//
//  ESPullToRefresh.swift
//
//  Created by egg swift on 16/4/7.
//  Copyright (c) 2013-2016 ESPullToRefresh (https://github.com/eggswift/pull-to-refresh)
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
import UIKit

private var kESRefreshHeaderKey: String = ""
private var kESRefreshFooterKey: String = ""

public extension UIScrollView {
    
    /// Pull-to-refresh associated property
    public var es_header: ESRefreshHeaderView? {
        get { return (objc_getAssociatedObject(self, &kESRefreshHeaderKey) as? ESRefreshHeaderView) }
        set(newValue) { objc_setAssociatedObject(self, &kESRefreshHeaderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// Infinitiy scroll associated property
    public var es_footer: ESRefreshFooterView? {
        get { return (objc_getAssociatedObject(self, &kESRefreshFooterKey) as? ESRefreshFooterView) }
        set(newValue) { objc_setAssociatedObject(self, &kESRefreshFooterKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) }
    }
    
    /// Add pull-to-refresh
    public func es_addPullToRefresh(handler: ESRefreshHandler) -> ESRefreshHeaderView {
        es_removeRefreshHeader()
        let header = ESRefreshHeaderView(frame: CGRect.zero, handler: handler)
        let headerH = header.animator.executeIncremental
        header.frame = CGRect.init(x: 0.0, y: -headerH /* - contentInset.top */, width: bounds.size.width, height: headerH)
        addSubview(header)
        es_header = header
        return header
    }
    
    public func es_addPullToRefresh(animator: protocol<ESRefreshProtocol, ESRefreshAnimatorProtocol>, handler: ESRefreshHandler) -> ESRefreshHeaderView {
        es_removeRefreshHeader()
        let header = ESRefreshHeaderView(frame: CGRect.zero, handler: handler, animator: animator)
        let headerH = animator.executeIncremental
        header.frame = CGRect.init(x: 0.0, y: -headerH /* - contentInset.top */, width: bounds.size.width, height: headerH)
        addSubview(header)
        es_header = header
        return header
    }
    
    /// Add infinite-scrolling
    public func es_addInfiniteScrolling(handler: ESRefreshHandler) -> ESRefreshFooterView {
        es_removeRefreshFooter()
        let footer = ESRefreshFooterView(frame: CGRect.zero, handler: handler)
        let footerH = footer.animator.executeIncremental
        footer.frame = CGRect.init(x: 0.0, y: contentSize.height + contentInset.bottom, width: bounds.size.width, height: footerH)
        addSubview(footer)
        es_footer = footer
        return footer
    }

    public func es_addInfiniteScrolling(animator: protocol<ESRefreshProtocol, ESRefreshAnimatorProtocol>, handler: ESRefreshHandler) -> ESRefreshFooterView {
        es_removeRefreshFooter()
        let footer = ESRefreshFooterView(frame: CGRect.zero, handler: handler, animator: animator)
        let footerH = footer.animator.executeIncremental
        footer.frame = CGRect.init(x: 0.0, y: contentSize.height + contentInset.bottom, width: bounds.size.width, height: footerH)
        es_footer = footer
        addSubview(footer)
        return footer
    }
    
    /// Remove
    public func es_removeRefreshHeader() {
        es_header?.stopRefreshing()
        es_header?.removeFromSuperview()
        es_header = nil
    }
    
    public func es_removeRefreshFooter() {
        es_footer?.stopRefreshing()
        es_footer?.removeFromSuperview()
        es_footer = nil
    }
    
    /// Manual refresh
    public func es_startPullToRefresh() {
        let queue = dispatch_get_main_queue()
        dispatch_async(queue) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.es_header?.startRefreshing(false)
        }
    }
    
    /// Auto refresh if expired.
    public func es_autoPullToRefresh() {
        if self.expired == true {
            let queue = dispatch_get_main_queue()
            dispatch_async(queue) { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.es_header?.startRefreshing(true)
            }
        }
    }
    
    /// Stop pull to refresh
    public func es_stopPullToRefresh(ignoreDate: Bool = false, ignoreFooter: Bool = false) {
        es_header?.stopRefreshing()
        if ignoreDate == false {
            if let key = es_header?.refreshIdentifier {
                ESRefreshDataManager.sharedManager.setDate(NSDate(), forKey: key)
            }
            es_footer?.resetNoMoreData()
        }
        es_footer?.hidden = ignoreFooter
    }
    
    /// Footer notice method
    public func  es_noticeNoMoreData() {
        es_footer?.stopRefreshing()
        es_footer?.noMoreData = true
    }
    
    public func es_resetNoMoreData() {
        es_footer?.noMoreData = false
    }
    
    public func es_stopLoadingMore() {
        es_footer?.stopRefreshing()
    }
    
}

public extension UIScrollView /* NSDate Manager */ {
    
    /// Identifier for cache expired timeinterval and last refresh date.
    public var refreshIdentifier: String? {
        get { return self.es_header?.refreshIdentifier }
        set { self.es_header?.refreshIdentifier = newValue }
    }
    
    /// If you setted refreshIdentifier and expiredTimeInterval, return nearest refresh expired or not. Default is false.
    public var expired: Bool {
        get {
            if let key = self.es_header?.refreshIdentifier {
                return ESRefreshDataManager.sharedManager.isExpired(forKey: key)
            }
            return false
        }
    }
    
    public var expiredTimeInterval: Double? {
        get {
            if let key = self.es_header?.refreshIdentifier {
                let interval = ESRefreshDataManager.sharedManager.expiredTimeInterval(forKey: key)
                return interval
            }
            return nil
        }
        set {
            if let key = self.es_header?.refreshIdentifier {
                ESRefreshDataManager.sharedManager.setExpiredTimeInterval(newValue, forKey: key)
            }
        }
    }
    
    /// Auto cached last refresh date when you setted refreshIdentifier.
    public var lastRefreshDate: NSDate? {
        get {
            if let key = self.es_header?.refreshIdentifier {
                return ESRefreshDataManager.sharedManager.date(forKey: key)
            }
            return nil
        }
    }
    
}


public class ESRefreshHeaderView: ESRefreshComponent {
    private var previousOffset: CGFloat = 0.0
    private var scrollViewInsets: UIEdgeInsets = UIEdgeInsetsZero
    private var scrollViewBounces: Bool = true

    public var lastRefreshTimestamp: Double?
    public var refreshIdentifier: String?
    
    public convenience init(frame: CGRect, handler: ESRefreshHandler) {
        self.init(frame: frame)
        self.handler = handler
        self.animator = ESRefreshHeaderAnimator.init()
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        /*
         DispatchQueue.main.async {
         [weak self] in
         // It's better
         }
         */
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let queue = dispatch_get_main_queue()
        dispatch_async(queue) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.scrollViewBounces = weakSelf.scrollView?.bounces ?? true
            weakSelf.scrollViewInsets = weakSelf.scrollView?.contentInset ?? UIEdgeInsetsZero
        }
    }
    
    public override func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?) {
        guard let scrollView = scrollView else {
            return
        }
            
        super.offsetChangeAction(object, change: change)
        
        guard self.isRefreshing == false && self.isAutoRefreshing == false else {
            let top = scrollViewInsets.top
            let offsetY = scrollView.contentOffset.y
            let height = self.frame.size.height
            var scrollingTop = (-offsetY > top) ? -offsetY : top
            scrollingTop = (scrollingTop > height + top) ? (height + top) : scrollingTop
            
            scrollView.contentInset.top = scrollingTop
            
            return
        }
        
        // Check needs re-set animator's progress or not.
        var isRecordingProgress = false
        defer {
            if isRecordingProgress == true {
                let percent = -(previousOffset + scrollViewInsets.top) / self.animator.trigger
                self.animator.refresh(self, progressDidChange: percent)
            }
        }
        
        let offsets = previousOffset + scrollViewInsets.top
        if offsets < -self.animator.trigger {
            // Reached critical
            if isRefreshing == false && isAutoRefreshing == false {
                if scrollView.dragging == false {
                    // Start to refresh...
                    self.startRefreshing(false)
                    self.animator.refresh(self, stateDidChange: .refreshing)
                } else {
                    // Release to refresh! Please drop down hard...
                    self.animator.refresh(self, stateDidChange: .releaseToRefresh)
                    isRecordingProgress = true
                }
            }
        } else if offsets < 0 {
            // Pull to refresh!
            if isRefreshing == false && isAutoRefreshing == false {
                self.animator.refresh(self, stateDidChange: .pullToRefresh)
                isRecordingProgress = true
            }
        } else {
            // Normal state
        }
        
        previousOffset = scrollView.contentOffset.y
        
    }
    
    public override func start() {
        guard let scrollView = scrollView else {
            return
        }
        
        // ignore observer
        self.ignoreObserver(true)
        
        // stop scroll view bounces for animation
        scrollView.bounces = false
        
        // call super start
        super.start()
        
        self.animator.refreshAnimationBegin(self)
        
        // 缓存scrollview当前的contentInset, 并根据animator的executeIncremental属性计算刷新时所需要的contentInset，它将在接下来的动画中应用。
        // Tips: 这里将self.scrollViewInsets.top更新，也可以将scrollViewInsets整个更新，因为left、right、bottom属性都没有用到，如果接下来的迭代需要使用这三个属性的话，这里可能需要额外的处理。
        var insets = scrollView.contentInset
        self.scrollViewInsets.top = insets.top
        insets.top += animator.executeIncremental
        
        // We need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then.
        scrollView.contentOffset.y = previousOffset
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset.y = -insets.top
        }, completion: { (finished) in
            self.handler?()
            // un-ignore observer
            self.ignoreObserver(false)
            scrollView.bounces = self.scrollViewBounces
        })
        
    }
    
    public override func stop() {
        guard let scrollView = scrollView else {
            return
        }
        
        // ignore observer
        self.ignoreObserver(true)
        
        self.animator.refreshAnimationEnd(self)
        
        // Back state
        UIView.animateWithDuration( 0.2, delay: 0, options: .CurveLinear, animations: {
            scrollView.contentInset.top = self.scrollViewInsets.top
            }, completion: { (finished) in
                self.animator.refresh(self, stateDidChange: .pullToRefresh)
                super.stop()
                scrollView.contentInset.top = self.scrollViewInsets.top
                // un-ignore observer
                self.ignoreObserver(false)
        })
    }
    
}

public class ESRefreshFooterView: ESRefreshComponent {
    private var scrollViewInsets: UIEdgeInsets = UIEdgeInsetsZero
    public var noMoreData = false {
        didSet {
            if noMoreData != oldValue {
                self.animator.refresh(self, stateDidChange: noMoreData ? .noMoreData : .pullToRefresh)
            }
        }
    }
    
    public override var hidden: Bool {
        didSet {
            if hidden == true {
                scrollView?.contentInset.bottom = scrollViewInsets.bottom
                var rect = self.frame
                rect.origin.y = scrollView?.contentSize.height ?? 0.0
                self.frame = rect
            } else {
                scrollView?.contentInset.bottom = scrollViewInsets.bottom + animator.executeIncremental
                var rect = self.frame
                rect.origin.y = scrollView?.contentSize.height ?? 0.0
                self.frame = rect
            }
        }
    }
    
    public convenience init(frame: CGRect, handler: ESRefreshHandler) {
        self.init(frame: frame)
        self.handler = handler
        self.animator = ESRefreshFooterAnimator.init()
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        /*
         DispatchQueue.main.async {
         [weak self] in
         // It's better
         }
         */
    }
    
    /**
      In didMoveToSuperview, it will cache superview(UIScrollView)'s contentInset and update self's frame.
      It called ESRefreshComponent's didMoveToSuperview.
     */
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let queue = dispatch_get_main_queue()
        dispatch_async(queue) {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.scrollViewInsets = weakSelf.scrollView?.contentInset ?? UIEdgeInsetsZero
            weakSelf.scrollView?.contentInset.bottom = weakSelf.scrollViewInsets.bottom + weakSelf.bounds.size.height
            var rect = weakSelf.frame
            rect.origin.y = weakSelf.scrollView?.contentSize.height ?? 0.0
            weakSelf.frame = rect
        }
    }
 
    public override func sizeChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?) {
        guard let scrollView = scrollView else { return }
        super.sizeChangeAction(object, change: change)
        let targetY = scrollView.contentSize.height + scrollViewInsets.bottom
        if self.frame.origin.y != targetY {
            var rect = self.frame
            rect.origin.y = targetY
            self.frame = rect
        }
    }
    
    public override func offsetChangeAction(object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?) {
        guard let scrollView = scrollView else {
            return
        }
        
        super.offsetChangeAction(object, change: change)
        
        guard isRefreshing == false && isAutoRefreshing == false && noMoreData == false && hidden == false else {
            // 正在loading more或者内容为空时不相应变化
            return
        }

        if scrollView.contentSize.height <= 0.0 || scrollView.contentOffset.y + scrollView.contentInset.top <= 0.0 {
            self.alpha = 0.0
            return
        } else {
            self.alpha = 1.0
        }
        
        if scrollView.contentSize.height + scrollView.contentInset.top > scrollView.bounds.size.height {
            // 内容超过一个屏幕 计算公式，判断是不是在拖在到了底部
            if scrollView.contentSize.height - scrollView.contentOffset.y + scrollView.contentInset.bottom  <= scrollView.bounds.size.height {
                self.animator.refresh(self, stateDidChange: .refreshing)
                self.startRefreshing()
            }
        } else {
            //内容没有超过一个屏幕，这时拖拽高度大于1/2footer的高度就表示请求上拉
            if scrollView.contentOffset.y + scrollView.contentInset.top >= animator.trigger / 2.0 {
                self.animator.refresh(self, stateDidChange: .refreshing)
                self.startRefreshing()
            }
        }
    }
    
    public override func start() {
        guard let scrollView = scrollView else {
            return
        }
        super.start()
        
        self.animator.refreshAnimationBegin(self)
        
        let x = scrollView.contentOffset.x
        let y = max(0.0, scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        
        // Call handler
        UIView.animateWithDuration( 0.3, delay: 0.0, options: .CurveLinear, animations: {
            scrollView.contentOffset = CGPoint.init(x: x, y: y)
        }, completion: { (animated) in
            self.handler?()
        })
    }
    
    public override func stop() {
        guard let scrollView = scrollView else {
            return
        }
        
        self.animator.refreshAnimationEnd(self)
        
        // Back state
        UIView.animateWithDuration( 0.3, delay: 0, options: .CurveLinear, animations: {
        }, completion: { (finished) in
            if self.noMoreData == false {
                self.animator.refresh(self, stateDidChange: .pullToRefresh)
            }
            super.stop()
        })

        // Stop deceleration of UIScrollView. When the button tap event is caught, you read what the [scrollView contentOffset].x is, and set the offset to this value with animation OFF.
        // http://stackoverflow.com/questions/2037892/stop-deceleration-of-uiscrollview
        if scrollView.decelerating {
            var contentOffset = scrollView.contentOffset
            contentOffset.y = min(contentOffset.y, scrollView.contentSize.height - scrollView.frame.size.height)
            if contentOffset.y < 0.0 {
                contentOffset.y = 0.0
                UIView.animateWithDuration( 0.1, animations: { 
                    scrollView.setContentOffset(contentOffset, animated: false)
                })
            } else {
                scrollView.setContentOffset(contentOffset, animated: false)
            }
        }
        
    }
    
    /// Change to no-more-data status.
    public func noticeNoMoreData() {
        self.noMoreData = true
    }
    
    /// Reset no-more-data status.
    public func resetNoMoreData() {
        self.noMoreData = false
    }
    
}

