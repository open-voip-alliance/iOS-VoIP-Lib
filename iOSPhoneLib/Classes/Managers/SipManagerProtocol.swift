//
//  SIPManagerProtocol.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation

protocol SipManagerProtocol: BaseManagerProtocol {
    var sessionDelegate:CallDelegate? { get set }
}
