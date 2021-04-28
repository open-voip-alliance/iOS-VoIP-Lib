//
//  MicPermissionHelper.swift
//

import Foundation
import AVFoundation

public class MicPermissionHelper{
    
    public static func requestMicrophonePermission(completion: @escaping ((_ startCalling: Bool) -> Void)) {
        DispatchQueue.main.async {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
