//
//  SettingsViewController.swift
//  Gdax1
//
//  Created by Mohammed on 12/10/17.
//  Copyright © 2017 Manik. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var lblApiKey: UITextField!
    
    @IBOutlet weak var lblUserName: UITextField!
    
    @IBOutlet weak var lblPassPhrase: UITextField!
    
    @IBOutlet weak var lblSecret: UITextField!
    
    
    @IBOutlet weak var lblSaveUpdate: UIButton!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
