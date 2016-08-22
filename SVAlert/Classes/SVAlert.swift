//
//  ViewController.swift
//  SVAlert
//
//  Created by Stanislav Vlaev on 08/18/2016.
//  Copyright (c) 2016 Stanislav Vlaev. All rights reserved.
//

import UIKit
import pop

public enum ShowHideAnimation {
    // Uses fade animation for the alert
    case FadeInOut
    // Drops the alert from the top of the screen to the center and moves it up when it's being hidden
    case DropDown
}

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
    // MARK: - Public static properties
    static let MaxWidth: CGFloat = 350

    // MARK: - Private properties
    private var windowView: UIWindow! = nil
    private var dimmerView: UIView! = nil
    private var alertView: SVAlertView! = nil
    private var parentView: UIView! = nil

    private var title: String! = nil
    private var subtitle: String! = nil
    private var buttons: [(title: String, callback: Void -> Void)]! = []

    // MARK: - Outlets
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

    // MARK: - Appearance
    public struct Appearance {
        public static var showHideAnimation: ShowHideAnimation = .DropDown
        public static var springBounciness: CGFloat = 10.0
        public static var animationDuration: Double = 0.3
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
        alertView.layer.opacity = 0.0
        parentView?.addSubview(alertView)
        if parentView != nil {
            addAlertConstraints()
        }
    }

    private func showWithAnimations() {
        var alertAnimation: POPPropertyAnimation! = nil
        switch Appearance.showHideAnimation {
            case .DropDown:
                alertView.layer.opacity = 1.0
                alertAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                alertAnimation.toValue = 0.0
                (alertAnimation as! POPSpringAnimation).springBounciness = Appearance.springBounciness
            case .FadeInOut:
                constrCenterAlertVertically.constant = 0.0
                alertAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                alertAnimation.toValue = 1.0
                (alertAnimation as! POPBasicAnimation).duration = Appearance.animationDuration
        }
        let dimmerShowAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        dimmerShowAnimation.toValue = 0.3
        dimmerShowAnimation.duration = Appearance.animationDuration
        switch Appearance.showHideAnimation {
            case .DropDown:
                constrCenterAlertVertically.pop_addAnimation(alertAnimation, forKey: AnimationTitles.AlertViewShow)
            case .FadeInOut:
                alertView.layer.pop_addAnimation(alertAnimation, forKey: AnimationTitles.AlertViewShow)
        }
        dimmerView.layer.pop_addAnimation(dimmerShowAnimation, forKey: AnimationTitles.DimmerViewOpacity)
    }

    private func hideWithAminations() {
        var alertAnimation: POPPropertyAnimation! = nil
        switch Appearance.showHideAnimation {
        case .DropDown:
            alertView.layer.opacity = 1.0
            alertAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            alertAnimation.toValue = -dimmerView.frame.size.height
            (alertAnimation as! POPBasicAnimation).duration = Appearance.animationDuration
        case .FadeInOut:
            alertAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            alertAnimation.toValue = 0.0
            (alertAnimation as! POPBasicAnimation).duration = Appearance.animationDuration
        }
        let dimmerHideAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        dimmerHideAnimation.toValue = 0.0
        dimmerHideAnimation.duration = 0.3
        dimmerHideAnimation.completionBlock = { animation, finished in
            if finished {
                self.removeFromViewHierarchy()
            }
        }
        switch Appearance.showHideAnimation {
            case .DropDown:
                constrCenterAlertVertically.pop_addAnimation(alertAnimation, forKey: AnimationTitles.AlertViewHide)
            case .FadeInOut:
                alertView.layer.pop_addAnimation(alertAnimation, forKey: AnimationTitles.AlertViewHide)
        }
        dimmerView.layer.pop_addAnimation(dimmerHideAnimation, forKey: AnimationTitles.DimmerViewOpacity)
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
        let w = min(self.frame.size.width * 0.9, SVAlert.MaxWidth)
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
