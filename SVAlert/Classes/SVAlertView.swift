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
    func showButtons(btns: [(title: String, callback: Void -> Void)]) {
        populateButtons(btns)
    }

    func buttonTapped(btn: UIButton) {
        var tap: (Void->Void)! = nil
        for b in buttonsArr {
            if b.btn.tag == btn.tag {
                tap = b.tapCallback
                break
            }
        }
        tap?()
        buttonTapCallback?()
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

    var buttonTapCallback: (Void -> Void)! = nil

    // MARK: - Private static properties
    static let ButtonHeight: CGFloat = 50.0

    // MARK: - Private properties
    private var buttonsArr: [(btn: UIButton, tapCallback: Void -> Void)]! = []

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
    private func populateButtons(btns: [(title: String, callback: Void -> Void)]) {
        viewBtnsHolder.subviews.forEach { $0.removeFromSuperview() }
        buttonsArr.removeAll()
        var index = 0
        for btnToBeAdded in btns {
            let btn = UIButton(type: .Custom)
            btn.frame = CGRectMake(0.0, 0.0, 44.0, 44.0)
            btn.setTitle(btnToBeAdded.title, forState: .Normal)
            btn.addTarget(self, action: #selector(buttonTapped), forControlEvents: .TouchUpInside)
            btn.tag = index
            btn.setTitleColor(UIColor(red: CGFloat(5.0/255.0), green: CGFloat(133.0/255.0), blue: 1.0, alpha: 1.0), forState: .Normal)
            index += 1
            btn.translatesAutoresizingMaskIntoConstraints = false
            buttonsArr.append(btn: btn, tapCallback: btnToBeAdded.callback)
            viewBtnsHolder.addSubview(btn)
        }
        guard buttonsArr.count > 0 else {
            constrButtonsHolderHeight.constant = 0.0
            return
        }
        constrButtonsHolderHeight.constant = buttonsArr.count > 2 ? CGFloat(buttonsArr.count) * SVAlertView.ButtonHeight : SVAlertView.ButtonHeight
        viewBtnsHolder.addConstraints(constraintsForButtons())

    }

    private func constraintsForButtons() -> [NSLayoutConstraint] {
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

    private func constraintsForOnlyOneButton(btn: UIButton) -> [NSLayoutConstraint] {
        let dict = ["btn" : btn]
        var arr = NSLayoutConstraint.visual("V:|-0-[btn]-0-|", views: dict)
        arr.appendContentsOf(NSLayoutConstraint.visual("H:|-0-[btn]-0-|", views: dict))
        return arr
    }

    private func constraintsForTwoButtons(button1 b1: UIButton, button2 b2: UIButton) -> [NSLayoutConstraint] {
        let dict = ["b1" : b1, "b2" : b2]
        let opts = NSLayoutFormatOptions(rawValue: 0)
        var arr = NSLayoutConstraint.visual("V:|-0-[b1]-0-|", views: dict)
        arr.appendContentsOf(NSLayoutConstraint.visual("V:|-0-[b2]-0-|", views: dict))
        arr.appendContentsOf(NSLayoutConstraint.visual("H:|-0-[b1]", views: dict))
        arr.appendContentsOf(NSLayoutConstraint.visual("H:[b2]-0-|", views: dict))
        arr.appendContentsOf(NSLayoutConstraint.visual("H:[b1]-0-[b2]", views: dict))
        arr.append(NSLayoutConstraint(item: b1, attribute: .Width, relatedBy: .Equal, toItem: b2, attribute: .Width, multiplier: 1.0, constant: b1.frame.size.width))
        return arr
    }

    private func constraintsForThreeOrMoreButtons(buttons: [UIButton]) -> [NSLayoutConstraint] {
        var arr: [NSLayoutConstraint] = []
        var index = 0
        let height = SVAlertView.ButtonHeight
        for b in buttons {
            arr.appendContentsOf(NSLayoutConstraint.visual("H:|-0-[btn]-0-|", views: ["btn" : b]))
            if index == 0 {
                arr.appendContentsOf(NSLayoutConstraint.visual("V:|-0-[btn(\(height))]", views: ["btn" : b]))
            } else {
                arr.appendContentsOf(NSLayoutConstraint.visual("V:[prevBtn]-0-[btn(\(height))]", views: ["prevBtn" : buttons[index-1], "btn" : b]))
            }
            index += 1
        }
        return arr
    }
}

extension NSLayoutConstraint {
    class func visual(format: String, views: [String : AnyObject]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views)
    }
}

