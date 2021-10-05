//
//  CallDelegate.swift
//  VoIPLib
//
//  Created by Fabian Giger on 02/07/2020.
//

import Foundation

public protocol CallDelegate: AnyObject {
    ///  An incoming call has been received by the library.
    ///
    /// - Parameters:
    ///     - incomingCall: The incoming call
    func incomingCallReceived(_ call: Call)
    
    /// Callback when there's a new outgoing call.
    ///
    /// - Parameters:
    ///     - call: The call
    func outgoingCallCreated(_ call: Call)
    
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
    
    /// Callback when a call has been updated. This is more generic callback. It's only used when there not a state specific callback.
    ///
    /// - Parameters:
    ///     - call: The call
    ///     - message: The message from the server.
    func callUpdated(_ call: Call, message: String)
    
    /// When the call object has been released.
    ///
    /// - Parameters:
    ///     - call: The call
    func callReleased(_ call:Call)
    
    /// An Attended Transfer has completed and the two calls have been merged, this will occur before receiving the ended and released events.
    ///
    /// - Parameters:
    ///     - call: The call
    func attendedTransferMerged(_ call: Call)
}
