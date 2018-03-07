#
#  Be sure to run `pod spec lint SZRefreshControl.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "SZRefreshControl"
  s.version      = "0.0.3"
  s.summary      = "refresh control"
  s.homepage     = "https://bitbucket.org/songzhou/ios_refreshcontrol"
  s.license      = "MIT"
  s.author       = { "Song Zhou" => "zhousong1993@gmail.com" }
  s.platform     = :ios
  s.ios.deployment_target  = '8.0'
  s.source       = { :git => "https://songzhou@bitbucket.org/songzhou/ios_refreshcontrol.git", :tag => "#{s.version}" }
  s.source_files  = "SZRefreshControl/Classes"
  s.requires_arc = true
end
