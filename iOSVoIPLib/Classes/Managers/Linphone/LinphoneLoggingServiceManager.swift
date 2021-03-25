//
//  LinphoneLoggingServiceManager.swift
//  linphone-sdk
//
//  Created by Fabian Giger on 09/07/2020.
//

import linphonesw

class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        let queue = DispatchQueue(label: "com.iOSVoIPLib.logging", qos: .background)
        queue.async {
            print("Log: \(message)")
        }
    }
}
