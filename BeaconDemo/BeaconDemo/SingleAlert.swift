//
//  SingleAlert.swift
//  BeaconDemo
//
//  Created by wata on 2015/10/06.
//  Copyright © 2015年 wataru. All rights reserved.
//

import Foundation


class SingleAlert {
    
    class var sharedInstance : SingleAlert {
        struct Static {
            static let instance : SingleAlert = SingleAlert()
        }
        return Static.instance
    }
    
    var alertFlg: Bool = false
    
}
