//
//  CallDelegate.swift
//  PhoneLib
//
//  Created by Fabian Giger on 02/07/2020.
//

import Foundation

public protocol CallDelegate: AnyObject {
    /// Callback when there's a new incoming call
    ///
    /// - Parameters:
    ///     - incomingCall: The incoming call
    func didReceive(incomingCall: Call)
    
    /// Callback when there's a new outgoing call.
    ///
    /// - Parameters:
    ///     - call: The call
    func outgoingDidInitialize(call: Call)
    
    /// Callback when a call has been updated. This is more generic callback. It's only used when there not a state specific callback.
    ///
    /// - Parameters:
    ///     - call: The call
    ///     - message: The message from the server.
    func callUpdated(_ call: Call, message: String)
    
    /// Callback when a call is connected.
    ///
    /// - Parameters:
    ///     - call: The call
    func callConnected(_ call: Call)
    
    /// Callback when a call ended.
    ///
    /// - Parameters:
    ///     - call: The call
    func callEnded(_ call: Call)
    
    /// Callback when a call released.
    ///
    /// - Parameters:
    ///     - call: The call
    func callReleased(_ call: Call)
    
    /// Callback when there's an error.
    ///
    /// - Parameters:
    ///     - call: The call
    ///     - message: The message from the server.
    func error(call:Call, message: String)
}
