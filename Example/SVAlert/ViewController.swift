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
    @IBAction func actionShowAlert(sender: AnyObject) {
        let alert = SVAlert(title: "Test title", subtitle: "bla")
        alert.addButton("B1") {
            print("B1 tap")
        }
        alert.addButton("B2") {
            print("B2 tap")
        }
        alert.showFrom(self.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        actionShowAlert(UIButton())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
