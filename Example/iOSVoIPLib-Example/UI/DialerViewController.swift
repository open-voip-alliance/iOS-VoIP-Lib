//
//  DialerViewController.swift
//  iOSVoIPLib-Example
//
//  Created by Chris Kontos on 24/03/2021.
//

import Foundation
import UIKit
import iOSVoIPLib
import Contacts

class DialerViewController: UIViewController {
    
    @IBOutlet weak var numberPreview: UITextField!
        
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        numberPreview.text = ""
    }

    @IBAction func callButtonWasPressed(_ sender: UIButton) {
        let voipLib = VoIPLib.shared
        guard let number = numberPreview.text,
              voipLib.isInitialized else { return }
        
        
        _ = voipLib.register { _ in
                MicPermissionHelper.requestMicrophonePermission { startCalling in
                    if startCalling {
                        let result = voipLib.call(to: number)
                        print("Initiated outgoing call with success: \(result)")
                    }
                }
        }
    }
    
    @IBAction func deleteButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        
        if currentNumberPreview.isEmpty { return }
        
        numberPreview.text = String(currentNumberPreview.prefix(currentNumberPreview.count - 1))
    }
    
    @IBAction func keypadButtonWasPressed(_ sender: UIButton) {
        let currentNumberPreview = numberPreview.text ?? ""
        let buttonNumber = sender.currentTitle ?? ""
        
        numberPreview.text = currentNumberPreview + buttonNumber
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    } //TODO: move this outside ViewControllers
}
