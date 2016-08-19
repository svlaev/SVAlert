//
//  ViewController.swift
//  SVAlert
//
//  Created by Stanislav Vlaev on 08/18/2016.
//  Copyright (c) 2016 Stanislav Vlaev. All rights reserved.
//

import UIKit
import pop

extension SVAlert {
    // MARK: - Public methods
    public func addButton(title: String, tap: Void -> Void) {
        buttons.append(title: title, callback: tap)
    }

    public func showFrom(parent: UIView){
        parentView = parent
        initializeDimmerView()
        initializeAlertView()
        alertView.showButtons(buttons)
        showWithAnimations()
    }

    public func hide() {
        hideWithAminations()
    }
}

public class SVAlert: UIView {
    // MARK: - Private static properties
    static let MaxWidth: CGFloat = 320

    // MARK: - Private properties
    private var windowView: UIWindow! = nil
    private var dimmerView: UIView! = nil
    private var alertView: SVAlertView! = nil
    private var parentView: UIView! = nil

    private var title: String! = nil
    private var subtitle: String! = nil
    private var buttons: [(title: String, callback: Void -> Void)]! = []

    @IBOutlet weak var constrCenterAlertVertically: NSLayoutConstraint!

    // MARK: - Initializer
    public convenience init(title: String, subtitle: String? = nil) {
        self.init(frame: CGRectZero)
        self.title = title
        self.subtitle = subtitle
        windowView = getWindow()
        frame = windowView.bounds
        initializeDimmerView()
        initializeAlertView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SVAlert {
    // MARK: - Private methods
    private func getWindow() -> UIWindow! {
        guard windowView == nil else { return windowView }
        var w = UIApplication.sharedApplication().keyWindow
        if w == nil {
            w = UIApplication.sharedApplication().windows.first
        }
        return w
    }

    private func screenRect() -> CGRect {
        return UIScreen.mainScreen().bounds
    }

    private func initializeDimmerView() {
        if dimmerView == nil {
            dimmerView = UIView(frame: CGRectZero)
            dimmerView.backgroundColor = UIColor.blackColor()
            dimmerView.layer.opacity = 0.0
        } else {
            dimmerView.removeFromSuperview()
        }
        parentView?.addSubview(dimmerView)
        if parentView != nil {
            dimmerView.frame = parentView.bounds
            addDimmerViewConstraints()
        }
    }

    private func initializeAlertView() {
        if alertView == nil {
            alertView = SVAlertView.defaultAlertView()
        } else {
            alertView.removeFromSuperview()
        }
        alertView.title = title
        alertView.subtitle = subtitle
        alertView.buttonTapCallback = {
            self.hide()
        }
        parentView?.addSubview(alertView)
        if parentView != nil {
            addAlertConstraints()
        }
    }

    private func showWithAnimations() {
        let springAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
        springAnimation.toValue = 0.0
        springAnimation.springBounciness = 10.0

        let dimmerShowAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        dimmerShowAnimation.toValue = 0.3
        dimmerShowAnimation.duration = 0.3
        constrCenterAlertVertically.pop_addAnimation(springAnimation, forKey: AnimationTitles.AlertViewShow)
        dimmerView.layer.pop_addAnimation(dimmerShowAnimation, forKey: AnimationTitles.DimmerViewOpacity)
    }

    private func hideWithAminations() {
        let hideAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant )
        hideAnimation.toValue = -dimmerView.frame.size.height
        hideAnimation.duration = 0.3
        let fadeAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.3
        hideAnimation.completionBlock = { animation, finished in
            if finished {
                self.removeFromViewHierarchy()
            }
        }
        constrCenterAlertVertically.pop_addAnimation(hideAnimation, forKey: AnimationTitles.AlertViewHide)
        dimmerView.layer.pop_addAnimation(fadeAnimation, forKey: AnimationTitles.DimmerViewOpacity)
    }

    private func removeFromViewHierarchy() {
        dimmerView?.removeFromSuperview()
        dimmerView = nil
        alertView?.removeFromSuperview()
        alertView = nil
        self.removeFromSuperview()
    }

    private func addAlertConstraints() {
        var arr: [NSLayoutConstraint] = []
        alertView.translatesAutoresizingMaskIntoConstraints = false
        arr.append(NSLayoutConstraint(item: alertView,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0.0))
        constrCenterAlertVertically = NSLayoutConstraint(item: alertView,
                                                         attribute: .CenterY,
                                                         relatedBy: .Equal,
                                                         toItem: parentView,
                                                         attribute: .CenterY,
                                                         multiplier: 1.0,
                                                         constant: -screenRect().size.height)
        arr.append(constrCenterAlertVertically)
        let w = min(self.frame.size.width, SVAlert.MaxWidth)
        alertView.addConstraints(NSLayoutConstraint.visual("H:[alert(\(w))]", views: ["alert" : alertView]))
        parentView.addConstraints(arr)
    }

    private func addDimmerViewConstraints() {
        var arr: [NSLayoutConstraint] = []
        let dict = ["v" : dimmerView]
        arr.appendContentsOf(NSLayoutConstraint.visual("H:|-0-[v]-0-|", views: dict))
        arr.appendContentsOf(NSLayoutConstraint.visual("V:|-0-[v]-0-|", views: dict))
        parentView.addConstraints(arr)
    }
}

struct AnimationTitles {
    static let DimmerViewOpacity = "dimmmerViewOpacity"
    static let AlertViewShow = "alertViewShow"
    static let AlertViewHide = "alertViewHide"
}
