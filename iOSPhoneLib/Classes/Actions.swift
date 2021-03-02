//
//  Actions.swift
//  iOSPhoneLib
//
//  Created by Jeremy Norman on 02/03/2021.
//

import Foundation

public class Actions {
    
    let sipManager: SipManagerProtocol
    let call: Session
    
    init(sipManager: SipManagerProtocol, call: Session) {
        self.sipManager = sipManager
        self.call = call
    }
    
    /// Accept an incoming call
    ///
    /// - Parameters:
    ///     - session: The accepting session
    /// - Returns: `Bool` Whether accepting went successfully
    public func accept() -> Bool {
        sipManager.acceptCall(for: call)
    }
    
    /// End an call.
    ///
    /// - Parameters:
    ///     - session: The accepting session
    /// - Returns: `Bool` Whether ending went successfully
    public func end() -> Bool {
        sipManager.endCall(for: call)
    }
    
    /// Turn on/off the speaker.
    /// This function uses AVAudioSession to override the `Output Audio Port`. It also sets the `category` to `PlayAndRecord` and `mode` to `VoiceChat`.
    ///
    /// - Parameters:
    ///     - speaker: The new state of the speaker.
    /// - Returns: `Bool` Whether the change was successful.
    public func setSpeaker(_ speaker:Bool) -> Bool {
        return sipManager.setSpeaker(speaker)
    }
    
    /// Enable/disable the audio session.
    /// This is a `CallKit` support function. Which must be called by the `CXProviderDelegate` on `didActivate` and `didDeactivate`.
    ///
    /// - Parameters:
    ///     - enabled: State of audio
    public func setAudio(enabled:Bool) {
        sipManager.setAudio(enabled: enabled)
    }
    
    /// Set a session on (un)hold
    ///
    /// - Parameters:
    ///     - session: The session
    ///     - onHold: The new hold state
    /// - Returns: `Bool` Whether the change was successful.
    public func hold(onHold hold:Bool) -> Bool {
        sipManager.setHold(session: call, onHold: hold)
    }
    
    /// Transfer a call. This is unattended.
    ///
    /// - Parameters:
    ///     - session: The active session
    ///     - number: Transfer to number
    /// - Returns: `Bool` Whether the transfer was successful.
    public func transfer(to number:String) -> Bool {
        sipManager.transfer(session: call, to: number)
    }
    
    /// Begin process of attended transfer by calling the transfer target's number.
    ///
    /// - Parameters:
    ///     - session: The active session
    ///     - number: The transfer target's number
    /// - Returns: `AttendedTransferSession` The struct with the two sessions.
    public func beginAttendedTransfer(to number:String) -> AttendedTransferSession? {
        sipManager.beginAttendedTransfer(session: call, to:number)
    }
    
    /// Finish process of attended transfer by merging the calls.
    ///
    /// - Parameter:
    ///     - attendedTransferSession: The struct with the two sessions.
    /// - Returns: `Bool` Whether the transfer was successful.
    public func finishAttendedTransfer(attendedTransferSession:AttendedTransferSession) -> Bool {
        sipManager.finishAttendedTransfer(attendedTransferSession:attendedTransferSession)
    }
    
    /// Send Dtmf.
    ///
    /// - Parameter:
    ///     - session: The session with the active call.
    ///     - dtmf: The string with the dtmf digits.
    public func sendDtmf(dtmf: String) {
        sipManager.sendDtmf(session: call, dtmf: dtmf)
    }
}
