//
//  Orders.swift
//  Gdax1
//
//  Created by Mohammed on 12/6/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation
import SwiftyJSON




class OrderResponse
{

//    {
//    "id": "d0c5340b-6d6c-49d9-b567-48c4bfca13d2",
//    "price": "0.10000000",
//    "size": "0.01000000",
//    "product_id": "BTC-USD",
//    "side": "buy",
//    "stp": "dc",
//    "type": "limit",
//    "time_in_force": "GTC",
//    "post_only": false,
//    "created_at": "2016-12-08T20:02:28.53864Z",
//    "fill_fees": "0.0000000000000000",
//    "filled_size": "0.00000000",
//    "executed_value": "0.0000000000000000",
//    "status": "pending",
//    "settled": false
//    }
    
    var orderId: String = ""
    var price: String = ""
    var size: String = ""
    var productId: String = ""
    var side: String = ""
    var type: String = ""
    var postOnly: String = ""
    var createdAt: String = ""
    var fillFee: String = ""
    var filledSize: String = ""
    var executedValue: String = ""
    var status: String = ""
    var settled: String = ""
    
}


class CancelResponse
{
    enum cancelResult {
        case OK
        case NotFound
        case PermissionDenied
        case AlreadyDone
        case Unknown
    }
    
    
    var result: cancelResult
    
    init()
    {
        result = .Unknown
    }
    
}


class Orders
{
    var logger:LoggerProtocol? = nil
    
    var auth: AuthContainer
    let ExReq: ExchanageRequest
    
    var currentOrderId:String = ""
    
    init(inputAuth: AuthContainer)
    {
        auth = inputAuth
        ExReq = ExchanageRequest(inputAuth: auth)
    }
    
    public func PlaceNewOrder(side: String, amount: String, atPrice: String, type: String, productId: String, postOnly: Bool, completion: @escaping (OrderResponse) -> ())
    {
        
        let parameters = ["side": side, "size":amount, "price":atPrice, "type":type, "product_id":productId, "post_only": postOnly] as [String : Any]
        
        
        
        do
        {
            try ExReq.execute(requestType: "POST", requestEndpoint: "/orders", body: parameters, completion: {(exResponse) in

                self.logger?.WriteLog("POST request complete")

                if exResponse.statusCode! != 200
                {
                    self.logger?.WriteLog("Server error occured: \(exResponse.jsonResponse?["message"] as! String)")
                    print ("server error occured")
                    print (exResponse.jsonResponse?["message"] as! String)
                }
                else
                {
                    print ("new order id: \((exResponse.jsonResponse?["id"] as! String))")
                    
                    self.currentOrderId = (exResponse.jsonResponse?["id"] as! String)
                    
                    
                    //sample response
                    //    {
                    //    "id": "d0c5340b-6d6c-49d9-b567-48c4bfca13d2",
                    //    "price": "0.10000000",
                    //    "size": "0.01000000",
                    //    "product_id": "BTC-USD",
                    //    "side": "buy",
                    //    "stp": "dc",
                    //    "type": "limit",
                    //    "time_in_force": "GTC",
                    //    "post_only": false,
                    //    "created_at": "2016-12-08T20:02:28.53864Z",
                    //    "fill_fees": "0.0000000000000000",
                    //    "filled_size": "0.00000000",
                    //    "executed_value": "0.0000000000000000",
                    //    "status": "pending",
                    //    "settled": false
                    //    }
                    
                    let orderDetails = OrderResponse()
                    
                    orderDetails.orderId = exResponse.jsonResponse?["id"] as! String
                    
                    if (exResponse.jsonResponse?["price"] != nil)
                    {
                        orderDetails.price = exResponse.jsonResponse?["price"] as! String
                    }else
                    {
                        orderDetails.price = "0.0" //indicates market order
                    }
                    
                    
                    orderDetails.size = exResponse.jsonResponse?["size"] as! String
                    orderDetails.productId = exResponse.jsonResponse?["product_id"] as! String
                    orderDetails.side = exResponse.jsonResponse?["side"] as! String
                    orderDetails.type = exResponse.jsonResponse?["type"] as! String
                    orderDetails.postOnly = String (exResponse.jsonResponse?["post_only"] as! Bool)
                    
                    orderDetails.createdAt = exResponse.jsonResponse?["created_at"] as! String
                    orderDetails.fillFee = exResponse.jsonResponse?["fill_fees"] as! String
                    orderDetails.filledSize = exResponse.jsonResponse?["filled_size"] as! String
                    orderDetails.executedValue = exResponse.jsonResponse?["executed_value"] as! String
                    orderDetails.status = exResponse.jsonResponse?["status"] as! String
                    orderDetails.settled = String(exResponse.jsonResponse?["settled"] as! Bool)
                    

                    completion(orderDetails)
                    
                }
                
            })
            
            
            
        }
        catch
        {
            print (error)
        }
        
    }
    
    
    
    
    public func CancelSingleOrder(orderId: String, completion: @escaping (CancelResponse)->())
    {
     
        do
        {
            print ("trying to cancel order: \(orderId)")
            try ExReq.execute(requestType: "DELETE", requestEndpoint: "/orders/" + orderId, completion: {(exResponse) in
                
                self.logger?.WriteLog("DELETE request complete")
                
                let responseResult = CancelResponse()
                
                if exResponse.statusCode == 200
                {
                    responseResult.result = .OK
                    completion(responseResult)
                }
                else if exResponse.statusCode == 404
                {
                    //not found 
                    responseResult.result = .OK
                    completion(responseResult)
                }
                else if exResponse.statusCode == 400
                {
                    //bad request: order already done 
                    responseResult.result = .AlreadyDone
                    completion(responseResult)
                }
                else
                {
                    responseResult.result = .Unknown
                    completion(responseResult)
                }
                
                
            })
        }
        catch
        {
            print (error)
        }
        
        
    }
    
    
    
    public func CancelAllOrders()
    {
        do
        {
            try ExReq.execute(requestType: "DELETE", requestEndpoint: "/orders", completion: {(exResponse) in

                self.logger?.WriteLog("DELETE request complete")
            })
        }
        catch
        {
            print (error)
        }
    }
    
    
    
    
    public func GetAllOpenOrders(productName: String, completion: @escaping ([OrderResponse])->())
    {
        
        let endpoint = "/orders?status=open&product_id=" + productName
        
        do
        {
            try ExReq.execute(requestType: "GET", requestEndpoint: endpoint) { (exResponse) in
                //
                
                //parse list of orders
                var orders: [OrderResponse] = []
                
                let json = try? JSON(data: exResponse.rawServerData!, options: .allowFragments)
                
                for curData in (json?.arrayValue)!
                {
                    
                    //Logger.WriteLog(curData.arrayValue)

                    let orderDetails = OrderResponse()
                    
                    //var temp = curData["id"] as! String
                    
                    orderDetails.orderId = curData["id"].string!
                    orderDetails.price = curData["price"].string!
                    orderDetails.size = curData["size"].string!
                    orderDetails.productId = curData["product_id"].string!
                    orderDetails.side = curData["side"].string!
                    orderDetails.type = curData["type"].string!
                    orderDetails.postOnly = String (curData["post_only"].bool!)
                    
                    orderDetails.createdAt = curData["created_at"].string!
                    orderDetails.fillFee = curData["fill_fees"].string!
                    orderDetails.filledSize = curData["filled_size"].string!
                    orderDetails.executedValue = curData["executed_value"].string!
                    orderDetails.status = curData["status"].string!
                    orderDetails.settled = String(curData["settled"].bool!)
                    
                    orders.append(orderDetails)
                    
                    
                }
                
                
                completion(orders)
                
            }
        }
        catch
        {
            self.logger?.WriteLog("error gettging all open orders \(error)")
        }
        
    }

    
    
    
    
    
    
    public func GetRecentFills(productName: String, completion: @escaping ([OrderResponse])->())
    {
        
        let endpoint = "/fills?product_id=" + productName
        
        do
        {
            try ExReq.execute(requestType: "GET", requestEndpoint: endpoint) { (exResponse) in
                //
                
                //parse list of orders
                var orders: [OrderResponse] = []
                
                let json = try? JSON(data: exResponse.rawServerData!, options: .allowFragments)
                
                print(json)
                
                for curData in (json?.arrayValue)!
                {
                    
                    //Logger.WriteLog(curData.arrayValue)
                    
                    let orderDetails = OrderResponse()
                    
                    //var temp = curData["id"] as! String
                    
                    
//                    "product_id" : "LTC-USD",
//                    "liquidity" : "M",
//                    "profile_id" : "ac67da92-ee4d-4fa1-9b56-f69bea68885f",
//                    "order_id" : "31ad0a5a-4bc6-4496-a693-a220f5e3ee51",
//                    "side" : "buy",
//                    "created_at" : "2017-12-10T10:27:37.763Z",
//                    "settled" : true,
//                    "size" : "0.01000000",
//                    "user_id" : "593f7e4624ce744c8791cca5",
//                    "fee" : "0.0000000000000000",
//                    "price" : "140.52000000",
//                    "trade_id" : 15737514
                    
                    
                    orderDetails.productId = curData["product_id"].string!
                    orderDetails.orderId = curData["order_id"].string!
                    orderDetails.side = curData["side"].string!
                    orderDetails.createdAt = curData["created_at"].string!
                    orderDetails.filledSize = curData["size"].string!
                    orderDetails.fillFee = curData["fee"].string!
                    orderDetails.price = curData["price"].string!
                    
                    
                    
                    
                    
                    
//                    orderDetails.type = curData["type"].string!
//                    orderDetails.postOnly = String (curData["post_only"].bool!)
//                    orderDetails.executedValue = curData["executed_value"].string!
//                    orderDetails.status = curData["status"].string!
//                    orderDetails.settled = String(curData["settled"].bool!)
                    
                    orders.append(orderDetails)
                    
                    
                }
                
                
                completion(orders)
                
            }
        }
        catch
        {
            self.logger?.WriteLog("error gettging recent filled orders \(error)")
        }
        
    }
    
    
    
    
    
}



class x
{
    var logger:LoggerProtocol?
    var auth: AuthContainer
    let ExReq: ExchanageRequest
    
    
    init(inputAuth: AuthContainer)
    {
        auth = inputAuth
        ExReq = ExchanageRequest(inputAuth: auth)
    }
    
    
    func getHistoricPrices()
    {
        
        do
        {
            try ExReq.execute(requestType: "GET", requestEndpoint: "/products/LTC-USD/candles", completion: {(exResponse) in
                
                self.logger?.WriteLog("get request complete")
                
                self.logger?.WriteLog("prices:")
                
                let json = try? JSON(data: exResponse.rawServerData!)
                
                
                for curData in (json?.arrayValue)! {
                    
                    print(curData.arrayValue)
                    
                    print("time: \(curData.arrayValue[0])")
                    print("price 1: \(curData.arrayValue[1])")
                    //                    for data in curData.arrayValue {
                    //                        //print (data)
                    //
                    //                        print (data[])
                    //                    }
                    //                    for curCandle in curData[0]
                    //                    {
                    //                        print ("time: \(curCandle)")
                    //                    }
                }
                
                
                //print (exResponse.jsonResponse)
                
            })
        }
        catch
        {
            print (error)
        }
    }
}
