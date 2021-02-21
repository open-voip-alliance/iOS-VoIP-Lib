//
//  SIPManager.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

class SipManager: NSObject, SipManagerProtocol {
    
    weak var registrationDelegate:RegistrationStateDelegate?
    weak var sessionDelegate:CallDelegate?
    
    public var sipRegistrationStatus:SipRegistrationStatus {
        sipSdkManager.sipRegistrationStatus
    }
    
    var isMicrophoneMuted:Bool {
        sipSdkManager.isMicrophoneMuted
    }
    var isSpeakerOn: Bool {
        sipSdkManager.isSpeakerOn
    }
    
    let sipSdkManager:SipSdkProtocol
    
    private var activeSessions = [Session]()
    
    init(sipSdkManager:SipSdkProtocol) {
        self.sipSdkManager = sipSdkManager
        super.init()
        self.sipSdkManager.registrationDelegate = self
        self.sipSdkManager.sessionDelegate = self
    }

    func initialize(config: Config) -> Bool {
        sipSdkManager.initialize(config: config)
    }
    
    func register() -> Bool {
        sipSdkManager.register()
    }
    
    func unregister(finished:@escaping() -> ()) {
        sipSdkManager.unregister(finished: finished)
    }
    
    func call(to number: String) -> Session? {
        return sipSdkManager.call(to: number)
    }
    
    func acceptCall(for session: Session) -> Bool {
        return sipSdkManager.acceptCall(for: session)
    }
    
    func endCall(for session: Session) -> Bool {
        return sipSdkManager.endCall(for: session)
    }
    
    func setAudioCodecs(_ codecs: [Codec]) {
        sipSdkManager.setAudioCodecs(codecs)
    }
    
    func resetAudioCodecs() {
        sipSdkManager.resetAudioCodecs()
    }
    
    func setMicrophone(muted: Bool) {
        sipSdkManager.setMicrophone(muted: muted)
    }
    
    func setSpeaker(_ speaker: Bool) -> Bool {
        return sipSdkManager.setSpeaker(speaker)
    }
    
    func setAudio(enabled:Bool) {
        sipSdkManager.setAudio(enabled: enabled)
    }
    
    func setHold(session: Session, onHold hold: Bool) -> Bool {
        return sipSdkManager.setHold(session: session, onHold: hold)
    }
    
    func transfer(session: Session, to number: String) -> Bool {
        return sipSdkManager.transfer(session: session, to: number)
    }
    
    func beginAttendedTransfer(session: Session, to number:String) -> AttendedTransferSession? {
        return sipSdkManager.beginAttendedTransfer(session:session, to:number)
    }
    
    func finishAttendedTransfer(attendedTransferSession: AttendedTransferSession) -> Bool {
        return sipSdkManager.finishAttendedTransfer(attendedTransferSession: attendedTransferSession)
    }
    
    func sendDtmf(session:Session, dtmf: String) {
        sipSdkManager.sendDtmf(session:session, dtmf:dtmf)
    }
    
    func setUserAgent(_ userAgent:String, version:String?) {
        sipSdkManager.setUserAgent(userAgent, version: version)
    }
    
    func setStun(enabled:Bool, server:String?, stunServerUserName:String?) {
        sipSdkManager.setStun(enabled: enabled, server: server, stunServerUserName: stunServerUserName)
    }
    
    fileprivate func findSession(for session:Session) -> Session? {
        return activeSessions.first(where: { $0 == session })
    }
    
}

extension SipManager: RegistrationStateDelegate {
    func didChangeRegisterState(_ state: SipRegistrationStatus, message:String?) {
        registrationDelegate?.didChangeRegisterState(state, message: message)
    }
}

extension SipManager: SipSDKDelegate {
    func getActiveSessions() -> [Session] {
        return activeSessions
    }
    
    func sessionUpdated(_ session: Session, message: String) {
        sessionDelegate?.sessionUpdated(session, message: message)
    }
    
    func didReceive(incomingSession: Session) {
        activeSessions.append(incomingSession)
        sessionDelegate?.didReceive(incomingSession: incomingSession)
    }
    
    func outgoingDidInitialize(session: Session) {
        activeSessions.append(session)
        sessionDelegate?.outgoingDidInitialize(session: session)
    }
    
    func sessionConnected(_ session: Session) {
        guard let session = findSession(for: session) else { return }
        sessionDelegate?.sessionConnected(session)
    }
    
    func sessionEnded(_ session: Session) {
        sessionDelegate?.sessionEnded(session)
    }
    
    func sessionReleased(_ session: Session) {
        activeSessions.removeAll(where: { $0 == session })
        sessionDelegate?.sessionReleased(session)
    }
    
    func error(session:Session, message: String) {
        sessionDelegate?.error(session: session, message: message)
    }
    
    
}
