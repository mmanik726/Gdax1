//
//  MyCoreDataUtil.swift
//  Gdax1
//
//  Created by Mohammed on 12/10/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import CoreData


class GdaxAuthSettings
{
    var userName = ""
    var apiKey = ""
    var passPhrase = ""
    var secret = "" 
}


class GdaxAppLog
{
    var dateTime = ""
    var productName = ""
    var logMsg = ""
    
}

public class MyCoreDataUtil
{
    var firstRun:Bool = true
    
    
    
    func getSettings() -> GdaxAuthSettings
    {
        
        let retrievedData = GdaxAuthSettings()
        
        let appDelegate = AppDelegate()
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSettings")
        
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let username = result.value(forKey: "user_name") as? String
                    {
                        //gets the user name value
                        retrievedData.userName = username
                    }
                    
                    if let apiKey = result.value(forKey: "api_key") as? String
                    {
                        //gets the user name value
                        retrievedData.apiKey = apiKey
                    }
                    
                    if let passPhrase = result.value(forKey: "pass_phrase") as? String
                    {
                        //gets the user name value
                        retrievedData.passPhrase = passPhrase
                    }
                    
                    if let secret = result.value(forKey: "secret") as? String
                    {
                        //gets the user name value
                        retrievedData.secret = secret
                    }
                }
            }
            
            print ("data retrieved successfully from core data database ")
            
            return retrievedData
        }
        catch
        {
            print ("an error occured while retrieving data \(error.localizedDescription)")
        }
        return retrievedData
    }
    
    
    
    
    
    func saveSettings(userSettings: GdaxAuthSettings)
    {
        let appDelegate = AppDelegate()// UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newSetting = NSEntityDescription.insertNewObject(forEntityName: "UserSettings", into: context)
        
        newSetting.setValue(userSettings.userName, forKey: "user_name")
        newSetting.setValue(userSettings.apiKey, forKey: "api_key")
        newSetting.setValue(userSettings.passPhrase, forKey: "pass_phrase")
        newSetting.setValue(userSettings.secret, forKey: "secret")
        
        
        do
        {
            try context.save()
            
            print ("data saved successfully into core data database ")
        }
        catch
        {
            print ("an error occured while saving data \(error.localizedDescription)")
        }
        
    }
    

    
    
    
    func saveLog(log: GdaxAppLog)
    {
        let appDelegate = AppDelegate()// UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLog = NSEntityDescription.insertNewObject(forEntityName: "Logs", into: context)
        
        newLog.setValue(log.dateTime, forKey: "date_time")
        newLog.setValue(log.productName, forKey: "product_name")
        newLog.setValue(log.logMsg, forKey: "log_msg")
        
        
        do
        {
            try context.save()
            
            print ("data saved successfully into core data database ")
        }
        catch
        {
            print ("an error occured while saving data \(error.localizedDescription)")
        }
        
    }
    
    
    
    func getLogs() -> GdaxAppLog
    {
        
        let retrievedData = GdaxAppLog()
        
        let appDelegate = AppDelegate()
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "logs")
        
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let prodName = result.value(forKey: "product_name") as? String
                    {
                        retrievedData.productName = prodName
                    }
                    
                    if let logMsg = result.value(forKey: "log_msg") as? String
                    {
                        retrievedData.logMsg = logMsg
                    }
                    
                    if let dateTime = result.value(forKey: "date_time") as? String
                    {
                        retrievedData.dateTime = dateTime
                    }

                }
            }
            
            print ("data retrieved successfully from core data database ")
            
            return retrievedData
        }
        catch
        {
            print ("an error occured while retrieving data \(error.localizedDescription)")
        }
        return retrievedData
    }
    
    
    
    
    
    
    
    

}
