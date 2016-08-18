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
        return NSBundle(forClass: self.classForCoder()).loadNibNamed("SVAlertView", owner: nil, options: nil).first as! SVAlertView
    }

    // MARK: - Public methods
}

class SVAlertView: UIView {
    // MARK: - Public properties
    var title: String! = nil {
        didSet {
            lblTitle?.text = title
        }
    }

    var subtitle: String! = nil {
        didSet {
            lblSubtitle?.text = subtitle
        }
    }

    // MARK: - Private static properties
    static let BottomMargin: CGFloat = 15.0

    // MARK: - Private properties

    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var viewBtnsHolder: UIView!
    @IBOutlet weak var constrTitleTopMargin: NSLayoutConstraint!
    @IBOutlet weak var constrSubtitleTopMargin: NSLayoutConstraint!
}

extension SVAlertView {
    // MARK: - Private methods
}