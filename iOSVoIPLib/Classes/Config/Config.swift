//
// Created by Jeremy Norman on 18/02/2021.
//

import Foundation

public struct Config {
    public init(auth: Auth, callDelegate: CallDelegate, encryption: Bool = true, stun: String? = nil, ring: String? = nil, codecs: [Codec] = [Codec.OPUS], userAgent: String = "iOSVoIPLib") {
        self.auth = auth
        self.callDelegate = callDelegate
        self.encryption = encryption
        self.stun = stun
        self.ring = ring
        self.codecs = codecs
        self.userAgent = userAgent
    }
    
    public let auth: Auth
    public let callDelegate: CallDelegate
    public let encryption: Bool
    public let stun: String?
    public let ring: String?
    public let codecs: [Codec]
    public let userAgent: String
}
