//
//  ViewController.swift
//  CollectionContainerView
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePreferredContentSizeIfNeeded()
    }
}

class ViewController2: ViewController{
    
}

