source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
pod 'SwiftLint'
pod 'DateToolsSwift'
pod 'ReachabilitySwift'
pod 'Moya'
end

def firebase_pods
pod 'Firebase/Core'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Messaging'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/DynamicLinks'
end
  
def ad_pods
  pod 'AdMediaction_iOS', :git => 'https://github.com/cashwalk/AdMediaction_iOS'
  pod 'MomentoIOS', :git => 'https://github.com/cashwalk/MomentoIOS' 
  pod 'Appboy-iOS-SDK'
  pod 'AdPieSDK' 
end

target 'Cashdoc' do
shared_pods
#kakao_pods
firebase_pods
ad_pods
end

target 'CashdocTests' do
shared_pods
end

target 'CashdocUITests' do
shared_pods
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
