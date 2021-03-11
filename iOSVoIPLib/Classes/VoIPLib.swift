//
//  SpindleSIPFramework.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

public class VoIPLib {
    
    static public let shared = VoIPLib()

    public var isRegistered: Bool {
        get { sipManager.isRegistered }
    }

    public var isInitialized: Bool {
        get { sipManager.isInitialized }
    }

    public var isReady: Bool {
        get { isRegistered && isInitialized }
    }
    
    let sipManager: SipManagerProtocol
    
    init() {
        sipManager = LinphoneManager()
    }
    
    public func initialize(config: Config) {
        _ = sipManager.initialize(config: config)
    }

    public func refreshConfig(config: Config) {
        destroy()
        initialize(config: config)
    }

    public func swapConfig(config: Config) {
        sipManager.swapConfig(config: config)
    }
    
    /// This `registers` your user on SIP. You need this before placing a call.
    /// - Returns: Bool containing register result
    public func register(callback: @escaping RegistrationCallback) -> Bool {
        sipManager.register(callback: callback)
    }

    public func destroy() {
        sipManager.destroy()
    }
    
    public func terminateAllCalls() {
        sipManager.terminateAllCalls()
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
    /// - Returns: `Call?`  The call or nil if the call has not been successful
    public func call(to number: String) -> Call? {
        sipManager.call(to: number)
    }
    
    public var isMicrophoneMuted:Bool {
        get {
            sipManager.isMicrophoneMuted
        }
        
        set(muted) {
            sipManager.setMicrophone(muted: muted)
        }
        
    }
    
    public func actions(call: Call) -> Actions {
        Actions(sipManager: sipManager, call: call)
    }
}
