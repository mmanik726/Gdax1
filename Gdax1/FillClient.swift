//
//  FillClient.swift
//  Gdax1
//
//  Created by Mohammed on 12/7/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation


class FillResponse: OrderResponse
{

    var completelyFilled: Bool = false
    var unfilledAmount: Float = 0.0
    
}

class FillClient
{
    var logger:LoggerProtocol?
    
    var auth: AuthContainer
    let ExReq: ExchanageRequest
    static var OrderTrackingComplete: Bool = false //decalred static becuase multiple threads/instances will access the same value
    
    static var trackingInProgressLock:Bool = false
    
    init(inputAuth: AuthContainer)
    {
        auth = inputAuth
        ExReq = ExchanageRequest(inputAuth: auth)
        FillClient.OrderTrackingComplete = false
        FillClient.trackingInProgressLock = false
    }
    
    public func TrackOrder(orderNumber: String, completion: @escaping (FillResponse) ->() )
    {
        //track order
        FillClient.OrderTrackingComplete = false
        
        
        FillClient.trackingInProgressLock = false
        

        DispatchQueue.global(qos: .default).async
        {

            while FillClient.OrderTrackingComplete == false
            {
                self.logger?.WriteLog("tacking order number: \(orderNumber)")
                
                do
                {
                    FillClient.trackingInProgressLock = true //lock other actions
                    
                    try self.ExReq.execute(requestType: "GET", requestEndpoint: "/orders/" + orderNumber) { (exResponse) in
                        
                        let filledOrder = FillResponse()
                        
                        if exResponse.statusCode == 200
                        {
                            
                            if let filledAmount:Float = Float(exResponse.jsonResponse?["filled_size"] as! String)
                            {
                                if ( filledAmount > 0.0)
                                {
                                    
                                    
                                    filledOrder.orderId = exResponse.jsonResponse?["id"] as! String
                                    
                                    
                                    if (exResponse.jsonResponse?["price"] != nil)
                                    {
                                        filledOrder.price = exResponse.jsonResponse?["price"] as! String
                                    }else
                                    {
                                        filledOrder.price = "0.0" //indicates market order
                                    }
                                    
                                    //filledOrder.price = exResponse.jsonResponse?["price"] as! String
                                    
                                    
                                    filledOrder.size = exResponse.jsonResponse?["size"] as! String
                                    filledOrder.productId = exResponse.jsonResponse?["product_id"] as! String
                                    filledOrder.side = exResponse.jsonResponse?["side"] as! String
                                    filledOrder.type = exResponse.jsonResponse?["type"] as! String
                                    filledOrder.postOnly = String (exResponse.jsonResponse?["post_only"] as! Bool)
                                    
                                    filledOrder.createdAt = exResponse.jsonResponse?["created_at"] as! String
                                    filledOrder.fillFee = exResponse.jsonResponse?["fill_fees"] as! String
                                    filledOrder.filledSize = exResponse.jsonResponse?["filled_size"] as! String
                                    filledOrder.executedValue = exResponse.jsonResponse?["executed_value"] as! String
                                    filledOrder.status = exResponse.jsonResponse?["status"] as! String
                                    filledOrder.settled = String(exResponse.jsonResponse?["settled"] as! Bool)
                                    
                                    
                                    let orderedAmount:Float = Float(exResponse.jsonResponse?["size"] as! String)!
                                    let filledAmount:Float = Float(exResponse.jsonResponse?["filled_size"] as! String)!
                                    
                                    
                                    if (orderedAmount != filledAmount )
                                    {
                                        filledOrder.completelyFilled = false
                                        filledOrder.unfilledAmount = orderedAmount - filledAmount
                                    }
                                    else
                                    {
                                        filledOrder.completelyFilled = true
                                    }
                                    
                                    FillClient.OrderTrackingComplete = true
                                    completion(filledOrder)
                                }
                            }
                            
                            
                        }
                        else if exResponse.statusCode == 404 || exResponse.statusCode == 400//order not found or already done (bad request)
                        {
                            
                            filledOrder.orderId = "UNKNOWN"
                            
                            filledOrder.completelyFilled = false
                            filledOrder.unfilledAmount = 0.0
                            
                            FillClient.OrderTrackingComplete = true
                            completion(filledOrder)
                        }

                        
                        
                    }
                }
                catch
                {
                    self.logger?.WriteLog("Error tracking active order")
                    print (error)
                }
                
                
                FillClient.trackingInProgressLock = false //release lock
                
                sleep(2) //sleep 2 seconds before checking agin
            }

            
        }
        
        
        

        
        
    }
    
    
    public func StopTrackingCurOrder()
    {
        //this will stop the while loop
        FillClient.OrderTrackingComplete = true
        
    }
    
    
}
