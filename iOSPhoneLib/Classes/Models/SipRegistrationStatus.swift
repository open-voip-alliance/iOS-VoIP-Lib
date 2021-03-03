//
//  SipRegistrationStatus.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

public enum SipRegistrationStatus:Int {
    case none
    case progress
    case registered //Ok in Linphone
    case cleared
    case failed
}
