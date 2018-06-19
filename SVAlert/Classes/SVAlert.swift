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
    case fadeInOut
    // Drops the alert from the top of the screen to the center and moves it up when it's being hidden
    case dropDown
}

extension SVAlert {
    // MARK: - Public methods
    public func addButton(_ title: String, tap: @escaping () -> Void) {
        buttons.append((title, tap))
    }

    public func showFrom(_ parent: UIView){
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

open class SVAlert: UIView {
    // MARK: - Public static properties
    static let MaxWidth: CGFloat = 350

    // MARK: - Private properties
    fileprivate var windowView: UIWindow! = nil
    fileprivate var dimmerView: UIView! = nil
    fileprivate var alertView: SVAlertView! = nil
    fileprivate var parentView: UIView! = nil

    fileprivate var title: String! = nil
    fileprivate var subtitle: String! = nil
    fileprivate var buttons: [(title: String, callback: () -> Void)]! = []

    // MARK: - Outlets
    @IBOutlet weak var constrCenterAlertVertically: NSLayoutConstraint!

    // MARK: - Initializer
    public convenience init(title: String, subtitle: String? = nil) {
        self.init(frame: CGRect.zero)
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
        public static var showHideAnimation: ShowHideAnimation = .dropDown
        public static var springBounciness: CGFloat = 10.0
        public static var animationDuration: Double = 0.3
    }
}

extension SVAlert {
    // MARK: - Private methods
    fileprivate func getWindow() -> UIWindow! {
        guard windowView == nil else { return windowView }
        var w = UIApplication.shared.keyWindow
        if w == nil {
            w = UIApplication.shared.windows.first
        }
        return w
    }

    fileprivate func screenRect() -> CGRect {
        return UIScreen.main.bounds
    }

    fileprivate func initializeDimmerView() {
        if dimmerView == nil {
            dimmerView = UIView(frame: CGRect.zero)
            dimmerView.backgroundColor = UIColor.black
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

    fileprivate func initializeAlertView() {
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

    fileprivate func showWithAnimations() {
        var alertAnimation: POPPropertyAnimation! = nil
        switch Appearance.showHideAnimation {
            case .dropDown:
                alertView.layer.opacity = 1.0
                alertAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                alertAnimation.toValue = 0.0
                (alertAnimation as! POPSpringAnimation).springBounciness = Appearance.springBounciness
            case .fadeInOut:
                constrCenterAlertVertically.constant = 0.0
                alertAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
                alertAnimation.toValue = 1.0
                (alertAnimation as! POPBasicAnimation).duration = Appearance.animationDuration
        }
        let dimmerShowAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        dimmerShowAnimation?.toValue = 0.3
        dimmerShowAnimation?.duration = Appearance.animationDuration
        switch Appearance.showHideAnimation {
            case .dropDown:
                constrCenterAlertVertically.pop_add(alertAnimation, forKey: AnimationTitles.AlertViewShow)
            case .fadeInOut:
                alertView.layer.pop_add(alertAnimation, forKey: AnimationTitles.AlertViewShow)
        }
        dimmerView.layer.pop_add(dimmerShowAnimation, forKey: AnimationTitles.DimmerViewOpacity)
    }

    fileprivate func hideWithAminations() {
        var alertAnimation: POPPropertyAnimation! = nil
        switch Appearance.showHideAnimation {
        case .dropDown:
            alertView.layer.opacity = 1.0
            alertAnimation = POPBasicAnimation(propertyNamed: kPOPLayoutConstraintConstant)
            alertAnimation.toValue = -dimmerView.frame.size.height
            (alertAnimation as! POPBasicAnimation).duration = Appearance.animationDuration
        case .fadeInOut:
            alertAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            alertAnimation.toValue = 0.0
            (alertAnimation as! POPBasicAnimation).duration = Appearance.animationDuration
        }
        let dimmerHideAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        dimmerHideAnimation?.toValue = 0.0
        dimmerHideAnimation?.duration = 0.3
        dimmerHideAnimation?.completionBlock = { animation, finished in
            if finished {
                self.removeFromViewHierarchy()
            }
        }
        switch Appearance.showHideAnimation {
            case .dropDown:
                constrCenterAlertVertically.pop_add(alertAnimation, forKey: AnimationTitles.AlertViewHide)
            case .fadeInOut:
                alertView.layer.pop_add(alertAnimation, forKey: AnimationTitles.AlertViewHide)
        }
        dimmerView.layer.pop_add(dimmerHideAnimation, forKey: AnimationTitles.DimmerViewOpacity)
    }

    fileprivate func removeFromViewHierarchy() {
        dimmerView?.removeFromSuperview()
        dimmerView = nil
        alertView?.removeFromSuperview()
        alertView = nil
        self.removeFromSuperview()
    }

    fileprivate func addAlertConstraints() {
        var arr: [NSLayoutConstraint] = []
        alertView.translatesAutoresizingMaskIntoConstraints = false
        arr.append(NSLayoutConstraint(item: alertView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0))
        constrCenterAlertVertically = NSLayoutConstraint(item: alertView,
                                                         attribute: .centerY,
                                                         relatedBy: .equal,
                                                         toItem: parentView,
                                                         attribute: .centerY,
                                                         multiplier: 1.0,
                                                         constant: -screenRect().size.height)
        arr.append(constrCenterAlertVertically)
        let w = min(self.frame.size.width * 0.9, SVAlert.MaxWidth)
        alertView.addConstraints(NSLayoutConstraint.visual("H:[alert(\(w))]", views: ["alert" : alertView]))
        parentView.addConstraints(arr)
    }

    fileprivate func addDimmerViewConstraints() {
        guard dimmerView != nil else { return }
        var arr: [NSLayoutConstraint] = []
        let dict = ["v" : dimmerView!]
        arr.append(contentsOf: NSLayoutConstraint.visual("H:|-0-[v]-0-|", views: dict))
        arr.append(contentsOf: NSLayoutConstraint.visual("V:|-0-[v]-0-|", views: dict))
        parentView.addConstraints(arr)
    }
}

struct AnimationTitles {
    static let DimmerViewOpacity = "dimmmerViewOpacity"
    static let AlertViewShow = "alertViewShow"
    static let AlertViewHide = "alertViewHide"
}
