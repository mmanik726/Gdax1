//
//  ViewControllerTableViewCell.swift
//  Gdax1
//
//  Created by Mohammed on 12/6/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import UIKit



protocol CellButtonActionDelegate {
    
    func someAction(passedString: String)
}

class ViewControllerTableViewCell: UITableViewCell {


    
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    
    
    @IBOutlet weak var lblProductName: UILabel!
    
    @IBOutlet weak var lblProductSize: UILabel!
    
    @IBOutlet weak var lblProductSide: UILabel!
    
    
    @IBOutlet weak var lblOrderType: UILabel!
    
    

    @IBOutlet weak var lblFilledSize: UILabel!
    
    
    @IBOutlet weak var lblAtPrice: UILabel!
    
    
    
    var delegate: CellButtonActionDelegate?
    
    var curStrData:OrderResponse?
    
    func sendStrData(inputData: OrderResponse)
    {
        curStrData = inputData
    }
    
    
    @IBAction func TestAction(_ sender: Any)
    {
        //delegate?.someAction(passedString: curStrData!)
        
    }
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
