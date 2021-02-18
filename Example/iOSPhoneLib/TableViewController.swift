//
//  ViewController.swift
//  SpindleSIPFramework
//
//  Created by Fabian Giger on 04/14/2020.
//  Copyright (c) 2020 Fabian Giger. All rights reserved.
//

import UIKit
import iOSPhoneLib

class TableViewController: UITableViewController {

    @IBOutlet private var domainTF: UITextField!
    @IBOutlet private var portTF: UITextField!
    @IBOutlet private var accountTF: UITextField!
    @IBOutlet private var passwordTF: UITextField!
    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var useTLS: UISwitch!
    
    @IBOutlet private var numberTF: UITextField!
    
    @IBOutlet var callAnswer: UIButton!
    @IBOutlet var callDecline: UIButton!
    @IBOutlet var callHold: UIButton!
    @IBOutlet var callTransfer: UIButton!
    
    var activeSession:Session?
    var holdSession:Session?
    
    private var durationTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAnswer.isHidden = true
        callDecline.isHidden = true
        callHold.isHidden = true
        callTransfer.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PhoneLib.shared.registrationDelegate = self
        PhoneLib.shared.sessionDelegate = self
        PhoneLib.shared.setUserAgent("PhoneLibExample", version: "1")
    }
    
    
    func updateUI(session:Session, message:String) {
        stateLabel.text = "\(message): \(session.displayName ?? "NO NAME") (\(session.remoteNumber))"
        callAnswer.isHidden = false
        callDecline.isHidden = false
    }

    @IBAction func connect(_ sender: Any) {
        if PhoneLib.shared.registrationStatus == .registered {
            PhoneLib.shared.unregister {
                (sender as! UIButton).setTitle("Connect", for: .normal)
            }
        } else {
            let success = PhoneLib.shared.register(domain: domainTF.text!,
                                                      port: Int(portTF.text!)!,
                                                      username: accountTF.text!,
                                                      password: passwordTF.text!,
                                                      encrypted: useTLS.isOn)
            debugPrint("Registering result: \(success)")
            (sender as! UIButton).setTitle(success ? "Disconnect" : "Failed", for: .normal)
            PhoneLib.shared.resetAudioCodecs()
        }
    }
    
    @IBAction func call(_ sender: Any) {
        //Two active lines.
        if let active = activeSession {
            PhoneLib.shared.setHold(session: active, onHold: true)
            holdSession = active
            activeSession = nil
        }
        let outgoingSuccess = PhoneLib.shared.call(to: numberTF.text!)
        stateLabel.text = "Call res: \(outgoingSuccess)"
        debugPrint("Call res: \(outgoingSuccess)")
        callDecline.isHidden = (outgoingSuccess == nil)
    }
    
    @IBAction func answer(_ sender: Any) {
        guard let session = activeSession else { return }
        stateLabel.text = "Answer: \(PhoneLib.shared.acceptCall(for: session))"
        callAnswer.isHidden = true
        callTransfer.isHidden = false
    }
    
    @IBAction func decline(_ sender: Any) {
        guard let session = activeSession else { return }
        stateLabel.text = "Ended: \(PhoneLib.shared.endCall(for: session))"
        callAnswer.isHidden = true
        callDecline.isHidden = true
        callTransfer.isHidden = true
    }
    
    @IBAction func holdCall(_ sender: UIButton) {
        guard let session = activeSession else { return }
        stateLabel.text = "Hold successful: \(PhoneLib.shared.setHold(session: session, onHold: session.state != .paused))"
        sender.setTitle(session.state == .pausing ? "Unhold" : "Hold", for: .normal)
    }
    
    @IBAction func transfer(_ sender: Any) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Transfer to number", message: nil, preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Number"
            textField.keyboardType = .numberPad
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Transfer", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?.first, !textField.text!.isEmpty else { return }
            let _ = PhoneLib.shared.transfer(session: self.activeSession!, to: textField.text!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleMic(_ sender: UIButton) {
        PhoneLib.shared.setMicrophone(muted: !PhoneLib.shared.isMicrophoneMuted)
        sender.setTitle(PhoneLib.shared.isMicrophoneMuted ? "Unmute mic" : "Mute mic", for: .normal)
    }
    
    @IBAction func toggleSpeaker(_ sender: UIButton) {
        _ = PhoneLib.shared.setSpeaker(!PhoneLib.shared.isSpeakerOn)
        sender.setTitle(PhoneLib.shared.isSpeakerOn ? "Turn off speaker" : "Turn on speaker", for: .normal)
    }
}

extension TableViewController: RegistrationStateDelegate {
    func didChangeRegisterState(_ state: SipRegistrationStatus, message: String?) {
        switch state {
        case .none:
            stateLabel.text = "None: \(message ?? "")"
        case .progress:
            stateLabel.text = "Progress: \(message ?? "")"
        case .registered:
            stateLabel.text = "Registered: \(message ?? "")"
        case .cleared:
            stateLabel.text = "Cleared: \(message ?? "")"
        case .failed:
            stateLabel.text = "Failed: \(message ?? "")"
        }
    }
}

extension TableViewController: CallDelegate {
    func didReceive(incomingSession: Session) {
        self.activeSession = incomingSession
        updateUI(session: incomingSession, message: "Incoming call")
    }
    
    func outgoingDidInitialize(session: Session) {
        self.activeSession = session
        updateUI(session: session, message: "Outgoing init")
        print("outgoingDidInitialize")
    }
    
    func sessionUpdated(_ session: Session, message: String) {
        self.activeSession = session
        updateUI(session: session, message: "Updated: \(message)")
        print("Session updated: \(session.state)")
    }
    
    func sessionConnected(_ session: Session) {
        self.activeSession = session
        updateUI(session: session, message: "Connected")
        if durationTimer == nil {
            durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
                self.stateLabel.text = "Call: \(session.displayName ?? "NO NAME") (\(session.remoteNumber)) (\(session.durationInSec ?? 0))"
            })
        }
        callHold.isHidden = false
        callTransfer.isHidden = false
        print("sessionConnected")
    }
    
    func sessionEnded(_ session: Session) {
        self.activeSession = session
        updateUI(session: session, message: "Ended")
        
        durationTimer?.invalidate()
        callHold.isHidden = true
        callAnswer.isHidden = true
        callDecline.isHidden = true
        print("sessionEnded")
    }
    
    public func sessionReleased(_ session: Session) {
        self.activeSession = session
        updateUI(session: session, message: "Released")
        durationTimer?.invalidate()
        print("sessionReleased")
    }
    
    func error(session:Session, message: String) {
        updateUI(session: session, message: "Error: \(message)")
        print("error")
    }
}
