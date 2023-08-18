//
//  InitialViewController.swift
//  FinalProject
//
//  Created by HuangSai on 2022-08-16.
//  Copyright © 2022 EirianTa. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    var selectedRowIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = "You've just clicked on row " + String(selectedRowIndex)

    }
}

