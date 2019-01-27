//
//  ViewController.swift
//  Gdax1
//
//  Created by Mohammed on 12/4/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import UIKit

//import SwiftyJSON

class ETHViewController: UIViewController
{
    
    
    
    @IBOutlet weak var lblAvailableProduct: UILabel!
    @IBOutlet weak var lblAvailableUSD: UILabel!
    @IBOutlet weak var lblRealtimePrice: UILabel!
    
    @IBOutlet weak var txtBuySellAmount: UITextField!
    
    
    @IBOutlet weak var wvETH: UIWebView!
    @IBOutlet weak var MyTableView: UITableView!
    
    @IBOutlet weak var txtLog: UITextView!
    
    @IBOutlet weak var segmentOptions: UISegmentedControl!
    
    var ETHManager:ProductManager?
    
    var logger:LoggerProtocol?
    
    
    @IBAction func btnSell(_ sender: Any)
    {
        let buyAmount = txtBuySellAmount.text!
        if buyAmount != ""
        {
            ETHManager?.PlaceOrder(side: "sell", amount: buyAmount, orderType: "limit")
        }
    }
    
    @IBAction func btnBuy(_ sender: Any)
    {
        let buyAmount = txtBuySellAmount.text!
        if buyAmount != ""
        {
            ETHManager?.PlaceOrder(side: "buy", amount: buyAmount, orderType: "limit")
        }
    }
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        loadFile(fileName: "TradeWidgetPageETH")
        
        txtLog.text = ""
        
        print("Initializing ETH manager")
        DispatchQueue.global().async
            {
                self.ETHManager = ProductManager(productName: "ETH-USD", inputAuth: AuthContainer(apikey: "", passPhrase: "", secret: ""),  myTableView: self.MyTableView, logContainer: self.txtLog)
                
                self.ETHManager?.inBackgroundSignal.subscribe(with: self, callback: self.inBackgroundHandler(_:))
                self.ETHManager?.inForeGroundSignal.subscribe(with: self, callback: self.inForegroundHandler(_:))
                
                self.ETHManager?.PriceUpdateSignal.subscribe(with: self, callback: self.updateRealTimePrice)
                
                self.ETHManager?.FundsUpdateSignal.subscribe(with: self, callback: self.updateAvailableFunds)
                
        }
        
    }
    
    
}


extension ETHViewController
{
    
    
    func inBackgroundHandler(_: Any)
    {
        unloadUiWebView()
    }
    
    func inForegroundHandler(_ param:Any)
    {
        loadFile(fileName: "TradeWidgetPageETH")
    }
    
    
    func unloadUiWebView()
    {
        self.wvETH.loadHTMLString("", baseURL: nil)
    }
    
    func updateRealTimePrice(price:String)
    {
        if !(self.ETHManager?.isInBackground)!
        {
            self.lblRealtimePrice.text = price
        }
        
    }
    
    
    
    @IBAction func SowHistory(_ sender: Any)
    {
        
        
        //sender can be any object
        //could be self but needs to be casted to correct type when using in
        // prepare for segue method
        ETHManager?.getHistory(completion: { (fills) in
            //
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowETHHistorySegue", sender: fills)
            }
        })
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowETHHistorySegue"
        {
            let destVC = segue.destination as! HistoryViewController
            destVC.CurrentProduct = ETHManager?.ProductName
            destVC.fillsList =  (sender as! [OrderResponse]) //LtcManager?.ProductName
        }
    }
    
    
    
//    func updateRealTimePrice(price:String)
//    {
//        self.lblRealtimePrice.text = price
//    }
    
    
    func updateAvailableFunds(availableFunds:AvailableFunds)
    {
        self.lblAvailableUSD.text = String(availableFunds.AvailableUSDBalance)
        self.lblAvailableProduct.text = String(availableFunds.AvailableProductBalance)
    }
    
    

    
    
    func loadFile(fileName: String)
    {
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
            wvETH.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch
        {
            print ("File HTML error")
        }
    
    //self.wvETH.loadHTMLString("", baseURL: nil)
    
    }
    
    
}






