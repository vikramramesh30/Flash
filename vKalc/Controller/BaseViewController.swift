//
//  BaseViewController.swift
//  vKalc
//
//  Created by cis on 29/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
}
