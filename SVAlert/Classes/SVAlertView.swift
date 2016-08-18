//
//  ViewController.swift
//  SVAlertView
//
//  Created by Stanislav Vlaev on 08/18/2016.
//  Copyright (c) 2016 Stanislav Vlaev. All rights reserved.
//

extension SVAlertView {
    // MARK: - Static methods
    class func defaultAlertView() -> SVAlertView {
        let alert = SVAlertView()
        return alert
    }

    // MARK: - Public methods

}

class SVAlertView: UIView {
    // MARK: - Public properties
    var title: String! = nil {
        didSet {

        }
    }

    // MARK: - Initializer
    convenience init () {
        self.init(frame: CGRectMake(0.0, 0.0, 200.0, 200.0))
    }

    // MARK: - Private static properties

    // MARK: - Private properties
    var lblTitle: UILabel! = nil
    var lblSubtitle: UILabel! = nil
}

extension SVAlertView {
    // MARK: - Private methods
}