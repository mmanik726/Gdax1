//
//  Accounts.swift
//  Gdax1
//
//  Created by Mohammed on 12/8/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import SwiftyJSON


public class AcccountDetails
{
    //    {
    //    "id": "71452118-efc7-4cc4-8780-a5e22d4baa53",
    //    "currency": "BTC",
    //    "balance": "0.0000000000000000",
    //    "available": "0.0000000000000000",
    //    "hold": "0.0000000000000000",
    //    "profile_id": "75da88c5-05bf-4f54-bc85-5c775bd68254"
    //    }
    
    var accountId:String = ""
    var currency:String = ""
    var balance:String = ""
    var available:String = ""
    var hold:String = ""
    var profileId:String = ""
    
    
}

public class AvailableFunds
{
    var ProductName:String = ""
    var AvailableProductBalance:Float = 0.00
    var AvailableUSDBalance:Float = 0.00
}


public class Accounts
{
    
    private let ExReq: ExchanageRequest
    
    var logger:LoggerProtocol?
    
    init(auth:AuthContainer)
    {
        ExReq = ExchanageRequest(inputAuth: auth)
        
    }
    

    
    func GetAllProductAccountDetails(productname:String, completion: @escaping ((AvailableFunds)->()))
    {
        
        
        let endpoint = "/accounts"
        
        do
        {
            try ExReq.execute(requestType: "GET", requestEndpoint: endpoint) { (exResponse) in
                //
                
                //parse list of orders
                var orders: [AcccountDetails] = []
                
                let json = try? JSON(data: exResponse.rawServerData!, options: .allowFragments)
                
                
                //Logger.WriteLog(json?.arrayValue)
                
                let productFundDetails = AvailableFunds()
                
                for curData in (json?.arrayValue)!
                {
                    
                    //    {
                    //    "id": "71452118-efc7-4cc4-8780-a5e22d4baa53",
                    //    "currency": "BTC",
                    //    "balance": "0.0000000000000000",
                    //    "available": "0.0000000000000000",
                    //    "hold": "0.0000000000000000",
                    //    "profile_id": "75da88c5-05bf-4f54-bc85-5c775bd68254"
                    //    }
                    
                    //Logger.WriteLog(curData.arrayValue)
                    
                    let account = AcccountDetails()
                    
                    account.accountId = curData["id"].string!
                    account.currency = curData["currency"].string!
                    account.balance = curData["balance"].string!
                    account.available = curData["available"].string!
                    account.hold = curData["hold"].string!
                    account.profileId = curData["profile_id"].string!
                    
                    orders.append(account)
                    
                    //str.startIndex, offsetBy: 5
                    
                    let index = productname.index(productname.startIndex, offsetBy: 3) // full name: "LTC-USD"
                    if account.currency == productname.substring(to: index)
                    {
                        productFundDetails.ProductName = productname
                        productFundDetails.AvailableProductBalance = Float(account.available)!
                    }
                    
                    if account.currency == "USD"
                    {
                        productFundDetails.AvailableUSDBalance = Float(account.available)!
                    }
                    
                    
                }
//
//                
//                let productFundDetails = AvailableFunds()
//                
//                if let itemIndex = orders.index(where: { (item) -> Bool in
//                    item.currency == productname
//                }){
//                    
//                    productFundDetails.ProductName = productname
//                    productFundDetails.AvailableProductBalance = Float(orders[itemIndex].balance)
//                }
                
                completion(productFundDetails)
                
                
            }
        }
        catch
        {
            self.logger?.WriteLog("error getting account info \(error)")
        }
        
        
    }
    
}
