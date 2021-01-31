platform :ios, '12.1'
use_frameworks!

abstract_target 'SumDU App' do
  pod 'Alamofire'
  pod 'Cartography'
  pod 'SwiftyJSON'
  
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  
  pod 'Fuzi'
  
  target 'SumDU'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.1'
  end
 end
end
