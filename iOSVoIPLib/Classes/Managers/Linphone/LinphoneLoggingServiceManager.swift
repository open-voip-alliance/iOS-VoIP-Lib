//
//  LinphoneLoggingServiceManager.swift
//  linphone-sdk
//
//  Created by Fabian Giger on 09/07/2020.
//

import linphonesw

class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    
    weak var loggingDelegate: LoggingDelegate?
    
    func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        print("Linphone: \(message)")
        loggingDelegate?.onLinphoneLog(message: message)
    }
}

