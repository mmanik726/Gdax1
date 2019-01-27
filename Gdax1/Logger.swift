//
//  Logger.swift
//  Gdax1
//
//  Created by Mohammed on 12/8/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import SwiftDate

import UIKit

public class Logger
{
    
    var logData:MyCoreDataUtil?
    var logProductName:String
    var loggerInstance:Logger?
    //use singleton to ensure only one log instace
    //but writeLog method is static anyways
    var logContainer:UITextView?
    init(inputContainer: UITextView, prodName:String )
    {

        //loggerInstance = Logger()
        logContainer = inputContainer
        logData = MyCoreDataUtil()
        
        logProductName = prodName
        
        
    }
    
//    public func setUIContainer(inputContainer: UITextView)
//    {
//        logContainer = inputContainer
//    }
    
    public func WriteLog(_ msg : String)
    {
        
        let date = DateInRegion()
        let dtStr = date.string(format: .custom("MM/dd hh:mm:ss aaa"))
        
        let tempLine: String = dtStr + "\t" + msg
        
        DispatchQueue.global().async {
            print(tempLine)
        }
        
        DispatchQueue.main.async
        {
            
            if self.logContainer != nil
            {
                self.logContainer?.text.append(tempLine + "\n")
                
                
                let stringLength:Int = self.logContainer!.text.characters.count
                self.logContainer?.scrollRangeToVisible(NSMakeRange(stringLength - 1, 0))
                
            }
            
            
            
            if self.logContainer!.text.characters.count > 5000
            {
                
                let tempAppLog = GdaxAppLog()
                tempAppLog.productName = self.logProductName
                tempAppLog.dateTime = dtStr
                tempAppLog.logMsg = self.logContainer!.text
                
                self.logData?.saveLog(log: tempAppLog)
                
                //clear whats in the current text
                self.logContainer?.text = ""
                self.WriteLog("log saved to permanent database")
            }
            
        }
        
        
    }
    
    
    
}
