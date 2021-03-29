//
//  LogManager.swift
//  iOSVoIPLib_Example
//
//  Created by Chris Kontos on 26/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import iOSVoIPLib

class LogManager: LoggingDelegate {
    
    let voipLib = VoIPLib.shared
    let log = NSMutableAttributedString(string: "")
    
    var loggingViewDelegate: LoggingViewDelegate?
    
    init() {
        voipLib.loggingDelegate = self
    }
    
    func updateLog(newMessage: NSAttributedString) {
        DispatchQueue.main.async {
            self.log.append(newMessage)
            self.loggingViewDelegate?.onUpdate(log: self.log)
        }
    }
    
    // MARK: LoggingDelegate
    
    func onLinphoneLog(message:String){
        let formattedMessage = formatLogMessage(message: " Linphone: " + message + "\n\n")
        updateLog(newMessage: formattedMessage)
    }

    func onVoIPLibLog(message: String) {
        let formattedMessage = formatLogMessage(message: " VoIPLib: " + message + "\n\n")
        updateLog(newMessage: formattedMessage)
    }

    // MARK: Formatting message

    private func formatLogMessage(message: String) -> NSAttributedString{
        let boldText = currentTime()
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

        let normalText = NSMutableAttributedString(string: message)

        attributedString.append(normalText)
        
        return attributedString
    }

    private func currentTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "HH:mm:ss.SSS"
        let time = formatter.string(from: date)

        return time
    }
}
