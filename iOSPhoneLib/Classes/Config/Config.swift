//
// Created by Jeremy Norman on 18/02/2021.
//

import Foundation

public struct Config {
    public let auth: Auth
    public let callDelegate: CallDelegate
    public let encryption: Bool = true
    public let stun: String? = nil
    public let ring: String? = nil
    public let codecs: [Codec] = [Codec.OPUS]
    public let userAgent: String = "iOSPhoneLib"
}
