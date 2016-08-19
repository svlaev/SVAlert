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
    // MARK: - Static methods

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

    }
}

public class SVAlert: UIView {
    // MARK: - Public properties

    // MARK: - Private static properties
    static let MaxWidth: CGFloat = 350

    // MARK: - Private properties
    private var windowView: UIWindow! = nil
    private var dimmerView: UIView! = nil
    private var alertView: SVAlertView! = nil
    private var parentView: UIView! = nil

    private var title: String! = nil
    private var subtitle: String! = nil
    private var buttons: [(title: String, callback: Void -> Void)]! = []


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

    private func getProperViewRect() -> CGRect {
        return UIScreen.mainScreen().bounds
    }

    private func initializeDimmerView() {
        if dimmerView == nil {
            dimmerView = UIView(frame: getProperViewRect())
            dimmerView.backgroundColor = UIColor.blackColor()
            dimmerView.layer.opacity = 0.0
        } else {
            dimmerView.removeFromSuperview()
        }
        parentView?.addSubview(dimmerView)
    }

    private func initializeAlertView() {
        if alertView == nil {
            alertView = SVAlertView.defaultAlertView()
        } else {
            alertView.removeFromSuperview()
        }
        alertView.title = title
        alertView.subtitle = subtitle
        var f = alertView.frame
        f.size.width = min(self.frame.size.width, SVAlert.MaxWidth)
        alertView.frame = f
        var p = dimmerView.center
        p.y = -p.y
        alertView.center = p
        parentView?.addSubview(alertView)
    }

    private func showWithAnimations() {
        let springAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        springAnimation.toValue = dimmerView.center.y
        springAnimation.springBounciness = 10.0

        let dimmerShowAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        dimmerShowAnimation.toValue = 0.3
        alertView.layer.pop_addAnimation(springAnimation, forKey: AnimationTitles.AlertViewShow)
        dimmerView.layer.pop_addAnimation(dimmerShowAnimation, forKey: AnimationTitles.DimmerViewOpacity)
    }
}

struct AnimationTitles {
    static let DimmerViewOpacity = "dimmmerViewOpacity"
    static let AlertViewShow = "alertViewShow"
}
