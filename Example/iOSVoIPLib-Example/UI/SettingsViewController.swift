//
//  SettingsViewController.swift
//  iOSVoIPLib-Example
//
//  Created by Chris Kontos on 24/03/2021.
//

import Foundation
import QuickTableViewController
import iOSVoIPLib

final class SettingsViewController: QuickTableViewController {

    private let defaults = UserDefaults.standard
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableContents = [

            Section(title: "Authentication", rows: [
                NavigationRow(text: "Username", detailText: .subtitle(userDefault(key: "username")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Username", key: "username") }),
                NavigationRow(text: "Password", detailText: .subtitle(userDefault(key: "password")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Password", key: "password") }),
                NavigationRow(text: "Domain", detailText: .subtitle(userDefault(key: "domain")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Domain", key: "domain") }),
                NavigationRow(text: "Port", detailText: .subtitle(userDefault(key: "port")), action: { [weak self] in self?.promptUserWithTextField(row: $0, title: "Port", key: "port") }),
                TapActionRow(text: "Test Authentication", action: { row in
                    
                    let auth = Auth(name: self.userDefault(key: "username"), password: self.userDefault(key: "password"), domain: self.userDefault(key: "domain"), port: Int(self.userDefault(key: "port")) ?? 0)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let callManager = appDelegate.callManager
                    let voipLib = VoIPLib.shared
                    
                    guard let config = voipLib.config else {
                        return
                    }
                                                 
                    let newConfig = Config(auth: auth,
                                           callDelegate: callManager,
                                           stun: config.stun,
                                           ring: config.ring,
                                           codecs: config.codecs,
                                           userAgent: config.userAgent,
                                           logListener: config.logListener
                    )
                    
                    voipLib.swapConfig(config: newConfig)
                            
                    print("Testing authentication..")

                    _ = voipLib.register { state in
                        print("Registration response: \(state)")
                        guard state != .progress else { return }
                        let success = state == .registered
                        
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Authentication Test", message: success ? "Authenticated successfully!" : "Authentication failed :(", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                            self.present(alert, animated: true)
                       }
                    }
                })
            ]),
            
            Section(title: "Preferences", rows: [
                SwitchRow(text: "Encryption", switchValue: self.defaults.bool(forKey: "encryption"), action: { row in
                    if let switchRow = row as? SwitchRowCompatible {
                        self.defaults.set(switchRow.switchValue, forKey: "encryption")
                    }
                }),
            ])
        ]
    }
    
    private func promptUserWithTextField(row: Row, title: String, key: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            self.defaults.set(textField.text, forKey: key)
            self.viewDidLoad()
        }
        alert.addTextField { (textField) in
            textField.text = self.userDefault(key: key)
        }
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }

    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    }
}

