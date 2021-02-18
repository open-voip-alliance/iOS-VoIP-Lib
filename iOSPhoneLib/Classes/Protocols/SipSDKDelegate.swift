//
//  SipSDKDelegate.swift
//  PhoneLib
//
//  Created by Fabian Giger on 02/07/2020.
//

import Foundation

protocol SipSDKDelegate: CallDelegate {
    func getActiveSessions() -> [Session]
}
