//
//  SpindleSIPFramework.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

public class PhoneLib {
    
    static public let shared = PhoneLib()

    public var isRegistered: Bool {
        get { sipManager.isRegistered }
    }

    public var isInitialized: Bool {
        get { sipManager.isInitialized }
    }

    public var isReady: Bool {
        get { isRegistered && isInitialized }
    }

    ///For retrieving registration state change callbacks
    public weak var registrationDelegate:RegistrationStateDelegate?
        
    public var isMicrophoneMuted:Bool {
        sipManager.isMicrophoneMuted
    }
    
    public var isSpeakerOn:Bool {
        sipManager.isSpeakerOn
    }
    
    let sipManager: SipManagerProtocol
    
    init() {
        sipManager = LinphoneManager()
    }
    
    public func initialize(config: Config) {
        sipManager.initialize(config: config)
    }
    
    /// This `registers` your user on SIP. You need this before placing a call.
    /// - Returns: Bool containing register result
    public func register() -> Bool {
        sipManager.register { state in
            
        }
    }

    public func destroy() {
        sipManager.destroy()
    }
    
    /// This `unregisters` your user on SIP.
    ///
    /// - Parameters:
    ///     - finished: Called async when unregistering is done.
    public func unregister(finished:@escaping() -> ()) {
        sipManager.unregister(finished: finished)
    }
    
    /// Call a phone number
    ///
    /// - Parameters:
    ///     - number: The phone number to call
    /// - Returns: `Session?`  The session or nil if the call has not been successful
    public func call(to number: String) -> Session? {
        return sipManager.call(to: number)
    }
    
    /// Accept an incoming call
    ///
    /// - Parameters:
    ///     - session: The accepting session
    /// - Returns: `Bool` Whether accepting went successfully
    public func acceptCall(for session: Session) -> Bool {
        return sipManager.acceptCall(for: session)
    }
    
    /// End an call.
    ///
    /// - Parameters:
    ///     - session: The accepting session
    /// - Returns: `Bool` Whether ending went successfully
    public func endCall(for session: Session) -> Bool {
        return sipManager.endCall(for: session)
    }
    
    /// Set Audio Codecs (Payloads).
    ///
    /// - Parameters:
    ///     - codecs: Array of codecs which need to be enabled. Codec is an enum
    public func setAudioCodecs(_ codecs:[Codec]) {
        sipManager.setAudioCodecs(codecs)
    }
    
    /// Reset Audio codecs to initial state. Enables all codecs from the `Codec` enum.
    public func resetAudioCodecs() {
        sipManager.resetAudioCodecs()
    }
    
    /// Turn on/off the microphone when calling.
    ///
    /// - Parameters:
    ///     - muted: The new state of the microphone.
    public func setMicrophone(muted:Bool) {
        sipManager.setMicrophone(muted: muted)
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
    public func setHold(session:Session, onHold hold:Bool) -> Bool {
        return sipManager.setHold(session: session, onHold: hold)
    }
    
    /// Transfer a call. This is unattended.
    ///
    /// - Parameters:
    ///     - session: The active session
    ///     - number: Transfer to number
    /// - Returns: `Bool` Whether the transfer was successful.
    public func transfer(session:Session, to number:String) -> Bool {
        return sipManager.transfer(session: session, to: number)
    }
    
    /// Begin process of attended transfer by calling the transfer target's number.
    ///
    /// - Parameters:
    ///     - session: The active session
    ///     - number: The transfer target's number
    /// - Returns: `AttendedTransferSession` The struct with the two sessions.
    public func beginAttendedTransfer(session:Session, to number:String) -> AttendedTransferSession? {
        return sipManager.beginAttendedTransfer(session: session, to:number)
    }
    
    /// Finish process of attended transfer by merging the calls.
    ///
    /// - Parameter:
    ///     - attendedTransferSession: The struct with the two sessions.
    /// - Returns: `Bool` Whether the transfer was successful.
    public func finishAttendedTransfer(attendedTransferSession:AttendedTransferSession) -> Bool {
        return sipManager.finishAttendedTransfer(attendedTransferSession:attendedTransferSession)
    }
    
    /// Send Dtmf.
    ///
    /// - Parameter:
    ///     - session: The session with the active call.
    ///     - dtmf: The string with the dtmf digits.
    public func sendDtmf(session:Session, dtmf: String) {
        sipManager.sendDtmf(session: session, dtmf: dtmf)
    }
    
    /// Set the user agent string used in SIP messages.
    /// Set the user agent string used in SIP messages as "[userAgent]/[version]".
    /// No slash character will be printed if nil is given to "version". If nil is given
    /// to "userAgent" and "version" both, the User-agent header will be empty.
    ///
    /// - Parameter userAgent: Name of the user agent.
    /// - Parameter version: Version of the user agent. (optional)
    ///
    public func setUserAgent(_ userAgent:String, version:String?) {
        sipManager.setUserAgent(userAgent, version: version)
    }
    
    public func setStun(enabled:Bool, server:String?, stunServerUserName:String?) {
        sipManager.setStun(enabled: enabled, server: server, stunServerUserName: stunServerUserName)
    }
}

extension PhoneLib: RegistrationStateDelegate {
    public func didChangeRegisterState(_ state: SipRegistrationStatus, message:String?) {
        registrationDelegate?.didChangeRegisterState(state, message: message)
    }
}
