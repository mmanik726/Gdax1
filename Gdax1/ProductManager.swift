//
//  ProductManager.swift
//  Gdax1
//
//  Created by Mohammed on 12/7/17.
//  Copyright © 2017 Manik. All rights reserved.
//
//
import Foundation

import UIKit

import Signals

import UserNotifications

class ProductManager: TickerDelegate, UiOrderCancelDelegate, LoggerProtocol
{
    let PriceUpdateSignal:Signal<String>
    
    var isInBackground: Bool = false
    
    let FundsUpdateSignal:Signal<AvailableFunds>
    
    let productTicker: Ticker
    
    let ProductName: String
    
    let Auth: AuthContainer
    
    let OrderBook: Orders
    
    let ProductFilleClient : FillClient
    
    let tableViewUpdater: UiUpdater
    
    static var orderOngoing:Bool = false
    
    var curOrderDetails:OrderResponse
    
    var lastTick:Date
    
    var ProductAvalilablFunds:AvailableFunds
    
    let ProductAccountInfo: Accounts

    let productLogger:Logger
    
    var lastCheckedPrice:Float = 0.0
    var lastPriceCheckTime = Date()
    
    
    var logger:LoggerProtocol?
    
    var inBackgroundSignal = Signal<Any>()
    var inForeGroundSignal = Signal<Any>()
    
    var bgWorker:BGWorker
    
    var isGrantedNotificationAccess:Bool = false
    
    func WriteLog(_ msg: String)
    {
        //print(msg)
        productLogger.WriteLog(msg)

    }
    
    
    
    init(productName: String, inputAuth: AuthContainer, myTableView: UITableView, logContainer:UITextView)
    {
        //Logger.WriteLog("\(productName) manager initializing...")
        
        
        productLogger = Logger(inputContainer: logContainer, prodName: productName)
        
        //productLogger.setUIContainer()
        
        bgWorker = BGWorker()
        
        PriceUpdateSignal = Signal<String>()
        FundsUpdateSignal = Signal<AvailableFunds>()
        
        ProductName = productName
        Auth = inputAuth
        OrderBook = Orders(inputAuth: Auth)
        
        ProductFilleClient = FillClient(inputAuth: Auth)
        
        productTicker = Ticker(productName: productName)
        
        curOrderDetails = OrderResponse()
        
        tableViewUpdater = UiUpdater(tableView: myTableView)
        
        lastTick = Date()
        
        
        ProductAvalilablFunds = AvailableFunds()
        
        
        ProductAccountInfo = Accounts(auth: inputAuth)//Accounts(auth: inputAuth, logHandler: self)
        
        AppDelegate.myAppDelSig.subscribe(with: self, callback: processAppDelEvents)
        
        tableViewUpdater.UiCancelOrderDelegate = self
        
        productTicker.TickEventDelegate = self
        
        //uiUpdater = UiUpdater(tableView: myTableView)
        
        getAvailableFunds()
        
        
        //update logic so orders are not auto handled on app start
        //show promt before auto handling
        //checkOpenOrders()
        
        setLoggerHandlers()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted}
        )
        
    }
    
    
    func showNotification(title:String, subtitle:String, body:String){
        
        if !isGrantedNotificationAccess
        {
            return
        }
        
        let first = UNMutableNotificationContent()
        first.title = title
        first.subtitle = subtitle
        first.body = body
        first.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request  = UNNotificationRequest(identifier: "identifier_" + ProductName, content: first, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            //code after completion
            //first.badge = 0
        }
    }
    
    func processAppDelEvents(eventName:String)
    {
        
        print(eventName)
        
        switch eventName
        {
            case "applicationWillResignActive":
                break
            
            case "applicationWillEnterForeground":
                break
            
            case "applicationDidEnterBackground":
            
                self.productLogger.WriteLog("Entering background mode")
                
                self.bgWorker.startBackgroundTask()
                
                inBackgroundSignal.fire((Any).self)
                self.isInBackground = true
            
            case "applicationDidBecomeActive":
            
                self.productLogger.WriteLog("Entering foreground mode")
                
                self.bgWorker.stopBackgroundTask()
                
                self.isInBackground = false
                
                inForeGroundSignal.fire((Any).self)
                
                logger?.WriteLog("updating funds")
                getAvailableFunds()
            
            default:
                break
                //print("")
        }
    }
    
    
    
    func setLoggerHandlers()
    {
        self.logger = self
        productTicker.logger = self
        OrderBook.logger = self
        
        ProductFilleClient.logger = self
        
        //ProductAvalilablFunds
        ProductAccountInfo.logger = self
        
        
    }
    
    
    func getAvailableFunds()
    {
        //setup variables for available funds for current product
        
        ProductAccountInfo.GetAllProductAccountDetails(productname: ProductName) { (availableFunds) in
            self.ProductAvalilablFunds = availableFunds
            
            self.logger?.WriteLog("You have \(availableFunds.AvailableProductBalance) \(self.ProductName) available")
            self.logger?.WriteLog("You have \(availableFunds.AvailableUSDBalance) USD available")
            
            
            DispatchQueue.main.async {
                self.FundsUpdateSignal.fire(availableFunds)
            }
            
            //self.FundsUpdateSignal.fire(availableFunds)
            
        }
    }
    
    
    
    
    func checkOpenOrders()
    {
        self.logger?.WriteLog("Checking for any previous open orders from servers")
        OrderBook.GetAllOpenOrders(productName: ProductName) { (openOderList) in
            
            if openOderList.count > 0
            {
                self.logger?.WriteLog("found \(openOderList.count) order(s) that are open, starting tracker")
                
                let curOpenOrder = openOderList[0]

                DispatchQueue.main.async {
                    // Update UI
                    self.tableViewUpdater.insertNewRow(inputOrderResponse: curOpenOrder)
                }
                
                self.curOrderDetails = curOpenOrder
                ProductManager.orderOngoing = true
                self.ProductFilleClient.TrackOrder(orderNumber: curOpenOrder.orderId, completion: self.OrderFilledEventHandler)
            }
        }
        
    }
    
    
    func getHistory(completion: @escaping (([OrderResponse])->()))
    {

        //self.logger?.WriteLog("Checking for any previous open orders from servers")
        OrderBook.GetRecentFills(productName: ProductName) { (recentFillList) in
            
            if recentFillList.count > 0
            {
                self.logger?.WriteLog("found \(recentFillList.count) recent fills")

                completion(recentFillList)
                
            }
        }
        
    }
    
    
    //price update event handler
    
    func handleTickUpdate(realtimePrice: Float, bufferedPrice: Float) {
        //price updates are here 
        
        
        notifyPriceChange()
        
        
        
        //notify all price update listeners
        PriceUpdateSignal.fire(String(realtimePrice))
        
        
        //self.logger?.WriteLog("\(ProductName): realtimeprice: \(realtimePrice), buffered: \(bufferedPrice)")
        
        // if order is on going
        // and last price tick was > 4 seconds ago
        //cancel current order
        //and place new order at new price
        

        let timeDiff = Date().seconds(from: lastTick)
        
        //Logger.WriteLog("time since last tick \(timeDiff)")

        if timeDiff > 8
        {
            lastTick = Date()
            
            if (ProductManager.orderOngoing)
            {
                self.logger?.WriteLog("trying to cancel and reorder ")
                cancelAndReorder()
            }
        }
        

        
    }
    
    
    func notifyPriceChange()
    {
        
        if (lastCheckedPrice == 0)
        {
            lastCheckedPrice = productTicker.curRealTimePrice
            return
        }
        
        let timeDiff = Date().seconds(from: lastPriceCheckTime)

        let NOTIFY_INTERVAL = 60 //every minute
        let CHANGE_PERCENT:Float = 0.20 / 100 //percent
        
        //print(timeDiff)
        if (timeDiff >= NOTIFY_INTERVAL)
        {
            let priceChange = (productTicker.curRealTimePrice - lastCheckedPrice)
            if priceChange == 0
            {
                return
            }
            
            let pricChangePercent:Float = (priceChange / lastCheckedPrice) //* 100
            
            if ( abs(pricChangePercent) > CHANGE_PERCENT )
            {
                
                if pricChangePercent > 0
                {
                    //print("\(ProductName): last: \(lastCheckedPrice) current:\(productTicker.curRealTimePrice) percent: \(pricChangePercent) notifyat > \(CHANGE_PERCENT)")
                    
                    
                    let curP = String(format: "%.2f", productTicker.curRealTimePrice)
                    let lastP = String(format: "%.2f", lastCheckedPrice)
                    let pChange = String(format: "%.2f", abs(priceChange))
                    
                    let msg:String = "Currrent Price:\t $\(curP)\nLast Price:\t\t $\(lastP)"
                    showNotification(title: "Price change", subtitle: "\(ProductName) price went up $\(pChange)", body: msg)
                }
                else
                {
                    //print("\(ProductName): last: \(lastCheckedPrice) current:\(productTicker.curRealTimePrice) percent: \(pricChangePercent) notifyat > \(CHANGE_PERCENT)")
                    
                    
                    let curP = String(format: "%.2f", productTicker.curRealTimePrice)
                    let lastP = String(format: "%.2f", lastCheckedPrice)
                    let pChange = String(format: "%.2f", abs(priceChange))
                    
                    let msg:String = "Currrent Price:\t $\(curP)\nLast Price:\t\t $\(lastP)"
                    showNotification(title: "Price change", subtitle: "\(ProductName) price went down $\(pChange)", body: msg)
                }


            }

            lastPriceCheckTime = Date()
            lastCheckedPrice = productTicker.curRealTimePrice

        }
        
        
        
    }
    
    
    
    func cancelAndReorder()
    {
        
        
        
        while FillClient.trackingInProgressLock
        {
            print ("Waiting for current tracking action to complete before cancel and reorder")
            usleep(500 * 1000) //wait 500ms
        }

        //cancel current order 
        ConfirmCancelOrder(orderDetails: curOrderDetails) { (orderCancelled) in
            //
            if (orderCancelled)
            {
                //if order cancelled properly : stop trackng it
                self.ProductFilleClient.StopTrackingCurOrder()
                
                DispatchQueue.main.async(execute: { 
                    self.tableViewUpdater.deleteRow(inputOrderId: self.curOrderDetails.orderId)
                })
                
                
                //place new order
                self.PlaceOrder(side: self.curOrderDetails.side, amount: self.curOrderDetails.size, orderType: self.curOrderDetails.type)
                
                
            }
            else
            {
                //if order couldnt be cancelled: must have been filled 
                
                let tempFillResponse = FillResponse()
                tempFillResponse.orderId = self.curOrderDetails.orderId
                tempFillResponse.side = self.curOrderDetails.side
                tempFillResponse.size = self.curOrderDetails.size
                tempFillResponse.price = self.curOrderDetails.price
                tempFillResponse.productId = self.curOrderDetails.productId
                self.orderFilledOtherWise(filledOrder: tempFillResponse)
            }
            
        }
        
    }
    
    
    func ConfirmCancelOrder (orderDetails: OrderResponse, completion: @escaping (Bool)->())
    {
        //cancel the order
        
        
        
        OrderBook.CancelSingleOrder(orderId: orderDetails.orderId) { (cancelRes) in
            if cancelRes.result == .OK
            {
                completion(true)
                
                //stop the tracker for this order 
                self.ProductFilleClient.StopTrackingCurOrder()
            }
            else
            {
                completion(false)
            }
        }
        
    }
    
    //ticker connected handler 
    
    //ticker disconnected handler
    
    
    
    //place order
    

    
    
    func PlaceOrder(side: String, amount: String, orderType: String)
    {
        var type = orderType;
        
        var postOnly:Bool = true //"T"

        
        var orderAtPrice: Float = 0.01
        
        if type == "limit"
        {
            //not instant: tries to catch best price by placing oder slightly above below current price
            postOnly = true //"T"
            
            
            while(Float(self.productTicker.curBufferedPrice) == 0)
            {
                print ("waiting for current price refresh")
                
                //sleep(1)
                usleep(500 * 1000) //wait 500ms
            }

            orderAtPrice = (side == "buy") ? (self.productTicker.curBufferedPrice - 0.01) : (self.productTicker.curBufferedPrice + 0.01)
        }
        else if type == "limit_post_only_off"
        {
            //not instant: but quicker than limit, may hve fees depending on market conditions
            type = "limit"
            postOnly = false //"F"
            
            orderAtPrice = self.productTicker.curRealTimePrice
            
        }
        else if type == "market"
        {
            //instant order: with fee
            postOnly = false //"F"
            orderAtPrice = self.productTicker.curRealTimePrice
            
        }
        else
        {
            //default is limit to avoid fees
            postOnly = true //"T"
            
            while(Float(self.productTicker.curBufferedPrice) == 0)
            {
                print ("waiting for current price refresh")
                
                //sleep(1)
                usleep(500 * 1000) //wait 500ms
            }
            
            orderAtPrice = (side == "buy") ? (self.productTicker.curBufferedPrice - 0.01) : (self.productTicker.curBufferedPrice + 0.01)
        }
        
        
        
        OrderBook.PlaceNewOrder(side: side, amount: amount, atPrice: String(orderAtPrice), type: type, productId: ProductName, postOnly: postOnly) { (orderResponse) in
            
            // if order placed properly then start tracking it 
            
            
//            if orderResponse.status != "rejected" && orderResponse.type == "market"
//            {
//                self.logger?.WriteLog("market \(orderResponse.side) order of \(orderResponse.size) \(orderResponse.productId) @\(orderResponse.price) filled completely")
//                self.logger?.WriteLog("Fee: $\(orderResponse.fillFee)")
//
//                ProductManager.orderOngoing = false
//
//                self.getAvailableFunds()
//
//                return
//            }
            
            
            if orderResponse.status != "rejected"
            {
                
                DispatchQueue.main.async {
                    // Update UI
                    self.tableViewUpdater.insertNewRow(inputOrderResponse: orderResponse)
                }
                
                ProductManager.orderOngoing = true
                
                self.curOrderDetails = orderResponse
                
                self.ProductFilleClient.TrackOrder(orderNumber: orderResponse.orderId, completion: self.OrderFilledEventHandler)
            }
            else
            {
                
                
                //sleep(1) //wait 2 sec before placing new order request, too many requests to server will get ip banned/throttled
                usleep(500 * 1000) //500ms
                
                var newPrice = String(self.productTicker.curBufferedPrice)
                
                self.logger?.WriteLog("\(side) order of \(amount) \(self.ProductName) @\(orderAtPrice) was rejected, retrying with new price of \(newPrice)")
                
                //try again 
                
                while(Float(newPrice) == 0)
                {
                    print ("waiting for current price")
                    
                    newPrice = String(self.productTicker.curBufferedPrice)
                    //newPrice = String(self.productTicker.curBufferedPrice - 10.0) //TEST!!!
                    
                    //sleep(1)
                    usleep(500 * 1000) //wait 500ms
                }
                
                
                self.PlaceOrder(side: side, amount: amount, orderType: type)
            }
            
            
            
        }
        
    }
    
    
    //order filled event handler
    
    func OrderFilledEventHandler(filledOrder: FillResponse)
    {
        //update the ui with filled response
        

        if filledOrder.completelyFilled == true
        {
            self.logger?.WriteLog("\(filledOrder.side) order of \(filledOrder.size) \(filledOrder.productId) @\(filledOrder.price) filled completely")
            self.logger?.WriteLog("Fee: $\(filledOrder.fillFee)")
            DispatchQueue.main.async {
                // Update UI
                //delete the order
                self.tableViewUpdater.deleteRow(inputOrderId: filledOrder.orderId)
            }
            
            ProductManager.orderOngoing = false
            
            getAvailableFunds()
        }
        else
        {
            
            //this is from tracking an old order where it was laready cancelled
            if filledOrder.orderId == "UNKNOWN"
            {
                return
            }
            
            
            DispatchQueue.main.async {
                // Update UI
                
                //delete the old data
                self.tableViewUpdater.deleteRow(inputOrderId: filledOrder.orderId)
                
                //insert the new data
                self.tableViewUpdater.insertNewRow(inputOrderResponse: filledOrder)
                
            }
            
            
            self.logger?.WriteLog("\(filledOrder.side) order of \(filledOrder.size) \(filledOrder.productId) @\(filledOrder.price) filled partially")
            self.logger?.WriteLog("Fee: $\(filledOrder.fillFee)")
            
            //cancel reaminder of the unfilled order if possible
            
            OrderBook.CancelSingleOrder(orderId: filledOrder.productId, completion: { (cancelRes:CancelResponse) in
                //
                
                //if properly cancelled then retry remainder of unfilled amount if 0.01
                
                if cancelRes.result == .OK
                {
                        //retry remainder
                    if filledOrder.unfilledAmount > 0.01
                    {
                        //recursively place a new order
                        self.PlaceOrder(side: filledOrder.side, amount: String(filledOrder.unfilledAmount), orderType: filledOrder.type)
                    }
                    
                }
                else if (cancelRes.result == .AlreadyDone)
                {
                    //notify filled otherwise
                    
                    print ("order already done")
                    self.logger?.WriteLog("\(filledOrder.side) order of \(filledOrder.size) \(filledOrder.productId) @\(filledOrder.price) filled otherwise")
                    self.logger?.WriteLog("Fee: $\(filledOrder.fillFee)")
                    
                    self.orderFilledOtherWise(filledOrder: filledOrder)
                    
                }
                else if (cancelRes.result == .NotFound)
                {
                    //notify filled otherwise
                    
                    print ("order not found")
                    self.logger?.WriteLog("\(filledOrder.side) order of \(filledOrder.size) \(filledOrder.productId) @\(filledOrder.price) filled otherwise")
                    self.logger?.WriteLog("Fee: $\(filledOrder.fillFee)")
                    
                    self.orderFilledOtherWise(filledOrder: filledOrder)
                    
                }
                else
                {
                    self.logger?.WriteLog("error while cancelling order")
                    self.orderFilledOtherWise(filledOrder: filledOrder)
                }
                
            })
            
        
            
            
            
        }
    }

    func orderFilledOtherWise(filledOrder: FillResponse)
    {
        //Logger.WriteLog("\(filledOrder.side) order of \(filledOrder.size) \(filledOrder.productId) @\(filledOrder.price) filled completely")
        
        filledOrder.orderId = "UNKNOWN"
        
        DispatchQueue.main.async {
            // Update UI
            //delete the order
            
            self.tableViewUpdater.deleteRow(inputOrderId: filledOrder.orderId)
        }
        
        ProductManager.orderOngoing = false
        getAvailableFunds()
    }
    
    
    
    
    
    
}
