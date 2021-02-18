Pod::Spec.new do |s|
  s.name             = 'iOSPhoneLib'
  s.version          = '0.1.0'
  s.summary          = 'Allow for easy implementation of SIP into a swift project.'



  s.description      = <<-DESC
This library is an opinionated sip-wrapper, currently using Linphone as the base.
                       DESC

  s.homepage         = 'https://gitlab.wearespindle.com/vialer/mobile/voip/ios-phone-lib'
  s.license          = { :type => 'AGPL', :file => 'LICENSE' }
  s.author           = { 'jeremynorman89' => 'jeremy.norman@wearespindle.com' }
  s.source           = { :git => 'https://github.com/open-voip-alliance/iOSPhoneLib.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.3'

  s.source_files = 'iOSPhoneLib/Classes/**/*'
  
  s.dependency 'linphone-sdk', '4.4.1'
end
