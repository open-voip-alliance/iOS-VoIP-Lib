//
//  SessionDelegate.swift
//  PhoneLib
//
//  Created by Fabian Giger on 02/07/2020.
//

import Foundation

public protocol CallDelegate: AnyObject {
    /// Callback when there's a new incoming call
    ///
    /// - Parameters:
    ///     - incomingSession: The incoming session
    func didReceive(incomingSession: Session)
    
    /// Callback when there's a new outgoing session.
    ///
    /// - Parameters:
    ///     - session: The session
    func outgoingDidInitialize(session: Session)
    
    /// Callback when a session has been updated. This is more generic callback. It's only used when there not a state specific callback.
    ///
    /// - Parameters:
    ///     - session: The session
    ///     - message: The message from the server.
    func sessionUpdated(_ session: Session, message: String)
    
    /// Callback when a session is connected.
    ///
    /// - Parameters:
    ///     - session: The session
    func sessionConnected(_ session: Session)
    
    /// Callback when a session ended.
    ///
    /// - Parameters:
    ///     - session: The session
    func sessionEnded(_ session: Session)
    
    /// Callback when a session released.
    ///
    /// - Parameters:
    ///     - session: The session
    func sessionReleased(_ session: Session)
    
    /// Callback when there's an error.
    ///
    /// - Parameters:
    ///     - session: The session
    ///     - message: The message from the server.
    func error(session:Session, message: String)
}
