//
//  Session.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation
import linphonesw

public class Session:NSObject {
    public let sessionId = UUID()
    let call: Call
    
    public var remoteNumber:String
    public var displayName:String?
    public var remoteEnvironment:String?
    
    public var state:SessionState = .idle {
        didSet {
            if state == .connected && startDate == nil {
                startDate = Date()
            }
        }
    }
    
    public var durationInSec:Int? {
        call.duration
    }
    
    private(set) var startDate:Date?
    
    init?(call: Call) {
        guard let address = call.remoteAddress else { return nil }
        self.call = call
        displayName = address.displayName
        remoteEnvironment = address.domain
        remoteNumber = address.username
    }
    
    init(call: Call, number:String) {
        self.call = call
        self.remoteNumber = number
        super.init()
        updateInfo(call: call)
    }
    
    /// Resumes a call.
    /// The call needs to have been paused previously with `pause()`
    public func resume() throws {
        try call.resume()
    }
    
    /// Pauses the call.
    /// be played to the remote user. The only way to resume a paused call is to call `resume()`
    public func pause() throws {
        try call.pause()
    }
    
    public func getAverageRating() -> Float{
        return call.averageQuality
    }
    
    func updateInfo(call:Call) {
        displayName = call.remoteAddress?.displayName
        remoteEnvironment = call.remoteAddress?.domain
        if let user = call.remoteAddress?.username {
            remoteNumber = user
        }
    }
}

extension Session{
    public static func == (lhs: Session, rhs: Session) -> Bool {
      return lhs.sessionId == rhs.sessionId
    }
}
