//
//  Call.swift
//  Pods-SpindleSIPFramework_Example
//


import Foundation
import linphonesw

public class Call:NSObject {
    public let callId = UUID()
    let linphoneCall: LinphoneCall
    
    public var remoteNumber:String
    public var displayName:String?
    public var remoteEnvironment:String?
    
    public var state:CallState = .idle {
        didSet {
            if state == .connected && startDate == nil {
                startDate = Date()
            }
        }
    }
    
    public var durationInSec:Int? {
        linphoneCall.duration
    }
    
    public var isIncoming:Bool {
        return linphoneCall.dir == .Incoming
    }
    
    public var direction: Direction {
        return linphoneCall.dir == .Incoming ? .inbound : .outbound
    }
    
    private(set) var startDate:Date?
    
    init?(linphoneCall: LinphoneCall) {
        guard let address = linphoneCall.remoteAddress else { return nil }
        self.linphoneCall = linphoneCall
        displayName = address.displayName
        remoteEnvironment = address.domain
        remoteNumber = address.username
    }
    
    init(linphoneCall: LinphoneCall, number:String) {
        self.linphoneCall = linphoneCall
        self.remoteNumber = number
        super.init()
        updateInfo(linphoneCall: linphoneCall)
    }
    
    /// Resumes a call.
    /// The call needs to have been paused previously with `pause()`
    public func resume() throws {
        try linphoneCall.resume()
    }
    
    /// Pauses the call.
    /// be played to the remote user. The only way to resume a paused call is to call `resume()`
    public func pause() throws {
        try linphoneCall.pause()
    }
    
    public func getAverageRating() -> Float{
        return linphoneCall.averageQuality
    }
    
    func updateInfo(linphoneCall:LinphoneCall) {
        displayName = linphoneCall.remoteAddress?.displayName
        remoteEnvironment = linphoneCall.remoteAddress?.domain
        if let user = linphoneCall.remoteAddress?.username {
            remoteNumber = user
        }
    }
}

extension Call{
    public static func == (lhs: Call, rhs: Call) -> Bool {
      return lhs.callId == rhs.callId
    }
}
