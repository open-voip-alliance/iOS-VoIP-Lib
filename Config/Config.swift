//
// Created by Jeremy Norman on 18/02/2021.
//

import Foundation

public struct Config {
    let auth: Auth
    let callDelegate: CallDelegate
    let encryption: Bool = true
    let stun: String? = nil
    let ring: String? = nil
    let codecs: [Codec] = [Codec.OPUS]
    let userAgent: String = "iOSPhoneLib"
}
