//
//  BaseManagerProtocol.swift
//  linphone-sdk
//
//  Created by Fabian Giger on 22/07/2020.
//

import Foundation

public typealias RegistrationCallback = (RegistrationState) -> Void

protocol SipManagerProtocol: AnyObject {    
    var isMicrophoneMuted:Bool { get }
    var isSpeakerOn:Bool { get }
    var isRegistered:Bool {get}
    var isInitialized: Bool { get }

    func initialize(config: Config) -> Bool
    func register(callback: @escaping RegistrationCallback) -> Bool
    func unregister(finished:@escaping() -> ())
    func destroy()
    func call(to number: String) -> Session?
    func acceptCall(for session: Session) -> Bool
    func endCall(for session: Session) -> Bool

    func setMicrophone(muted:Bool)
    func setSpeaker(_ speaker:Bool) -> Bool
    func setAudio(enabled:Bool)
    
    func setHold(session:Session, onHold hold:Bool) -> Bool
    func transfer(session: Session, to number: String) -> Bool

    func swapConfig(config: Config)
    func beginAttendedTransfer(session: Session, to number:String) -> AttendedTransferSession?
    func finishAttendedTransfer(attendedTransferSession: AttendedTransferSession) -> Bool
    
    func sendDtmf(session:Session, dtmf: String)
}
