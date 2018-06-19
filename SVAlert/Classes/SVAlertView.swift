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
        return Bundle(for: self.classForCoder()).loadNibNamed("SVAlertView", owner: nil, options: nil)!.first as! SVAlertView
    }

    // MARK: - Public methods
    func showButtons(_ btns: [(title: String, callback: () -> Void)]) {
        populateButtons(btns)
    }

    @objc func buttonTapped(_ btn: UIButton) {
        var tap: (()->Void)! = nil
        for b in buttonsArr {
            if b.btn.tag == btn.tag {
                tap = b.tapCallback
                break
            }
        }
        tap?()
        buttonTapCallback?()
    }

    func desiredHeight() -> CGFloat {
        return viewBtnsHolder.frame.maxY
    }
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
            constrSubtitleTopMargin.constant = lblSubtitle?.text != nil ? constrTitleTopMargin.constant : 0.0
        }
    }

    var buttonTapCallback: (() -> Void)! = nil

    // MARK: - Private static properties
    static let ButtonHeight: CGFloat = 50.0

    // MARK: - Private properties
    fileprivate var buttonsArr: [(btn: UIButton, tapCallback: () -> Void)]! = []

    // MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var viewBtnsHolder: UIView!
    @IBOutlet weak var constrTitleTopMargin: NSLayoutConstraint!
    @IBOutlet weak var constrSubtitleTopMargin: NSLayoutConstraint!
    @IBOutlet weak var constrButtonsHolderHeight: NSLayoutConstraint!
}

extension SVAlertView {
    // MARK: - Private methods
    fileprivate func populateButtons(_ btns: [(title: String, callback: () -> Void)]) {
        viewBtnsHolder.subviews.forEach { $0.removeFromSuperview() }
        buttonsArr.removeAll()
        var index = 0
        for btnToBeAdded in btns {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
            btn.setTitle(btnToBeAdded.title, for: UIControlState())
            btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            btn.tag = index
            btn.setTitleColor(UIColor(red: CGFloat(5.0/255.0), green: CGFloat(133.0/255.0), blue: 1.0, alpha: 1.0), for: UIControlState())
            index += 1
            btn.translatesAutoresizingMaskIntoConstraints = false
            buttonsArr.append((btn: btn, tapCallback: btnToBeAdded.callback))
            viewBtnsHolder.addSubview(btn)
        }
        guard buttonsArr.count > 0 else {
            constrButtonsHolderHeight.constant = 0.0
            return
        }
        constrButtonsHolderHeight.constant = buttonsArr.count > 2 ? CGFloat(buttonsArr.count) * SVAlertView.ButtonHeight : SVAlertView.ButtonHeight
        viewBtnsHolder.addConstraints(constraintsForButtons())

    }

    fileprivate func constraintsForButtons() -> [NSLayoutConstraint] {
        switch buttonsArr.count {
            case 1:
                return constraintsForOnlyOneButton(buttonsArr.first!.btn)
            case 2:
                return constraintsForTwoButtons(button1: buttonsArr.first!.btn, button2: buttonsArr.last!.btn)
            case 3..<Int.max:
                return constraintsForThreeOrMoreButtons(buttonsArr.map { $0.btn })
            default: return []
        }
    }

    fileprivate func constraintsForOnlyOneButton(_ btn: UIButton) -> [NSLayoutConstraint] {
        let dict = ["btn" : btn]
        var arr = NSLayoutConstraint.visual("V:|-0-[btn]-0-|", views: dict)
        arr.append(contentsOf: NSLayoutConstraint.visual("H:|-0-[btn]-0-|", views: dict))
        return arr
    }

    fileprivate func constraintsForTwoButtons(button1 b1: UIButton, button2 b2: UIButton) -> [NSLayoutConstraint] {
        let dict = ["b1" : b1, "b2" : b2]
        var arr = NSLayoutConstraint.visual("V:|-0-[b1]-0-|", views: dict)
        arr.append(contentsOf: NSLayoutConstraint.visual("V:|-0-[b2]-0-|", views: dict))
        arr.append(contentsOf: NSLayoutConstraint.visual("H:|-0-[b1]", views: dict))
        arr.append(contentsOf: NSLayoutConstraint.visual("H:[b2]-0-|", views: dict))
        arr.append(contentsOf: NSLayoutConstraint.visual("H:[b1]-0-[b2]", views: dict))
        arr.append(NSLayoutConstraint(item: b1, attribute: .width, relatedBy: .equal, toItem: b2, attribute: .width, multiplier: 1.0, constant: b1.frame.size.width))
        return arr
    }

    fileprivate func constraintsForThreeOrMoreButtons(_ buttons: [UIButton]) -> [NSLayoutConstraint] {
        var arr: [NSLayoutConstraint] = []
        var index = 0
        let height = SVAlertView.ButtonHeight
        for b in buttons {
            arr.append(contentsOf: NSLayoutConstraint.visual("H:|-0-[btn]-0-|", views: ["btn" : b]))
            if index == 0 {
                arr.append(contentsOf: NSLayoutConstraint.visual("V:|-0-[btn(\(height))]", views: ["btn" : b]))
            } else {
                arr.append(contentsOf: NSLayoutConstraint.visual("V:[prevBtn]-0-[btn(\(height))]", views: ["prevBtn" : buttons[index-1], "btn" : b]))
            }
            index += 1
        }
        return arr
    }
}

extension NSLayoutConstraint {
    class func visual(_ format: String, views: [String : Any]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views)
    }
}

