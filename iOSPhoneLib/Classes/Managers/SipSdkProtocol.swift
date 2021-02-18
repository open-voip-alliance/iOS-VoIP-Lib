//
//  SipSdkProtocol.swift
//  linphone-sdk
//
//  Created by Fabian Giger on 20/07/2020.
//

import Foundation

protocol SipSdkProtocol: BaseManagerProtocol {
    var sessionDelegate:SipSDKDelegate? { get set }
    
    func setup() -> Bool
}
