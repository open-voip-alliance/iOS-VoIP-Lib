//
//  LoggingDelegate.swift
//  iOSVoIPLib
//
//  Created by Chris Kontos on 21/04/2021.
//

import Foundation

public protocol LoggingDelegate: AnyObject {
    func onLinphoneLog(message: String)
    func onVoIPLibLog(message: String)
}

// Optional protocol methods 
extension LoggingDelegate {
    func onLinphoneLog(message: String){}
    func onVoIPLibLog(message: String){}
}
