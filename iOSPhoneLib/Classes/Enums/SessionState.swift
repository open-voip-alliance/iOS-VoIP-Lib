//
//  SessionState.swift
//  PhoneLib
//
//  Created by Fabian Giger on 02/07/2020.
//

import Foundation

///LinphoneCallState enum represents the different states a call can reach into.
public enum SessionState:Int {
    /// Initial state.
    case idle = 0
    /// Incoming call received.
    case incomingReceived = 1
    /// Outgoing call initialized.
    case outgoingDidInitialize = 2
    /// Outgoing call in progress.
    case outgoingProgress = 3
    /// Outgoing call ringing.
    case outgoingRinging = 4
    /// Outgoing call early media.
    case outgoingEarlyMedia = 5
    /// Connected.
    case connected = 6
    /// Streams running.
    case streamsRunning = 7
    /// Pausing.
    case pausing = 8
    /// Paused.
    case paused = 9
    /// Resuming.
    case resuming = 10
    /// Referred.
    case referred = 11
    /// Error.
    case error = 12
    /// Call end.
    case ended = 13
    /// Paused by remote.
    case pausedByRemote = 14
    /// The call's parameters are updated for example when video is asked by remote.
    case updatedByRemote = 15
    /// We are proposing early media to an incoming call.
    case incomingEarlyMedia = 16
    /// We have initiated a call update.
    case updating = 17
    /// The call object is now released.
    case released = 18
    /// The call is updated by remote while not yet answered (SIP UPDATE in early
    /// dialog received)
    case earlyUpdatedByRemote = 19
    /// We are updating the call while not yet answered (SIP UPDATE in early dialog
    /// sent)
    case earlyUpdating = 20
}
