//
//  SpindleSIPFrameworkDelegate.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Coffee IT on 14/04/2020.
//

import Foundation

public protocol RegistrationStateDelegate: AnyObject {
    /// Callback for registration state changes
    ///
    /// - Parameters:
    ///     - state: The new state
    func didChangeRegisterState(_ state: SipRegistrationStatus, message:String?)
}
