//
//  CallViewController.swift
//


import Foundation
import UIKit
import iOSVoIPLib
import AVFoundation

class CallViewController: UIViewController, CallEvent {
    
    @IBOutlet weak var callTitle: UILabel!
    @IBOutlet weak var callSubtitle: UILabel!
    @IBOutlet weak var callDuration: UILabel!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var inactiveCallStatus: UILabel!
    
    @IBOutlet weak var speakerButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var holdButton: UIButton!
    @IBOutlet weak var earpieceButton: UIButton!
    @IBOutlet weak var transferButton: UIButton!
    
    let voipLib = VoIPLib.shared
    let callManager = (UIApplication.shared.delegate as! AppDelegate).callManager
    
    private let audioSession = AVAudioSession.sharedInstance()
    
    // MARK: Lifecircle
    
    override func viewWillAppear(_ animated: Bool) {
        callManager.callEvent = self
        render(call: callManager.activeCall)
    }
    
    // MARK: CallEvent

    func onUpdate() {
        print("Updating CallViewController for call event")
        let call = callManager.activeCall

        if !callManager.isInCall && call?.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
        render(call: call)
    }

    // MARK: Ui

    private func render(call: Call? = nil) {
        guard let call = call ?? callManager.activeCall else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        callTitle.text = call.displayName
        callSubtitle.text = String(describing: call.direction)
        callDuration.text = String(describing: call.durationInSec!)
        callStatus.text = String(describing: call.state)

        if voipLib.isMicrophoneMuted {
            muteButton.isSelected = true
            muteButton.setTitle("UNMUTE", for: .normal)
        } else {
            muteButton.isSelected = false
            muteButton.setTitle("MUTE", for: .normal)
        }

        if call.state == .paused {
            holdButton.isSelected = true
            holdButton.setTitle("UNHOLD", for: .normal)
        } else {
            holdButton.isSelected = false
            holdButton.setTitle("HOLD", for: .normal)
        }
        
        if callManager.isInTranfer {
            inactiveCallStatus.isHidden = false
            if let inactiveCall = callManager.inactiveCall {
                inactiveCallStatus.text = "\(inactiveCall.displayName) - \(inactiveCall.remoteNumber)"
            }
            transferButton.setTitle("MERGE", for: .normal)
        } else {
            inactiveCallStatus.isHidden = true
            inactiveCallStatus.text = ""
            transferButton.setTitle("TRANSFER", for: .normal)
        }
        
        if call.state != .connected {
            speakerButton.isSelected = false
            earpieceButton.isSelected = false
            return
        }
        
        let speakerIsOn = !audioSession.currentRoute.outputs.filter({$0.portType == .builtInSpeaker}).isEmpty
        speakerButton.isSelected = speakerIsOn
        
        let earpieceIsOn = !audioSession.currentRoute.outputs.filter({$0.portType == .builtInReceiver}).isEmpty
        earpieceButton.isSelected = earpieceIsOn
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        guard let call = callManager.activeCall else {
            self.dismiss(animated: true)
            return
        }
        _ = voipLib.actions(call: call).end()
    }
    

    @IBAction func earpieceButtonWasPressed(_ sender: Any) {
        do {
            try audioSession.overrideOutputAudioPort(.none)
            try audioSession.setActive(true)
        } catch {
            print("Audio routing failed: \(error.localizedDescription)")
        }
        render()
    }

    @IBAction func speakerButtonWasPressed(_ sender: Any) {
        do {
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            print("Audio routing failed: \(error.localizedDescription)")
        }
        render()
    }

    @IBAction func transferButtonWasPressed(_ sender: Any) {
        guard let call = self.callManager.activeCall else {
            return
        }
        
        if (!callManager.isInTranfer) {
            promptForTransferNumber { number in
                self.callManager.transferSession = self.voipLib.actions(call: call).beginAttendedTransfer(to: number)
            }
        } else {
            guard let transferSession = self.callManager.transferSession else {return}
            _ = self.voipLib.actions(call: call).finishAttendedTransfer(attendedTransferSession: transferSession)
        }
    }

    @IBAction func holdButtonWasPressed(_ sender: Any) {
        guard let call = callManager.activeCall else {
            return
        }
        _ = voipLib.actions(call: call).hold(onHold: call.state != .paused)
        render(call: call)
    }

    @IBAction func muteButtonWasPressed(_ sender: Any) {
        voipLib.isMicrophoneMuted = !voipLib.isMicrophoneMuted
        render()
    }
    
    private func promptForTransferNumber(callback: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Call Transfer", message: "Enter the number to transfer to", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "080012341234"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Transfer", style: .default) { _ in
            callback(alertController.textFields![0].text!)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        present(alertController, animated: true, completion: nil)
    }
}
