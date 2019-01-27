//
//  ExchangeRequest.swift
//  Gdax1
//
//  Created by Mohammed on 12/4/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import CryptoSwift
import SwiftyJSON



public class ExchanageRequest
{
    var logger:LoggerProtocol?
    
    private var curRequestType : String?
    private var curRequestEndPoint: String?
    
    private var baseUrl: String?

    let auth: AuthContainer
    
    init(inputAuth: AuthContainer) {
        baseUrl = "https://api.gdax.com"
        curRequestType = "GET"
        curRequestEndPoint = "/"
        auth = inputAuth

    }
    
    
    func execute(requestType: String, requestEndpoint: String, body: [String:Any] = [:], completion: @escaping (ExchangeRespose) -> ()) throws
    {
        
        if requestType == "GET"
        {
            //executeGet(requestEndpoint)
            
            
            do
            {
                try executeRequest(requestEndpoint, requestType: requestType, body: [:], completion: { (exResponse) in
                    //completion handler after get request completes
                    
                    
                    if (exResponse.ResponseError != nil)
                    {
                        print(exResponse.ResponseError ?? "error")
                    }
                    else
                    {
                        completion(exResponse) //call completion handler to caller
                    }
                    
                })
            }
            catch
            {
                throw error
            }

            
            
            
            
        }
        else if requestType == "POST"
        {
            
            do
            {
                try executeRequest(requestEndpoint, requestType: requestType, body: body, completion: { (exResponse) in
                    //completion handler after get request completes
                    
                    
                    if (exResponse.ResponseError != nil)
                    {
                        print(exResponse.ResponseError ?? "error")
                    }
                    else
                    {
                        completion(exResponse) //call completion handler to caller
                    }
                    
                })
            }
            catch
            {
                throw error
            }


        }
        else if requestType == "DELETE"
        {
            do
            {
                try executeRequest(requestEndpoint, requestType: requestType, body: body, completion: { (exResponse) in
                    //completion handler after get request completes
                    
                    if (exResponse.ResponseError != nil)
                    {
                        print(exResponse.ResponseError ?? "error")
                    }
                    else
                    {
                        completion(exResponse) //call completion handler to caller
                    }
                    
                })
                
            }
            catch
            {
                throw error
            }
            
            
        }
        else
        {
            self.logger?.WriteLog("Invalid web method")
            return

        }
       
    }
    
    
    private func executeRequest(_ endpoint: String, requestType: String, body: [String:Any] = [:], completion: @escaping (ExchangeRespose) -> () ) throws
    {
        
        
        let ht = try? JSONSerialization.data(withJSONObject: body, options: [])
        var a = String(data: ht!, encoding: String.Encoding.utf8)
        print(a)

        guard let url = URL(string: (baseUrl! + endpoint)) else {return}
        
        let session = URLSession.shared
        
        
        
        var request = URLRequest(url: url)
        
        
        var httpBodyData:Data? // = ""
        
        if requestType == "GET"
        {
            request.httpMethod = "GET"
        }
        else if requestType == "POST"
        {
            request.httpMethod = "POST"
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {return}
            request.httpBody = httpBody
            
            //Logger.WriteLog(String(data: httpBody, encoding: String.Encoding.utf8) as String!)
            
            httpBodyData = httpBody
            
        }
        else if requestType == "DELETE"
        {
            request.httpMethod = "DELETE"
        }
        
        
        //common headers for all GET POST and DELETE
        request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        var signature = ""
        do
        {
            //calculate gdax specific request signature in base64 encoded format HMAC sha256 
            //signature consists of the timestamp, web method type, relative end point address and body text
            signature = try auth.ComputeSignature(relativeURL: endpoint, method: requestType, bodyData: httpBodyData)
        }
        catch
        {
            throw error
        }
        
        
        request.addValue(signature, forHTTPHeaderField: "CB-ACCESS-SIGN")
        request.addValue(auth.curTimeStamp!, forHTTPHeaderField: "CB-ACCESS-TIMESTAMP")
        request.addValue(auth.ApiKey, forHTTPHeaderField: "CB-ACCESS-KEY")
        request.addValue(auth.Passphrase, forHTTPHeaderField: "CB-ACCESS-PASSPHRASE")
        
        

        session.dataTask(with: request)
        { (data, response, error) in
            if let response = response
            {
                //Logger.WriteLog(response)
                //var dataString = String(data: data!, encoding: String.Encoding.utf8) as String!
                
                
                
//                if let httpResponse = response as? HTTPURLResponse
//                {
//                    Logger.WriteLog("status code: \(httpResponse.statusCode)")
//                }
            }
            else
            {
                //throw
            }
            
            
            if let data = data
            {
                //convert json to
                //Logger.WriteLog(data)
                
                do
                {

                    if let error = error {
                        do
                        {
                            let exResponse = try ExchangeRespose(inputResponse: response!, inputError: error, bodyData: data)
                            completion(exResponse)
                        }
                        catch
                        {
                            throw error
                        }

                    }
                    else
                    {
                        do
                        {
                            let exResponse = try ExchangeRespose(inputResponse: response!, bodyData: data)
                            completion(exResponse)
                        }
                        catch
                        {
                            throw error
                        }

                    }
                }
                catch
                {
                    print(error)
                }

            }

            
        }.resume()

        
    }
    

    
    
}



public class AuthContainer
{
    
    let Secret: String;
    let ApiKey: String
    let Passphrase: String
    
    var curTimeStamp:String?
    
    init(apikey: String, passPhrase: String, secret:String )
    {
           
        
        
        //manik
        ApiKey = "YOUR_APIKEY_GOES_HERE"//apikey
        Passphrase = "YOUR_PASSPHRASE_GOES_HERE"//passPhrase
        Secret = "YOUR_SECRET_GOES_HERE"//secret
        
        
        curTimeStamp = String(NSDate().timeIntervalSince1970)
    }
    
    
    
    public func ComputeSignature(relativeURL: String, method: String, bodyData: Data? = nil) throws -> String {
        
        //let body: Data? = bodyStr?.data(using: String.Encoding.utf8)
        
        let body: Data? = bodyData
        
        let secret64 = Secret
        
        let timestamp = Int64(Date().timeIntervalSince1970)
        
        curTimeStamp = String(timestamp)
        
        var preHash = "\(timestamp)\(method.uppercased())\(relativeURL)"
        
//        if let body = body {
//            guard let bodyString = String(data: body, encoding: .utf8) else {
//                throw GDAXError.authenticationBuilderError("Failed to UTF8 encode the request body")
//            }
        
        var bstr = ""
        if let body = body {
            if let bodyString = String(data: body, encoding: .utf8) {
                //throw GDAXError.authenticationBuilderError("Failed to UTF8 encode the request body")
                bstr = bodyString
            }
        
            
        }
        
        preHash += bstr
        
        guard let secret = Data(base64Encoded: secret64) else {
            throw GDAXError.authenticationBuilderError("Failed to base64 decode secret")
        }
        
        guard let preHashData = preHash.data(using: .utf8) else {
            throw GDAXError.authenticationBuilderError("Failed to convert preHash into data")
        }
        
        guard let hmac = try HMAC(key: secret.bytes, variant: .sha256).authenticate(preHashData.bytes).toBase64() else {
            throw GDAXError.authenticationBuilderError("Failed to generate HMAC from preHash")
        }
        
        return hmac
    }
    
}


public class ExchangeRespose
{
    var logger:LoggerProtocol?
    
    let bodyResponse: Data
    var ResponseError: Error? = nil
    let urlResponseData: URLResponse
    
    var jsonResponse: [String:AnyObject]?
    var statusCode: Int?
    
    var rawServerData: Data?
    var rawServerDataInJson: String?
    
    init(inputResponse: URLResponse, inputError: Error, bodyData: Data) throws
    {
        bodyResponse = bodyData
        ResponseError = inputError
        urlResponseData = inputResponse
        do
        {
            try parseServerData(data: bodyData, responseData: urlResponseData)
        }
        catch
        {
            throw error
        }
        
    }
    
    init(inputResponse: URLResponse, bodyData: Data) throws
    {
        bodyResponse = bodyData
        urlResponseData = inputResponse
        
        do
        {
            try parseServerData(data: bodyData, responseData: urlResponseData)
        }
        catch
        {
            throw error
        }
        
    }
    

    
    
    private func parseServerData(data: Data, responseData: URLResponse) throws
    {
        do
        {
            
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            
            rawServerData = data
            rawServerDataInJson = String(data: data, encoding: .utf8)
            
            //print (String(data: data, encoding: .utf8)! )
            //Logger.WriteLog(json)
            
            if json != nil {
                let all: [String : AnyObject] = try JSONSerialization.jsonObject( with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                
                jsonResponse = all
                
                //Logger.WriteLog(all)
                //jsonResponse = all
            }

            
            if let httpResponse = responseData as? HTTPURLResponse
            {
                self.logger?.WriteLog("status code: \(httpResponse.statusCode)")
                statusCode = httpResponse.statusCode
            }
            
        }
        catch
        {
            self.logger?.WriteLog("error parsing json data from server")
            throw GDAXError.responseParsingFailure("Could not parse response data from server")
        }
    }
}


public enum GDAXError: Error {
    
    case invalidStatusCode(Int, String)
    case authenticationBuilderError(String)
    case invalidResponseData
    case responseParsingFailure(String)
    case requestExecuteError(String)
    
    
    public var errorDescription: String? {
        switch self
        {
            case .invalidStatusCode(let statusCode, let message):
                return NSLocalizedString("(\(statusCode) - \(message))", comment: "error")
            case .authenticationBuilderError(let message):
                return NSLocalizedString(message, comment: "error")
            case .invalidResponseData:
                return NSLocalizedString("Could not read response data", comment: "error")
            case .responseParsingFailure(let message):
                return NSLocalizedString(message, comment: "error")
            case .requestExecuteError(let message):
                return NSLocalizedString(message, comment: "error")
        }
    }
    
}
