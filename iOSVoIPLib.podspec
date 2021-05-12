Pod::Spec.new do |s|

    s.platform = :ios
    s.ios.deployment_target = '11.3'
    s.name = 'iOSVoIPLib'
    s.summary = 'This library is an opinionated sip-wrapper, currently using Linphone as the base.'
    
    s.version = '0.1.0'
    
    s.license = { :type => 'AGPL', :file => 'LICENSE' }
    
    s.author = { "Jeremy Norman" => "Jeremy.Norman@wearespindle.com", "Chris Kontos" => "chris.kontos@wearespindle.com" }
    
    s.homepage = 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-voip-lib'
    
    s.source = { :git => 'https://github.com/open-voip-alliance/iOS-VoIP-Lib.git',
                 :tag => s.version.to_s }

    s.source_files = 'iOSVoIPLib/Classes/**/*'
  
    s.dependency 'linphone-sdk', '4.4.1'
    
    s.swift_version = "5"
  
end

