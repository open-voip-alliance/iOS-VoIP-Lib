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
        
        loadDefaultCredentialsFromEnvironment()
        
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
    
    /// Loads in environment variables into the user default, so you can provide default login information to avoid manually adding it every time.
    ///
    /// To add environment variables, in xCode, "Edit Scheme" > Run > Environment and add the environment keys (e.g. pil.default.username) and
    /// the relevant values (i.e. your voip account password).
    private func loadDefaultCredentialsFromEnvironment() {
        _ = loadCredentialFromEnvironment(environmentKey: "default.username", userDefaultsKey: "username")
        _ = loadCredentialFromEnvironment(environmentKey: "default.password", userDefaultsKey: "password")
        _ = loadCredentialFromEnvironment(environmentKey: "default.domain", userDefaultsKey: "domain")
        _ = loadCredentialFromEnvironment(environmentKey: "default.port", userDefaultsKey: "port")
    }
    
    /// Attempts to load a credential from an environment variable, and puts it into the user defaults.
    private func loadCredentialFromEnvironment(environmentKey: String, userDefaultsKey: String) -> Bool {
        if let value = ProcessInfo.processInfo.environment[environmentKey] {
            if !value.isEmpty {
                self.defaults.set(value, forKey: userDefaultsKey)
                return true
            } else {
                return false
            }
        }
        
        return false
    }
}
