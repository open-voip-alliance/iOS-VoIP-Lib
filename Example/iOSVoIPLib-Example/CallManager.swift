//
//  CallManager.swift
//  iOSVoIPLib-Example
//
//  Created by Chris Kontos on 24/03/2021.
//

import Foundation
import iOSVoIPLib

class CallManager: CallDelegate {
    
    
    let voipLib: VoIPLib
    
    private var internalActiveCall: Call? = nil
    
    var callEvent: CallEvent?
    var transferSession: AttendedTransferSession? = nil

    var activeCall: Call? {
        get {
            if let transferSession = transferSession {
                return transferSession.to
            }
            return internalActiveCall
        }
    }

    var inactiveCall: Call? {
        get {
            return transferSession?.from
        }
    }
    
    var isInCall: Bool {
        get {
            activeCall != nil
        }
    }
    
    var isInTranfer: Bool {
        get {
            transferSession != nil
        }
    }
    
    init() {
      voipLib = VoIPLib.shared
    }
    
        
    // MARK: CallDelegate
    public func incomingCallReceived(_ incomingCall: Call) {
        if !isInCall {
            print("Setting up the incoming call")
            self.internalActiveCall = incomingCall
            broadcast()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let nav = appDelegate.window?.rootViewController as? UITabBarController {
                nav.performSegue(withIdentifier: "LaunchIncomingCallSegue", sender: nav)
            }
        } else {
            print("Detecting incoming call received while already in call so not doing anything")
        }
    }

    public func outgoingCallCreated(_ call: Call) {
        if !isInCall {
            print("Setting up the outgoing call")
            self.internalActiveCall = call
            broadcast()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let nav = appDelegate.window?.rootViewController as? UITabBarController {
                nav.performSegue(withIdentifier: "LaunchCallSegue", sender: nav)
            }
        } else {
            print("Detected outgoing call creation while already in call so not doing anything")
        }
    }

    public func callUpdated(_ call: Call, message: String) {
        print("Call has updated: \(message)")
        broadcast()
    }

    public func callConnected(_ call: Call) {
        print("Call has connected")
        broadcast()
    }

    public func callEnded(_ call: Call) {
        print("Received call ended event")
        
        if !isInTranfer {
            print("We are not currently in transfer so we will end all calls")
            voipLib.terminateAllCalls()
            self.internalActiveCall = nil
        }

        transferSession = nil
        broadcast()
    }
    
    func callReleased(_ call: Call) {
        broadcast()
    }
    
    func broadcast() {
        callEvent?.onUpdate()
    }    
    
    func attendedTransferMerged(_ call: Call) {
    
    }
}
