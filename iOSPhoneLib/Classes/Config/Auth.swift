//
// Created by Jeremy Norman on 18/02/2021.
//

import Foundation

public struct Auth {
    public init(name: String, password: String, domain: String, port: Int) {
        self.name = name
        self.password = password
        self.domain = domain
        self.port = port
    }
    
    public let name: String
    public let password: String
    public let domain: String
    public let port: Int
}
