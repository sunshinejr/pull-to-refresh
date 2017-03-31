//
//  ESPullToRefresh+Manager.swift
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

public class ESRefreshDataManager {
    
    static let sharedManager = ESRefreshDataManager.init()
    
    static let lastRefreshKey: String = "com.espulltorefresh.lastRefreshKey"
    static let expiredTimeIntervalKey: String = "com.espulltorefresh.expiredTimeIntervalKey"
    public var lastRefreshInfo = [String: NSDate]()
    public var expiredTimeIntervalInfo = [String: Double]()
    
    public required init() {
        
        if let lastRefreshInfo = NSUserDefaults.standardUserDefaults().dictionaryForKey( ESRefreshDataManager.lastRefreshKey) as? [String: NSDate] {
            self.lastRefreshInfo = lastRefreshInfo
        }
        if let expiredTimeIntervalInfo = NSUserDefaults.standardUserDefaults().dictionaryForKey( ESRefreshDataManager.expiredTimeIntervalKey) as? [String: Double] {
            self.expiredTimeIntervalInfo = expiredTimeIntervalInfo
        }
    }
    
    public func date(forKey key: String) -> NSDate? {
        let date = lastRefreshInfo[key]
        return date
    }
    
    public func setDate(_ date: NSDate?, forKey key: String) {
        lastRefreshInfo[key] = date
        NSUserDefaults.standardUserDefaults().setObject(lastRefreshInfo, forKey: ESRefreshDataManager.lastRefreshKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func expiredTimeInterval(forKey key: String) -> Double? {
        let interval = expiredTimeIntervalInfo[key]
        return interval
    }
    
    public func setExpiredTimeInterval(_ interval: Double?, forKey key: String) {
        expiredTimeIntervalInfo[key] = interval
        NSUserDefaults.standardUserDefaults().setObject(expiredTimeIntervalInfo, forKey: ESRefreshDataManager.expiredTimeIntervalKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func isExpired(forKey key: String) -> Bool {
        guard let date = date(forKey: key) else {
            return true
        }
        guard let interval = expiredTimeInterval(forKey: key) else {
            return false
        }
        if date.timeIntervalSinceNow < -interval {
            return true // Expired
        }
        return false
    }
    
    public func isExpired(forKey key: String, block: ((Bool) -> ())?) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            [weak self] in
            guard let weakSelf = self else {
                return
            }
            let result = weakSelf.isExpired(forKey: key)
            let queue = dispatch_get_main_queue()
            dispatch_async(queue) {
                block?(result)
            }
        }
    }
    
    public static func clearAll() {
        self.clearLastRefreshInfo()
        self.clearExpiredTimeIntervalInfo()
    }
    
    public static func clearLastRefreshInfo() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: ESRefreshDataManager.lastRefreshKey)
    }
    
    public static func clearExpiredTimeIntervalInfo() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: ESRefreshDataManager.expiredTimeIntervalKey)
    }
    
}
