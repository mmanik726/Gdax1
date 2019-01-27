//
//  ViewController.swift
//  Gdax1
//
//  Created by Mohammed on 12/4/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import UIKit

//import SwiftyJSON

class LTCViewController: UIViewController
{
    

    
//    func UIApplicationWillResignActive()
//    {
//        logger?.WriteLog("app will resign method")
//    }
//
//    func applicationWillResignActive(_ application: UIApplication){
//        
//    }
//    
//    func applicationDidBecomeActive()
//    {
//        
//    }
    
    @IBOutlet weak var lblAvailableProduct: UILabel!
    @IBOutlet weak var lblAvailableUSD: UILabel!
    @IBOutlet weak var lblRealtimePrice: UILabel!
    
    @IBOutlet weak var txtBuySellAmount: UITextField!
    @IBOutlet weak var wvLTC: UIWebView! //WKWebView!//
    
    @IBOutlet weak var MyTableView: UITableView!
    
    @IBOutlet weak var txtLog: UITextView!
    
    @IBOutlet weak var segmentOptions: UISegmentedControl!

    var LtcManager:ProductManager?
    
    var logger:LoggerProtocol?

    var webviewLoaded:Bool = false
    
    
    @IBAction func btnSell(_ sender: Any)
    {
        
        let curPrice = lblRealtimePrice.text!
        
        let orderType = getOrderType()
        
        if let buyAmount = self.txtBuySellAmount?.text
        {
            if isNumeric(a: buyAmount)
            {
                let myAlert = UIAlertController(title: "Confirm sell Order", message: "Place new '\(orderType)' sell order at \(curPrice)?", preferredStyle: UIAlertControllerStyle.alert)
                
                myAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.LtcManager?.PlaceOrder(side: "sell", amount: buyAmount, orderType: orderType)
                }))
                
                myAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                
                present(myAlert, animated: true, completion: nil)
            }
            else
            {
                logger?.WriteLog("Invalid amount, please enter correct amount")
            }
        }
        

        
        
        
    }
    
    @IBAction func btnBuy(_ sender: Any)
    {

        let curPrice = lblRealtimePrice.text!
        
        let orderType = getOrderType()
        
        if let buyAmount = self.txtBuySellAmount?.text
        {
            if isNumeric(a: buyAmount)
            {
                let myAlert = UIAlertController(title: "Confirm buy Order", message: "Place new '\(orderType)' sell order at \(curPrice)?", preferredStyle: UIAlertControllerStyle.alert)
                
                myAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.LtcManager?.PlaceOrder(side: "buy", amount: buyAmount, orderType: orderType)
                }))
                
                myAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                
                present(myAlert, animated: true, completion: nil)
            }
            else
            {
                logger?.WriteLog("Invalid amount, please enter correct amount")
            }
        }

    }


    func getOrderType() -> String
    {
        if (segmentOptions.selectedSegmentIndex == 0)
        {
            return "limit"
        }
        else if (segmentOptions.selectedSegmentIndex == 1)
        {
            return "limit_post_only_off"
        }
        else if (segmentOptions.selectedSegmentIndex == 2)
        {
            return "market"
        }
        else
        {
            return "limit" //default to limit order
        }
        
    }


    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //wvLTC.navigationDelegate = self
//        AppDelegate.myAppDelSig.subscribe(with: self, callback: perocessAppDelEvents)
        //self.logger = self
        
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if !webviewLoaded {
            loadFile(fileName: "TradeWidgetPageLTC")
        }
        
        webviewLoaded = true
        
        
        txtLog.text = ""

        print("initializing Ltc manager")
        DispatchQueue.global().async
        {
            self.LtcManager = ProductManager(productName: "LTC-USD", inputAuth: AuthContainer(apikey: "", passPhrase: "", secret: ""),  myTableView: self.MyTableView, logContainer: self.txtLog)
            
            self.LtcManager?.inBackgroundSignal.subscribe(with: self, callback: self.inBackgroundHandler(_:))
            self.LtcManager?.inForeGroundSignal.subscribe(with: self, callback: self.inForegroundHandler(_:))
            
            self.LtcManager?.PriceUpdateSignal.subscribe(with: self, callback: self.updateRealTimePrice)
            
            self.LtcManager?.FundsUpdateSignal.subscribe(with: self, callback: self.updateAvailableFunds)
            
            
        }

        
        
//        sleep(10)
//        
//        let t = MyCoreDataUtil()
//        
//        let s = GdaxAuthSettings()
//        s.userName = "Manik"
//        s.apiKey = "Manikapikey982038"
//        s.passPhrase = "Manik_passphrase283840 897234809 /2340982034"
//        s.secret = "Manik secret 0293-094-238327095790- a/a'dflae"
//        
//        t.saveSettings(userSettings: s)
//        
//        
//        sleep(5)
//        
//        let x = t.getSettings()
        
        
        
    }


}


extension LTCViewController
{

    func inBackgroundHandler(_: Any)
    {
        //unloadUiWebView()
    }
    
    func inForegroundHandler(_ param:Any)
    {
        //loadFile(fileName: "TradeWidgetPageLTC")
    }
    
    
    func unloadUiWebView()
    {
        //self.wvLTC.loadHTMLString("", baseURL: nil)
    }
    
    func updateRealTimePrice(price:String)
    {
        if !(LtcManager?.isInBackground)!
        {
            
            if let curLblPrice = Float(self.lblRealtimePrice.text!)
            {
                if curLblPrice < (Float(price))!
                {
                    self.lblRealtimePrice.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                    //self.lblRealtimePrice.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
                }
                else
                {
                    self.lblRealtimePrice.textColor = #colorLiteral(red: 1, green: 0.2947081114, blue: 0.3164347739, alpha: 1)
                    //self.lblRealtimePrice.backgroundColor = #colorLiteral(red: 1, green: 0.2947081114, blue: 0.3164347739, alpha: 1)
                }
            }
            
            self.lblRealtimePrice.text = price
            //self.lblRealtimePrice.text = String(format: "%.2F", price)
            //self.lblRealtimePrice.text = String.localizedStringWithFormat("%.2f", price) //(format: "%.2F", price)
        }
        
    }
    
    
    
    @IBAction func SowHistory(_ sender: Any)
    {
        
        //sender can be any object
        //could be self but needs to be casted to correct type when using in
        // prepare for segue method
        
        LtcManager?.getHistory(completion: { (fills) in
            //
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowLTCHistorySegue", sender: fills)
            }
            
        })
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowLTCHistorySegue"
        {
            let destVC = segue.destination as! HistoryViewController
            destVC.CurrentProduct = LtcManager?.ProductName
            destVC.fillsList =  (sender as! [OrderResponse]) //LtcManager?.ProductName
        }
    }
    
    
    
    func isNumeric(a: String) -> Bool {
        return Double(a) != nil
    }

    
    func updateAvailableFunds(availableFunds:AvailableFunds)
    {
        self.lblAvailableUSD.text = String(availableFunds.AvailableUSDBalance)
        self.lblAvailableProduct.text = String(availableFunds.AvailableProductBalance)
    }
    


    
    
    func loadFile(fileName: String)
    {
        print("locading html page \(fileName)")
        do {
            guard let filePath = Bundle.main.path(forResource: fileName, ofType: "html")
                else
            {
                    // File Error
                    print ("File reading error")
                    return
            }
            
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            
            
            wvLTC.loadHTMLString(contents as String, baseURL: baseUrl)

            //wvLTC.loadRequest(URLRequest(url: URL(string: "https://www.tradingview.com")!))
            
//            var pref = WKPreferences()
//            pref.javaScriptEnabled = false
//            var config = WKWebViewConfiguration()
//            config.preferences = pref
            //wvLTC.script
        }
        catch
        {
            print ("File HTML error")
        }
        
        
        
        
        //self.wvLTC.loadHTMLString("", baseURL: nil)
        
    }
    
}






