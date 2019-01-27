//
//  HistoryViewController.swift
//  Gdax1
//
//  Created by Mohammed on 12/9/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    var CurrentProduct:String?
    
    var fillsList:[OrderResponse] = []
    
    @IBOutlet weak var lblProdName: UILabel!
    

    
    @IBOutlet weak var buySellTableView: UITableView!
    
    
    //@IBOutlet weak var sellTableView: UITableView!
    
    
    
    @IBAction func btnGoBack(_ sender: Any)
    {
        
        //performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
        //_ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        

        // Do any additional setup after loading the view.
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        lblProdName.text = CurrentProduct
        
        
        
        let tableViewUpdater = UiUpdater(tableView: self.buySellTableView)
        
        tableViewUpdater.insertBatchRow(inputOrderResponse: self.fillsList)
        
//        DispatchQueue.main.async {
//            
//            
//            let tableViewUpdater = UiUpdater(tableView: self.buySellTableView)
//            
//            //let selltableViewUpdater = UiUpdater(tableView: self.sellTableView)
//            //sellTableView
//            
//            
//            tableViewUpdater.insertBatchRow(inputOrderResponse: self.fillsList)
//            
////            if self.fillsList.count > 0
////            {
////                tableViewUpdater.clearData() //prepare for next run
////                
////                for curFill in self.fillsList
////                {
////                    
////                    tableViewUpdater.insertNewRow(inputOrderResponse: curFill)
////                    
//////                    if curFill.side == "buy"
//////                    {
//////                        tableViewUpdater.insertNewRow(inputOrderResponse: curFill)
//////                        print(curFill.orderId)
//////                    }
//////                    
//////                    if curFill.side == "sell"
//////                    {
//////                        selltableViewUpdater.insertNewRow(inputOrderResponse: curFill)
//////                        print(curFill.orderId)
//////                    }
////                }
////                
////                
////                
////            }
//
//            
//        }


    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
