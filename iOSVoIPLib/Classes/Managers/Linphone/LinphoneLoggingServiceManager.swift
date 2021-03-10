//
//  LinphoneLoggingServiceManager.swift
//  linphone-sdk
//
//  Created by Fabian Giger on 09/07/2020.
//

import linphonesw

class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        print("Log: \(message)")
    }
}
