//
//  AppDelegate.swift
//  iOSVoIPLib-Example
//


import UIKit
import iOSVoIPLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let voipLib = VoIPLib.shared
    private let defaults = UserDefaults.standard
    
    let callManager = CallManager()
    let logManager = LogManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let auth = Auth(name: self.userDefault(key: "username"), password: self.userDefault(key: "password"), domain: self.userDefault(key: "domain"), port: Int(self.userDefault(key: "port")) ?? 0)
        
        
        let config = Config(auth: auth,
                            callDelegate: callManager,
                            encryption: self.defaults.bool(forKey: "encryption"))
        voipLib.initialize(config: config)
                
        print("Attempting registration on app launch...")

        _ = voipLib.register { state in
            print("Registration response: \(state)")

            if state == .registered {
                print("Registration was successful!")
            }
            else if state == .failed {
                print("Registration failed.")
            }
        }
        
        return true
    }
    
    private func userDefault(key: String) -> String {
        defaults.object(forKey: key) as? String ?? ""
    }
}
