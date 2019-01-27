//
//  UiUpdater.swift
//  Gdax1
//
//  Created by Mohammed on 12/7/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import Foundation

import UIKit



protocol UiOrderCancelDelegate
{
    func ConfirmCancelOrder (orderDetails: OrderResponse, completion: @escaping (Bool)->())
}

class UiUpdater : NSObject, UITableViewDataSource, UITableViewDelegate, CellButtonActionDelegate
{
    var logger:LoggerProtocol?
    
    var items: [OrderResponse] = []
    
    var MyTableView:UITableView?
    
    
    var UiCancelOrderDelegate:UiOrderCancelDelegate?
    
    init(tableView: UITableView)
    {

        super.init()
        
        MyTableView = tableView
        
        initTableView()
    }
    
    func initTableView()
    {
        MyTableView?.delegate = self
        MyTableView?.dataSource = self
    }

    
    
    //this function gets called everytime row is updated
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Logger.WriteLog("item count: \(items.count)")
        return items.count
    }
    
    
    //this function gets called everytime a new row appears
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        
        
        //send data to each row item and setup each row item. these functions gets called for each row
        
        let curRowIndex = indexPath.row
        
        cell.lblOrderId.text = items[curRowIndex].orderId
        cell.lblOrderTime.text = items[curRowIndex].createdAt//UtcToLocalDate(items[curRowIndex].createdAt)
        cell.lblProductName.text = items[curRowIndex].productId
        cell.lblProductSize.text = items[curRowIndex].size
        cell.lblProductSide.text = items[curRowIndex].side
        cell.lblOrderType.text = items[curRowIndex].type
        
        if (items[curRowIndex].side == "buy")
        {
            cell.lblProductSide.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        else
        {
            cell.lblProductSide.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        }
        
        cell.lblFilledSize.text = items[curRowIndex].filledSize
        cell.lblAtPrice.text = items[curRowIndex].price
        
        //add the filled fee
        //cell.lblFillFee.text = items[curRowIndex].fillFee
        //cell.sendStrData(inputData: "item \(curRowIndex)")
        
        
        
        //set the delegate action methods to point to this class
        cell.delegate = self
        
        
        return cell
    }
    
    
    //ability to edit rows
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    //delete row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete
        {
            
            
            UiCancelOrderDelegate?.ConfirmCancelOrder(orderDetails: items[indexPath.row], completion: { (returnedBool) in
                //
                
                //if the order cancellation was successfull
                //remove the corresponding row from tableview
                if returnedBool == true
                {
                    //
                    
                    ProductManager.orderOngoing = false
                    
                    DispatchQueue.main.async(execute: { 
                        self.items.remove(at: indexPath.row)
                        
                        self.MyTableView?.beginUpdates()
                        self.MyTableView?.deleteRows(at: [indexPath], with: .automatic)
                        
                        self.MyTableView?.endUpdates()
                    })

                }
            })
            
            
        }
    }
    
 
    func UtcToLocalDate(_ dtString:String) -> String
    {
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        //let date = dateFormatter.date(from: "2015-04-01T11:42:00")// create   date from string
        let date = dateFormatter.date(from: dtString)// create   date from string
        
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateFormatter.timeZone = TimeZone.current; //TimeZone.localTimeZone()
        let timeStamp = dateFormatter.string(from: date!)
        
        return timeStamp;
    }
    
    
    func someAction(passedString: String)
    {
        //        UIAlertAction(title: "some title", style: .default) { (uIAlertAction) in
        //            //
        //        }.
        
        self.logger?.WriteLog(passedString)
    }
    
    
    
    
    
    
    func insertNewRow(inputOrderResponse: OrderResponse)
    {
        items.append(inputOrderResponse)
        
        let indexPath = IndexPath(row: items.count - 1, section: 0)
     

        self.MyTableView?.beginUpdates()
        
        //multiple rows can be added with multiple indexPaths passed in as array
        self.MyTableView?.insertRows(at: [indexPath], with: .automatic)
        
        self.MyTableView?.endUpdates()


        
    }
    
    
    func insertBatchRow(inputOrderResponse: [OrderResponse])
    {
        
        var indexPaths:[IndexPath] = []
        
        for curResponse in inputOrderResponse
        {
            items.append(curResponse)
            
            let curIndexPath = IndexPath(row: items.count - 1, section: 0)
            
            indexPaths.append(curIndexPath)
            
        }
        
        
        

        
        DispatchQueue.main.async {
            self.MyTableView?.beginUpdates()
            
            //multiple rows can be added with multiple indexPaths passed in as array
            self.MyTableView?.insertRows(at: indexPaths, with: .automatic)
            
            self.MyTableView?.endUpdates()
        }

        
        
        
    }
    
    
    
    
    func clearData()
    {
        items.removeAll()
    }
    


    
    func deleteRow(inputOrderId: String)
    {
        //item is found delete 
        
        if let itemIndex = items.index(where: { (item) -> Bool in
            item.orderId == inputOrderId
        }){
            
            
            items.remove(at: itemIndex)
            
            
            let indexPath = IndexPath(row: itemIndex, section: 0)
            
            MyTableView?.beginUpdates()
            
            //multiple rows can be added with multiple indexPaths passed in as array
            MyTableView?.deleteRows(at: [indexPath], with: .automatic)
            
            MyTableView?.endUpdates()
            
        }
        
        
        if inputOrderId == "UNKNOWN" && items.count > 0
        {
            //remove the first item: assuming
            
            //remove the first element 
            items.remove(at: (0))
            
            
            let indexPath = IndexPath(row: (0), section: 0)
            
            MyTableView?.beginUpdates()
            
            //multiple rows can be added with multiple indexPaths passed in as array
            MyTableView?.deleteRows(at: [indexPath], with: .automatic)
            
            MyTableView?.endUpdates()
        }
        
        

        
    }
    
    
}
