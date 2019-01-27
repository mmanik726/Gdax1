//
//  Ticker.swift
//  Gdax1
//
//  Created by Mohammed on 12/7/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import SwiftWebSocket


protocol TickerDelegate
{
    func handleTickUpdate(realtimePrice:Float, bufferedPrice: Float)
}


class Ticker
{
 
    var logger:LoggerProtocol?
    
    let socket:WebSocket
    let ProductId:String
    var curRealTimePrice: Float
    var curBufferedPrice:Float
    
    var lastTickTime:Date?
    
    var lastTickHandledTime:Date?
    var TickEventDelegate:TickerDelegate?
    
    
    struct socketEndPoint
    {
        let socketEndPoint: String = "wss://ws-feed.gdax.com"
        let socketExchangeName: String = "Gdax (Coinbase) Crypto Currency Exchange"
        
    }
    
    init(productName: String)
    {
        ProductId = productName
        
        let gdaxSocketFeed = socketEndPoint()
        
        curRealTimePrice = 0.0
        curBufferedPrice = 0.0
        
        socket = WebSocket(gdaxSocketFeed.socketEndPoint)
        
        
        
        socket.compression.on = true
        socket.services = [.Background]
        
        
        socket.event.open = {
            self.logger?.WriteLog("websocket connected to \(gdaxSocketFeed.socketExchangeName)")
        }
        
        socket.event.close = { code, reason, clean in
            self.logger?.WriteLog("Webcocket closed because: \(reason) code:\(code)")
            self.logger?.WriteLog("Retrying to connect in 2 sec")
            
            //dont block other threads
            DispatchQueue.global().async(execute: { 
                sleep(2)
                self.connectSocket()
            })
            
            
        }
        
        socket.event.error = { error in
            self.logger?.WriteLog("an error occured in websocket: \(error)")
        }
        
        
        
        socket.event.message = { message in
            if let msg = message as? String
            {
                self.handleMessage(jsonString: msg)
            }
        }
        
        
        connectSocket()
        
    }
    
    private func connectSocket()
    {
        socket.open()
        
//        let jsonObj: [String: Any] = [
//            "type": "subscribe",
//            "product_ids" : [ProductId]
//        ]

        
        let jsonObj: [String: Any] = [
            "type": "subscribe",
            "product_ids" : [ProductId],
            "channels": [["name": "ticker", "product_ids": [ProductId]]]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObj)
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        //Logger.WriteLog(jsonString)
        
        socket.send(jsonString)
    }
    
    
    private func handleMessage(jsonString:String)
    {
        
        
        
//        //handle messages only every 100 ms
//        if lastTickHandledTime != nil
//        {
//            let d = Date().nanoSeconds(from: lastTickHandledTime!) / 1000000
//            
//            
//            if ( d < 5)
//            {
//                //lastTickHandledTime = Date()
//                //print(d) //mili seconds
//                //print("skipped \(d)")
//                return
//            }
//        }
//        lastTickHandledTime = Date()
        
        
        
        
        if let data = jsonString.data(using: String.Encoding.utf8)
        {
            do
            {
                
                let JSON : [String:AnyObject] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                
                //print(JSON)
                
                let msgType : String = JSON["type"] as! String
                var curPrice = "0"
                //print(msgType)
                //if msgType == "match"
                if msgType == "ticker"
                {
                    curPrice = JSON["price"] as! String
                    //Logger.WriteLog(curPrice)
                    
                    //print(ProductId + ": " + curPrice)
                    
                    //let curPrice = String(format: "%.2f", Float(curPrice)!)
                    curRealTimePrice = Float(curPrice)!
                    
                    
                    if lastTickTime != nil
                    {
                        let timeDiff = Date().seconds(from: lastTickTime!)
                        
                        
                        //buffered price is sampled evey one seconds
                        if timeDiff >= 1
                        {
                            curBufferedPrice = curRealTimePrice
                        }
                    }
                    else
                    {
                        //iniital value
                        curBufferedPrice = curRealTimePrice
                    }
                    
                    
                    lastTickTime =  Date()
                    
                    
                    //call the price update handler delegate method for subscribers
                    TickEventDelegate?.handleTickUpdate(realtimePrice: curRealTimePrice, bufferedPrice: curBufferedPrice)

                    
                }
                
            }
            catch let error
            {
                self.logger?.WriteLog("Error parsing websocket json: \(error)")
            }
        }
    }
    
    
    

}


//some useful extensions to Date class

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /// Returns the amount of seconds from another date
    func nanoSeconds(from date: Date) -> Int {
        
        //return Calendar.current.dateComponents([Calendar.Component.nanosecond], from: date, to: Date()).n
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
        
        
    }
    
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
