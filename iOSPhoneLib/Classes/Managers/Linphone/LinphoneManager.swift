//
//  LinphoneManager.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation
import linphonesw
import AVFoundation

//CallKit: https://wiki.linphone.org/xwiki/wiki/public/view/Lib/Getting%20started/iOS/#HCallKitIntegration

class LinphoneManager:SipSdkProtocol {
    
    weak var sessionDelegate:SipSDKDelegate?
    weak var registrationDelegate:RegistrationStateDelegate?

    private var config: Config?
    var isInitialized: Bool = false
    //Linphone Core
    private var lc: Core!
    private var stateManager:LinphoneStateManager!
    private var proxyConfig: ProxyConfig!
    private let logManager = LinphoneLoggingServiceManager()
    var sipRegistrationStatus: SipRegistrationStatus = SipRegistrationStatus.none
    
    var isMicrophoneMuted: Bool {
        return !lc.micEnabled
    }
    
    var isSpeakerOn: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == AVAudioSessionPortBuiltInSpeaker })
    }
    
    init() {
        lc = try! Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        stateManager = LinphoneStateManager(manager: self)
    }

    func initialize(config: Config) -> Bool {
        self.config = config
        guard !isInitialized else {
            debugPrint("Linphone already init")
            return true
        }
        debugPrint("Linphone init")
        return startLinphone()
    }

    func startLinphone() -> Bool {
        isInitialized = true

        #if DEBUG
        Factory.Instance.enableLogCollection(state: LogCollectionState.Enabled)
        let log = LoggingService.Instance
        log.addDelegate(delegate: logManager)
        log.logLevel = LogLevel.Debug
        #endif
        
        lc.addDelegate(delegate: stateManager)
        lc.adaptiveRateControlEnabled = true
        lc.echoCancellationEnabled = true
        lc.callkitEnabled = true
        
        try? lc.migrateToMultiTransport()
        
        do {
            try lc.start()
        } catch {
            isInitialized = false
            print("Linphone starting failed")
        }
        return isInitialized
    }
    
    private func setTimer() {
        DispatchQueue.global().async {
            while(self.isInitialized){
                self.lc.iterate() // first iterate initiates registration
                usleep(50000)
            }
        }
    }
    
    fileprivate func findSession(for call:Call) -> Session? {
        return sessionDelegate?.getActiveSessions().first(where: { $0.call.remoteAddress != nil && $0.call.remoteAddress?.asString() == call.remoteAddress?.asString() })
    }
    
    private func setupProxy(from:Address, encrypted:Bool) throws {
        // configure proxy entries
        proxyConfig = try lc.createProxyConfig()
        try proxyConfig.setIdentityaddress(newValue: from) // set identity with user name and domain
        let serverAddress = from.domain + (encrypted ? ";transport=tls" : "") // extract domain address from identity
        try proxyConfig.setServeraddr(newValue: serverAddress) // we assume domain = proxy server address
        try proxyConfig.setRoute(newValue: serverAddress)
        proxyConfig.registerEnabled = true // activate registration for this proxy config
        try proxyConfig.done()
        
        try lc.addProxyConfig(config: proxyConfig!) // add proxy config to linphone core
        lc.defaultProxyConfig = proxyConfig // set to default proxy
    }
    
    //MARK: - SipSdkProtocol
    func register() -> Bool {
        let factory = Factory.Instance
        do {
            guard let config = self.config else {
                throw InitializationError.noConfigurationProvided
            }
            
            let identity = "sip:" + config.auth.name + "@" + config.auth.domain + ":\(config.auth.port)"
            let from = try factory.createAddress(addr: identity)
            try from.setTransport(newValue: config.encryption ? .Tls : .Udp)
            
            if config.encryption, let transports:Transports = lc.transports {
                from.secure = true //Force calling via TLS
                transports.tlsPort = config.auth.port
                transports.udpPort = config.auth.port
                transports.tcpPort = config.auth.port
                try lc.setTransports(newValue: transports)
                try lc.setMediaencryption(newValue: MediaEncryption.SRTP)
                lc.mediaEncryptionMandatory = true
            }
            
            try setupProxy(from: from, encrypted: config.encryption)
            
            let info = try factory.createAuthInfo(username: from.username, userid: "", passwd: config.auth.password, ha1: "", realm: "", domain: "") // create authentication structure from identity
            lc.addAuthInfo(info: info) // add authentication arianinfo to LinphoneCore
            
            lc.useRfc2833ForDtmf = true
            lc.ipv6Enabled = true
            setTimer()
            print("Linphone successfully registering")
        } catch (let error) {
            print("Linphone registering identify error: \(error)")
            return false
        }
        return true
    }
    
    func unregister(finished:@escaping() -> ()) {
        DispatchQueue.global().async {
            guard self.isInitialized else {
                DispatchQueue.main.async {
                    finished()
                }
                return
            }
            print("Linphone unregistering")
            for config in self.lc.proxyConfigList {
                config.edit() // start editing proxy configuration
                config.registerEnabled = false // de-activate registration for this proxy config
                do {
                    try config.done()
                } catch {
                    print("Linphone unregistering error on proxy: \(error)")
                } // initiate REGISTER with expire = 0
            }
            self.isInitialized = false
            
            while(self.lc.proxyConfigList.contains(where: { $0.state != RegistrationState.Cleared } )) {
                self.lc.iterate() // to make sure we receive call backs before shutting down
                usleep(50000)
            }
            self.lc.proxyConfigList.forEach( { self.lc.removeProxyConfig(config: $0) } )
            self.lc.removeDelegate(delegate: self.stateManager)
            self.lc.stop()
            print("Linphone unregistered")
            DispatchQueue.main.async {
                finished()
            }
        }
    }
    
    func call(to number: String) -> Session? {
        guard let call = lc.invite(url: number) else {return nil}
        let session = Session.init(call: call)
        return isInitialized ? session : nil
    }
    
    func acceptCall(for session: Session) -> Bool {
        do {
            try session.call.accept()
            return true
        } catch {
            return false
        }
    }
    
    func endCall(for session: Session) -> Bool {
        do {
            try session.call.terminate()
            return true
        } catch {
            return false
        }
    }
    
    internal func setAudioCodecs(_ codecs: [Codec]) {
        var disabledPayloads = lc.audioPayloadTypes

        for codec in Codec.allCases {
            disabledPayloads.removeAll(where: { $0.mimeType.uppercased() == codec.rawValue.uppercased() })
            let enabled = codecs.contains(codec)
            guard let payload = lc.getPayloadType(type: codec.rawValue, rate: -1, channels: -1) else { continue }
            print("Enable result \(payload.mimeType): \(payload.enable(enabled: enabled) == 0)")
            
        }
        disabledPayloads.forEach( {
            print("Disabling result \($0.mimeType): \($0.enable(enabled: false) == 0)")
        })
    }
    
    func resetAudioCodecs() {
        setAudioCodecs(Codec.allCases)
    }
    
    func setMicrophone(muted: Bool) {
        lc.micEnabled = !muted
    }
    
    func setSpeaker(_ speaker: Bool) -> Bool {
        do {
//            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .voiceChat)
//            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.voiceChat)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(speaker ? .speaker : .none)
            try AVAudioSession.sharedInstance().setActive(true)
            print("AVAudioSession Category playAndRecord OK")
            return true
        } catch {
            print("Soundmanager setCategory error: \(error.localizedDescription)")
            return false
        }
    }
    
    func setAudio(enabled:Bool) {
        debugPrint("Linphone set audio: \(enabled)")
        lc.activateAudioSession(actived: enabled)
    }
    
    func setHold(session:Session, onHold hold:Bool) -> Bool {
        do {
            if hold {
                print("Pausing session.")
                try session.pause()
            } else {
                print("Resuming session.")
                try session.resume()
            }
            return true
        } catch {
            return false
        }
    }
    
    func transfer(session: Session, to number: String) -> Bool {
        do {
            try session.call.transfer(referTo: number)
            print("Transfer was successful")
            return true
        } catch (let error) {
            print("Transfer failed: \(error)")
            return false
        }
    }
    
    func beginAttendedTransfer(session: Session, to number:String) -> AttendedTransferSession? {        
        guard let destinationSession = call(to: number) else {
            print("Unable to make call for target session")
            return nil
        }
        
        return AttendedTransferSession(from: session, to: destinationSession)
    }
    
    func finishAttendedTransfer(attendedTransferSession: AttendedTransferSession) -> Bool {
        do {
            try attendedTransferSession.from.call.transferToAnother(dest: attendedTransferSession.to.call)
            print("Transfer was successful")
            return true
        } catch (let error) {
            print("Transfer failed: \(error)")
            return false
        }
    }
    
    func sendDtmf(session:Session, dtmf: String) {
        if dtmf.count == 1 {
            do {
                let dtmfDigit = dtmf.utf8CString[0]
                try session.call.sendDtmf(dtmf: dtmfDigit)
            } catch (let error) {
                print("Sending dtmf failed: \(error)")
            }
        } else {
            do {
                try session.call.sendDtmfs(dtmfs: dtmf)
            } catch (let error) {
                print("Sending dtmfs failed: \(error)")
            }
        }
    }
    
    func setUserAgent(_ userAgent:String, version:String?) {
        lc.setUserAgent(uaName: userAgent, version: version ?? "")
    }
    
    func setStun(enabled:Bool, server:String?, stunServerUserName:String?) {
        if !enabled {
            lc.natPolicy?.clear()
            return
        }
        guard let server = server, let user = stunServerUserName else {
            return
        }
        lc.natPolicy?.stunEnabled = enabled
        lc.natPolicy?.stunServer = server
        lc.natPolicy?.stunServerUsername = user
        lc.natPolicy?.resolveStunServer()
    }
}

class LinphoneStateManager:CoreDelegate {
    
    let linphoneManager:LinphoneManager
    
    init(manager:LinphoneManager) {
        linphoneManager = manager
    }
    
    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String?) {
        print("onRegistrationStateChanged: \(cfg.transport); Mes: \(message ?? "")")
        guard let newState = SipRegistrationStatus(rawValue: cstate.rawValue) else { return }
        if newState != linphoneManager.sipRegistrationStatus {
            linphoneManager.sipRegistrationStatus = newState
            DispatchQueue.main.async {
                self.linphoneManager.registrationDelegate?.didChangeRegisterState(newState, message: message)
            }
        }
    }
    
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
        print("OnCallStateChanged, state:\(cstate) with message:\(message).")
        
                
        if cstate == .IncomingReceived || cstate == .OutgoingInit {
            guard let session = Session(call: call) else {
                try? call.terminate()
                print("Call terminated because remoteAddress was nil.")
                return
            }
            session.state = SessionState(rawValue: cstate.rawValue) ?? .idle
            DispatchQueue.main.async {
                if session.state == .outgoingDidInitialize {
                    self.linphoneManager.sessionDelegate?.outgoingDidInitialize(session: session)
                } else {
                    self.linphoneManager.sessionDelegate?.didReceive(incomingSession: session)
                }
                
            }
            return
        }
        
        guard let session = linphoneManager.findSession(for: call) else { return }
        session.updateInfo(call: call)
        
        session.state = SessionState(rawValue: cstate.rawValue) ?? .idle
        DispatchQueue.main.async {
            let delegate = self.linphoneManager.sessionDelegate
            switch cstate {
            case .Connected:
                delegate?.sessionConnected(session)
            case .End:
                delegate?.sessionEnded(session)
            case .Released:
                delegate?.sessionReleased(session)
            case .Error: // The call encountered an error
                delegate?.error(session: session, message: message)
            default:
                delegate?.sessionUpdated(session, message: message)
                print("Default call state: \(cstate)")
            }
        }
    }
}
