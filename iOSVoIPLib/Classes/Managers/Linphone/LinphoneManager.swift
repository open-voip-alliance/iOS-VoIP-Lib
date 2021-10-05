//
//  LinphoneManager.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation
import linphonesw
import AVFoundation

typealias LinphoneCall = linphonesw.Call

//CallKit: https://wiki.linphone.org/xwiki/wiki/public/view/Lib/Getting%20started/iOS/#HCallKitIntegration

class LinphoneManager: SipManagerProtocol {
    
    var config: Config?
    var isInitialized: Bool = false
    var isRegistered: Bool = false

    private var linphoneCore: Core!
    private lazy var stateManager: LinphoneStateManager = {
        LinphoneStateManager(manager: self)
    }()
    private var proxyConfig: ProxyConfig!
    private let logManager = LinphoneLoggingServiceManager()

    var loggingDelegate: LoggingDelegate? {
        get {
            logManager.loggingDelegate
        }
        set {
            logManager.loggingDelegate = newValue
        }
    }
    
    private var logging: LoggingService {
        LoggingService.Instance
    }
    
    private var factory: Factory {
        Factory.Instance
    }
    
    var sipRegistrationStatus: SipRegistrationStatus = SipRegistrationStatus.none
    
    var isMicrophoneMuted: Bool {
        return !linphoneCore.micEnabled
    }
    
    var isSpeakerOn: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == AVAudioSession.Port.builtInSpeaker })
    }

    func initialize(config: Config) -> Bool {
        self.config = config

        if isInitialized {
            logVoIPLib(message: "Linphone already init")
            return true
        }

        do {
            try startLinphone()
            return true
        } catch {
            logVoIPLib(message: "Failed to start Linphone \(error.localizedDescription)")
            isInitialized = false
            return false
        }
    }
    
    private func startLinphone() throws {
        factory.enableLogCollection(state: LogCollectionState.Disabled)
        logging.addDelegate(delegate: logManager)
        logging.logLevel = LogLevel.Message
        
        linphoneCore = try factory.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        linphoneCore.addDelegate(delegate: stateManager)
        applyPreStartConfiguration(core: linphoneCore)
        isInitialized = true
        try linphoneCore.start()
        applyPostStartConfiguration(core: linphoneCore)
        configureCodecs(core: linphoneCore)
    }

    private func applyPreStartConfiguration(core: Core) {
        if let transports = core.transports {
            transports.tlsPort = 0
            transports.udpPort = 0
            transports.tcpPort = 0
        }
        core.pushNotificationEnabled = false
        core.callkitEnabled = false
        core.ipv6Enabled = false
        core.dnsSrvEnabled = false
        core.dnsSearchEnabled = false
        core.maxCalls = 2
        core.uploadBandwidth = 0
        core.downloadBandwidth = 0
        core.mtu = 1300
        core.guessHostname = true
        core.incTimeout = 60
        core.audioPort = -1
        core.nortpTimeout = 30
        core.avpfMode = AVPFMode.Disabled
        if let stun = config?.stun {
            core.stunServer = stun
        }
        if let natPolicy = core.natPolicy {
            natPolicy.stunEnabled = config?.stun != nil
            natPolicy.upnpEnabled = false
            natPolicy.stunServer = config?.stun ?? ""
            natPolicy.resolveStunServer()
            core.natPolicy = natPolicy
        }
        core.audioJittcomp = 100
    }
    
    func applyPostStartConfiguration(core: Core) {
        core.useInfoForDtmf = true
        core.useRfc2833ForDtmf = true
        core.adaptiveRateControlEnabled = true
        core.echoCancellationEnabled = true
    }
    
    fileprivate func logVoIPLib(message: String) {
        loggingDelegate?.onVoIPLibLog(message: message)
        debugPrint(message)
    }
        
    private func setupProxy(from:Address, encrypted:Bool) throws {
        // configure proxy entries
        proxyConfig = try linphoneCore.createProxyConfig()
        try proxyConfig.setIdentityaddress(newValue: from) // set identity with user name and domain
        let serverAddress = from.domain + (encrypted ? ";transport=tls" : "") // extract domain address from identity
        try proxyConfig.setServeraddr(newValue: serverAddress) // we assume domain = proxy server address
        try proxyConfig.setRoute(newValue: serverAddress)
        proxyConfig.registerEnabled = true // activate registration for this proxy config
        try proxyConfig.done()
        
        try linphoneCore.addProxyConfig(config: proxyConfig!) // add proxy config to linphone core
        linphoneCore.defaultProxyConfig = proxyConfig // set to default proxy
    }
    
    func swapConfig(config: Config) {
        self.config = config
    }
    
    var registrationListener: RegistrationListener?
    
    //MARK: - SipSdkProtocol
    func register(callback: @escaping RegistrationCallback) -> Bool {
        let factory = Factory.Instance
        do {
            guard let config = self.config else {
                throw InitializationError.noConfigurationProvided
            }
            
            self.registrationListener = RegistrationListener(linphoneManager: self, core: linphoneCore, callback: callback)
            
            linphoneCore.addDelegate(delegate: self.registrationListener!)

            let identity = "sip:" + config.auth.name + "@" + config.auth.domain + ":\(config.auth.port)"
            let from = try factory.createAddress(addr: identity)
            try from.setTransport(newValue: config.encryption ? .Tls : .Udp)
            
            if let transports = linphoneCore.transports {
                if config.encryption {
                    transports.tlsPort = -1
                    transports.udpPort = 0
                    transports.tcpPort = 0
                } else {
                    transports.udpPort = -1
                    transports.tlsPort = 0
                    transports.tcpPort = 0
                }
                
                try linphoneCore.setTransports(newValue: transports)
            }
            
            if config.encryption {
                from.secure = true
                try linphoneCore.setMediaencryption(newValue: MediaEncryption.SRTP)
                linphoneCore.mediaEncryptionMandatory = true
            } else {
                from.secure = false
                try linphoneCore.setMediaencryption(newValue: MediaEncryption.None)
                linphoneCore.mediaEncryptionMandatory = false
            }
            
            try setupProxy(from: from, encrypted: config.encryption)
            
            let info = try factory.createAuthInfo(username: from.username, userid: "", passwd: config.auth.password, ha1: "", realm: "", domain: "")
            linphoneCore.addAuthInfo(info: info)
            
            linphoneCore.useRfc2833ForDtmf = true
            linphoneCore.ipv6Enabled = true
            logVoIPLib(message: "Linphone successfully registering")
        } catch (let error) {
            logVoIPLib(message: "Linphone registering identify error: \(error)")
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
            self.logVoIPLib(message: "Linphone unregistering")
            for config in self.linphoneCore.proxyConfigList {
                config.edit() // start editing proxy configuration
                config.registerEnabled = false // de-activate registration for this proxy config
                do {
                    try config.done()
                } catch {
                    self.logVoIPLib(message: "Linphone unregistering error on proxy: \(error)")
                } // initiate REGISTER with expire = 0
            }

            self.isRegistered = false
            
            while(self.linphoneCore.proxyConfigList.contains(where: { $0.state != linphonesw.RegistrationState.Cleared } )) {
                self.linphoneCore.iterate() // to make sure we receive call backs before shutting down
                usleep(50000)
            }
            self.linphoneCore.proxyConfigList.forEach( { self.linphoneCore.removeProxyConfig(config: $0) } )
        }
    }

    func destroy() {
        isInitialized = false
        isRegistered = false
        linphoneCore.removeDelegate(delegate: stateManager)
        linphoneCore.stop()
        logVoIPLib(message: "Linphone unregistered")
    }
    
    func terminateAllCalls() {
        do {
           try linphoneCore.terminateAllCalls()
        } catch {
            
        }
    }
    
    func call(to number: String) -> Call? {
        guard let linphoneCall = linphoneCore.invite(url: number) else {return nil}
        let call = Call.init(linphoneCall: linphoneCall)
        return isInitialized ? call : nil
    }
    
    func acceptCall(for call: Call) -> Bool {
        do {
            try call.linphoneCall.accept()
            return true
        } catch {
            return false
        }
    }
    
    func endCall(for call: Call) -> Bool {
        do {
            try call.linphoneCall.terminate()
            return true
        } catch {
            return false
        }
    }
    
    private func configureCodecs(core: Core) {
        guard let codecs = config?.codecs else {
            return
        }
        
        linphoneCore?.videoPayloadTypes.forEach { payload in
            _ = payload.enable(enabled: false)
        }
        
        linphoneCore?.audioPayloadTypes.forEach { payload in
            let enable = !codecs.filter { selectedCodec in
                selectedCodec.rawValue.uppercased() == payload.mimeType.uppercased()
            }.isEmpty
            
            _ = payload.enable(enabled: enable)
        }
        
        guard let enabled = linphoneCore?.audioPayloadTypes.filter({ payload in payload.enabled() }).map({ payload in payload.mimeType }).joined(separator: ", ") else {
            logVoIPLib(message: "Unable to log codecs, no core")
            return
        }
        
        logVoIPLib(message: "Enabled codecs: \(enabled)")
    }

    
    func setMicrophone(muted: Bool) {
        linphoneCore.micEnabled = !muted
    }
    
    func setAudio(enabled:Bool) {
        logVoIPLib(message: "Linphone set audio: \(enabled)")
        linphoneCore.activateAudioSession(actived: enabled)
    }
    
    func setHold(call:Call, onHold hold:Bool) -> Bool {
        do {
            if hold {
                logVoIPLib(message: "Pausing call.")
                try call.pause()
            } else {
                logVoIPLib(message: "Resuming call.")
                try call.resume()
            }
            return true
        } catch {
            return false
        }
    }
    
    func transfer(call: Call, to number: String) -> Bool {
        do {
            try call.linphoneCall.transfer(referTo: number)
            logVoIPLib(message: "Transfer was successful")
            return true
        } catch (let error) {
            logVoIPLib(message: "Transfer failed: \(error)")
            return false
        }
    }
    
    func beginAttendedTransfer(call: Call, to number:String) -> AttendedTransferSession? {
        guard let destinationCall = self.call(to: number) else {
            logVoIPLib(message: "Unable to make call for target call")
            return nil
        }
        
        return AttendedTransferSession(from: call, to: destinationCall)
    }
    
    func finishAttendedTransfer(attendedTransferSession: AttendedTransferSession) -> Bool {
        do {
            try attendedTransferSession.from.linphoneCall.transferToAnother(dest: attendedTransferSession.to.linphoneCall)
            logVoIPLib(message: "Transfer was successful")
            return true
        } catch (let error) {
            logVoIPLib(message: "Transfer failed: \(error)")
            return false
        }
    }
    
    func sendDtmf(call:Call, dtmf: String) {
        if dtmf.count == 1 {
            do {
                let dtmfDigit = dtmf.utf8CString[0]
                try call.linphoneCall.sendDtmf(dtmf: dtmfDigit)
            } catch (let error) {
                logVoIPLib(message: "Sending dtmf failed: \(error)")
            }
        } else {
            do {
                try call.linphoneCall.sendDtmfs(dtmfs: dtmf)
            } catch (let error) {
                logVoIPLib(message: "Sending dtmfs failed: \(error)")
            }
        }
    }
    
    /// Provide human readable call info
    ///
    /// - Parameter call: the Call object
    /// - Returns: a String with all call info
    func provideCallInfo(call: Call) -> String {
        let callInfoProvider = CallInfoProvider(call: call)
        return callInfoProvider.provideCallInfo()
    }
}

class LinphoneStateManager:CoreDelegate {
    
    private let headersToPreserve = ["Remote-Party-ID", "P-Asserted-Identity"]
    
    let linphoneManager:LinphoneManager
    
    init(manager:LinphoneManager) {
        linphoneManager = manager
    }
    
    func onCallStateChanged(core: Core, call: LinphoneCall, state: LinphoneCall.State, message: String) {
        linphoneManager.logVoIPLib(message: "OnCallStateChanged, state:\(state) with message:\(message).")

        guard let voipLibCall = Call(linphoneCall: call) else {
            linphoneManager.logVoIPLib(message: "Unable to create call, no remote address")
            return
        }

        guard let delegate = self.linphoneManager.config?.callDelegate else {
            linphoneManager.logVoIPLib(message: "Unable to send events as no call delegate")
            return
        }

        DispatchQueue.main.async {
            switch state {
                case .OutgoingInit:
                    delegate.outgoingCallCreated(voipLibCall)
                case .IncomingReceived:
                    self.preserveHeaders(call: call)
                    delegate.incomingCallReceived(voipLibCall)
                case .Connected:
                    delegate.callConnected(voipLibCall)
                case .End, .Error:
                    delegate.callEnded(voipLibCall)
                case .Released:
                    delegate.callReleased(voipLibCall)
                default:
                    delegate.callUpdated(voipLibCall, message: message)
            }
        }
    }
    
    func onTransferStateChanged(core: Core, transfered: LinphoneCall, callState: LinphoneCall.State) {
        guard let delegate = self.linphoneManager.config?.callDelegate else {
            linphoneManager.logVoIPLib(message: "Unable to send call transfer event as no call delegate")
            return
        }
        
        guard let voipLibCall = Call(linphoneCall: transfered) else {
            linphoneManager.logVoIPLib(message: "Unable to create call, no remote address")
            return
        }
        
        delegate.attendedTransferMerged(voipLibCall)
    }
    
    /**
            Some headers only appear in the initial invite, this will check for any headers we have flagged to be preserved
     and retain them across all iterations of the LinphoneCall.
     */
    private func preserveHeaders(call: LinphoneCall) {
        headersToPreserve.forEach { key in
            let value = call.getToHeader(headerName: key)
            call.params?.addCustomHeader(headerName: key, headerValue: value)
        }
    }
}

class RegistrationListener : CoreDelegate {
    private let core: Core
    private let callback: RegistrationCallback
    private let linphoneManager: LinphoneManager
    
    init(linphoneManager: LinphoneManager, core: Core, callback: @escaping RegistrationCallback) {
        self.linphoneManager = linphoneManager
        self.callback = callback
        self.core = core
    }

    func onRegistrationStateChanged(core: Core, proxyConfig: ProxyConfig, state: linphonesw.RegistrationState, message: String) {
        switch state {
            case .Failed:
                linphoneManager.isRegistered = false
                callback(.failed)
            case .Ok:
                linphoneManager.isRegistered = true
                callback(.registered)
            case .Cleared: callback(.cleared)
            case .None: callback(.none)
            case .Progress: callback(.progress)
        }

        if state == linphonesw.RegistrationState.Ok || state == linphonesw.RegistrationState.Failed {
            core.removeDelegate(delegate: self)
        }
    }
}
