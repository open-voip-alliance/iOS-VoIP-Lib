//
//  IncomingCallViewController.swift
//  iOSVoIPLib_Example
//
//  Created by Chris Kontos on 02/04/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//


import Foundation
import UIKit
import iOSVoIPLib

class IncomingCallViewController: UIViewController, CallEvent {

    let voipLib = VoIPLib.shared
    let callManager = (UIApplication.shared.delegate as! AppDelegate).callManager
    
    @IBOutlet weak var callTitle: UILabel!
    @IBOutlet weak var callSubtitle: UILabel!
    
    // MARK: Lifecircle
    
    override func viewWillAppear(_ animated: Bool) {
        callManager.callEvent = self
        render(call: callManager.activeCall)
    }
    
    // MARK: CallEvent
    
    func onUpdate() {
        print("Updating IncomingCallViewController for call event")
        let call = callManager.activeCall

        if !callManager.isInCall && call?.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
        render(call: call)
    }
    
    // MARK: Ui
    
    private func render(call: Call? = nil) {
        guard let call = (call ?? callManager.activeCall) else {
            self.dismiss(animated: true)
            return
        }
        callTitle.text = call.displayName
        callSubtitle.text = call.remoteNumber
    }
    
    @IBAction func hangUpButtonWasPressed(_ sender: Any) {
        guard let call = callManager.activeCall else {
            self.dismiss(animated: true)
            return
        }
        _ = voipLib.actions(call: call).end()
    }
    
    @IBAction func answerButtonWasPressed(_ sender: Any) {
        guard let call = callManager.activeCall else {
            self.dismiss(animated: true)
            return
        }
        _ = voipLib.actions(call: call).accept()
        
        self.dismiss(animated: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let nav = appDelegate.window?.rootViewController as? UITabBarController {
            nav.performSegue(withIdentifier: "LaunchCallSegue", sender: nav)
        }
    }
    
}
