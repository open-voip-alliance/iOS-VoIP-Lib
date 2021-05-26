//
//  CallInfoProvider.swift
//  iOSVoIPLib
//
//  Created by Chris Kontos on 20/04/2021.
//

import Foundation
import linphonesw

class CallInfoProvider {
    
    let call: Call
    
    init(call: Call){
        self.call = call
    }
    
    func provideCallInfo() -> String {
        let audio = provideAudioInfo()
        let advancedSettings = provideAdvancedSettings()
        let toAddressInfo = provideToAddressInfo()
        let remoteParams = provideRemoteParams()
        let params = provideParams()
        let callProperties = provideCallProperties()
        let errorInfo = provideErrorInfo()
        
        let callInfo: [String: Any] = [
            "Audio": audio.map{"  \($0): \($1)"}.sorted().joined(separator: "\n"),
            "Advanced Settings": advancedSettings.map{"  \($0): \($1)"}.sorted().joined(separator: "\n"),
            "To Address": toAddressInfo.map{"  \($0): \($1)"}.sorted().joined(separator: "\n"),
            "Remote Params": remoteParams.map{"  \($0): \($1)"}.sorted().joined(separator: "\n"),
            "Params": params.map{"  \($0): \($1)"}.sorted().joined(separator: "\n"),
            "Call": callProperties.map{"  \($0): \($1)"}.sorted().joined(separator: "\n"),
            "Error": errorInfo.map{"  \($0): \($1)"}.sorted().joined(separator: "\n")
        ]
        
        return callInfo.map{"\($0)\n\($1)\n"}.sorted().joined(separator: "\n")
    }
    
    private func provideAudioInfo() -> [String:Any] {
        guard let codec = call.linphoneCall.currentParams?.usedAudioPayloadType?.description,
        let codecChannels = call.linphoneCall.currentParams?.usedAudioPayloadType?.channels,
        let downloadBandwidth = call.linphoneCall.getStats(type: .Audio)?.downloadBandwidth,
        let estimatedDownloadBandwidth = call.linphoneCall.getStats(type: .Audio)?.estimatedDownloadBandwidth,
        let jitterBufferSizeMs = call.linphoneCall.getStats(type: .Audio)?.jitterBufferSizeMs,
        let localLateRate = call.linphoneCall.getStats(type: .Audio)?.localLateRate,
        let localLossRate = call.linphoneCall.getStats(type: .Audio)?.localLossRate,
        let receiverInterarrivalJitter = call.linphoneCall.getStats(type: .Audio)?.receiverInterarrivalJitter,
        let receiverLossRate = call.linphoneCall.getStats(type: .Audio)?.receiverLossRate,
        let roundTripDelay = call.linphoneCall.getStats(type: .Audio)?.roundTripDelay,
        let rtcpDownloadBandwidth = call.linphoneCall.getStats(type: .Audio)?.rtcpDownloadBandwidth,
        let rtcpUploadBandwidth = call.linphoneCall.getStats(type: .Audio)?.rtcpUploadBandwidth,
        let senderInterarrivalJitter = call.linphoneCall.getStats(type: .Audio)?.senderInterarrivalJitter,
        let senderLossRate = call.linphoneCall.getStats(type: .Audio)?.senderLossRate,
        let iceState = call.linphoneCall.getStats(type: .Audio)?.iceState,
        let uploadBandwidth = call.linphoneCall.getStats(type: .Audio)?.uploadBandwidth else {return ["":""]}
        
        let audio: [String:Any] = [
            "codec": codec,
            "codecChannels": codecChannels,
            "downloadBandwidth": downloadBandwidth,
            "estimatedDownloadBandwidth": estimatedDownloadBandwidth,
            "jitterBufferSizeMs": jitterBufferSizeMs,
            "localLateRate": localLateRate,
            "localLossRate": localLossRate,
            "receiverInterarrivalJitter": receiverInterarrivalJitter,
            "receiverLossRate": receiverLossRate,
            "roundTripDelay": roundTripDelay,
            "rtcpDownloadBandwidth": rtcpDownloadBandwidth,
            "rtcpUploadBandwidth": rtcpUploadBandwidth,
            "senderInterarrivalJitter": senderInterarrivalJitter,
            "senderLossRate": senderLossRate,
            "iceState": iceState,
            "uploadBandwidth": uploadBandwidth
        ]
        
        return audio
    }
        
    private func provideAdvancedSettings() -> [String:Any] {
        guard let mtu = call.linphoneCall.core?.mtu,
        let echoCancellationEnabled = call.linphoneCall.core?.echoCancellationEnabled,
        let adaptiveRateControlEnabled = call.linphoneCall.core?.adaptiveRateControlEnabled,
        let audioAdaptiveJittcompEnabled = call.linphoneCall.core?.audioAdaptiveJittcompEnabled,
        let rtpBundleEnabled = call.linphoneCall.core?.rtpBundleEnabled,
        let adaptiveRateAlgorithm = call.linphoneCall.core?.adaptiveRateAlgorithm else {return ["":""]}
        
        let advancedSettings: [String:Any] = [
            "mtu": mtu,
            "echoCancellationEnabled": echoCancellationEnabled,
            "adaptiveRateControlEnabled": adaptiveRateControlEnabled,
            "audioAdaptiveJittcompEnabled": audioAdaptiveJittcompEnabled,
            "rtpBundleEnabled": rtpBundleEnabled,
            "adaptiveRateAlgorithm": adaptiveRateAlgorithm
        ]
        
        return advancedSettings
    }
    
    private func provideToAddressInfo() -> [String:Any] {
        guard let transport = call.linphoneCall.toAddress?.transport,
              let domain = call.linphoneCall.toAddress?.domain else {return ["":""]}
        
        let toAddressInfo: [String:Any] = [
            "transport": transport,
            "domain": domain,
        ]
        
        return toAddressInfo
    }
    
    private func provideRemoteParams() -> [String:Any] {
        guard let remoteEncryption = call.linphoneCall.remoteParams?.mediaEncryption,
              let remoteSessionName = call.linphoneCall.remoteParams?.sessionName,
              let remotePartyId = call.linphoneCall.remoteParams?.getCustomHeader(headerName: "Remote-Party-ID"),
              let pAssertedIdentity = call.linphoneCall.remoteParams?.getCustomHeader(headerName: "P-Asserted-Identity") else {return ["":""]}
        
        let remoteParams: [String:Any] = [
            "encryption": remoteEncryption,
            "sessionName": remoteSessionName,
            "remotePartyId": remotePartyId,
            "pAssertedIdentity": pAssertedIdentity,
        ]
        
        return remoteParams
    }
    
    private func provideParams() -> [String:Any] {
        guard let encryption = call.linphoneCall.params?.mediaEncryption,
              let sessionName = call.linphoneCall.params?.sessionName else {return ["":""]}
        
        let params: [String:Any] = [
            "encryption": encryption,
            "sessionName": sessionName
        ]
        
        return params
    }

    private func provideCallProperties() -> [String:Any] {
        let reason = call.linphoneCall.reason
        let duration = call.linphoneCall.duration
        
        guard let callId = call.linphoneCall.callLog?.callId,
              let refKey = call.linphoneCall.callLog?.refKey,
              let status = call.linphoneCall.callLog?.status,
              let direction = call.linphoneCall.callLog?.dir,
              let quality = call.linphoneCall.callLog?.quality,
              let startDate = call.linphoneCall.callLog?.startDate
        else { return ["reason": reason, "duration": duration]}
        
        let callProperties: [String:Any] = [
            "callId": callId,
            "refKey": refKey,
            "status": status,
            "direction": direction,
            "quality": quality,
            "startDate": startDate,
            "reason": reason,
            "duration": duration
        ]
        
        return callProperties
    }
    
    private func provideErrorInfo() -> [String:Any] {
        guard let phrase = call.linphoneCall.errorInfo?.phrase,
            let errorProtocol = call.linphoneCall.errorInfo?.proto,
            let errorReason = call.linphoneCall.errorInfo?.reason,
            let protocolCode = call.linphoneCall.errorInfo?.protocolCode else {return ["":""]}
        
        let errorInfo: [String:Any] = [
            "phrase": phrase,
            "protocol": errorProtocol,
            "reason": errorReason,
            "protocolCode": protocolCode
        ]
        
        return errorInfo
    }
}
