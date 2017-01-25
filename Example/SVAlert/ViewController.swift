//
//  ViewController.swift
//  SVAlert
//
//  Created by Stanislav Vlaev on 08/18/2016.
//  Copyright (c) 2016 Stanislav Vlaev. All rights reserved.
//

import UIKit
import SVAlert

class ViewController: UIViewController {
    @IBAction func actionShowAlert(_ sender: AnyObject) {
        SVAlert.Appearance.showHideAnimation = .fadeInOut
        let alert = SVAlert(title: "Test title", subtitle: "Test\nsubtitle\nwith\nmany\nrows")
        alert.addButton("Ok") {
            print("Ok tapped")
        }
        alert.addButton("Cancel") {
            print("Cancel tapped")
        }
        alert.showFrom(self.view)
    }
}

