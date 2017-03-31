//
//  GCDHelper.swift
//  ESPullToRefreshExample
//
//  Created by Lukasz Mroz on 31.03.2017.
//  Copyright © 2017 egg swift. All rights reserved.
//

import Foundation

final class Dispatch {
    
    static func after(delay: Double, block: Void -> Void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            block()
        }
    }
}
