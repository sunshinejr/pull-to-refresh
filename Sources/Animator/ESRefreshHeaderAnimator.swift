//
//  ESRefreshHeaderView.swift
//
//  Created by egg swift on 16/4/7.
//  Copyright (c) 2013-2016 ESPullToRefresh (https://github.com/eggswift/pull-to-refresh)
//  Icon from http://www.iconfont.cn
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import QuartzCore
import UIKit

public class ESRefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol, ESRefreshImpactProtocol {
    public var pullToRefreshDescription = NSLocalizedString("Pull to refresh", comment: "") {
        didSet {
            if pullToRefreshDescription != oldValue {
                titleLabel.text = pullToRefreshDescription;
            }
        }
    }
    public var releaseToRefreshDescription = NSLocalizedString("Release to refresh", comment: "")
    public var loadingDescription = NSLocalizedString("Loading...", comment: "")

    public var view: UIView { return self }
    public var insets: UIEdgeInsets = UIEdgeInsetsZero
    public var trigger: CGFloat = 60.0
    public var executeIncremental: CGFloat = 60.0
    public var state: ESRefreshViewState = .pullToRefresh

    private let imageView: UIImageView = {
        let imageView = UIImageView.init()
        if /* Carthage */ let bundle = NSBundle.init(identifier: "com.eggswift.ESPullToRefresh") {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow", inBundle: bundle, compatibleWithTraitCollection: nil)
        } else if /* CocoaPods */ let bundle = NSBundle.init(identifier: "org.cocoapods.ESPullToRefresh") {
            imageView.image = UIImage(named: "ESPullToRefresh.bundle/icon_pull_to_refresh_arrow", inBundle: bundle, compatibleWithTraitCollection: nil)
        } else /* Manual */ {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow")
        }
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFontOfSize( 14.0)
        label.textColor = UIColor.init(white: 0.625, alpha: 1.0)
        label.textAlignment = .Left
        return label
    }()
    
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        indicatorView.hidden = true
        return indicatorView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = pullToRefreshDescription
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(indicatorView)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        indicatorView.hidden = false
        imageView.hidden = true
        titleLabel.text = loadingDescription
        imageView.transform = CGAffineTransformMakeRotation(0.000001 - CGFloat(M_PI))
    }
  
    public func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        indicatorView.hidden = true
        imageView.hidden = false
        titleLabel.text = pullToRefreshDescription
        imageView.transform = CGAffineTransformIdentity
    }
    
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        // Do nothing
        
    }
    
    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .refreshing, .autoRefreshing:
            titleLabel.text = loadingDescription
            self.setNeedsLayout()
            break
        case .releaseToRefresh:
            titleLabel.text = releaseToRefreshDescription
            self.setNeedsLayout()
            self.impact()
            UIView.animateWithDuration( 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                [weak self] in
                self?.imageView.transform = CGAffineTransformMakeRotation(0.000001 - CGFloat(M_PI))
            }) { (animated) in }
            break
        case .pullToRefresh:
            titleLabel.text = pullToRefreshDescription
            self.setNeedsLayout()
            UIView.animateWithDuration( 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                [weak self] in
                self?.imageView.transform = CGAffineTransformIdentity
            }) { (animated) in }
            break
        default:
            break
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let s = self.bounds.size
        let w = s.width
        let h = s.height
        
        UIView.performWithoutAnimation {
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint.init(x: w / 2.0, y: h / 2.0)
            indicatorView.center = CGPoint.init(x: titleLabel.frame.origin.x - 16.0, y: h / 2.0)
            imageView.frame = CGRect.init(x: titleLabel.frame.origin.x - 28.0, y: (h - 18.0) / 2.0, width: 18.0, height: 18.0)
        }
    }
    
}
