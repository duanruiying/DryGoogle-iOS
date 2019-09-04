#
# Be sure to run `pod lib lint DryGoogle-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# 提交仓库:
# pod spec lint DryGoogle-iOS.podspec --allow-warnings --use-libraries
# pod trunk push DryGoogle-iOS.podspec --allow-warnings --use-libraries
#

Pod::Spec.new do |s|
  
  # Git
  s.name        = 'DryGoogle-iOS'
  s.version     = '0.0.1'
  s.summary     = 'DryGoogle-iOS'
  s.homepage    = 'https://github.com/duanruiying/DryGoogle-iOS'
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.author      = { 'duanruiying' => '2237840768@qq.com' }
  s.source      = { :git => 'https://github.com/duanruiying/DryGoogle-iOS.git', :tag => s.version.to_s }
  s.description = <<-DESC
  TODO: Google功能简化(登录、获取用户信息).
  DESC
  
  # User
  #s.swift_version         = '5.0'
  s.ios.deployment_target = '10.0'
  s.requires_arc          = true
  s.user_target_xcconfig  = {'OTHER_LDFLAGS' => ['-w']}
  
  # Pod
  s.static_framework      = true
  s.pod_target_xcconfig   = {'OTHER_LDFLAGS' => ['-w', '-ObjC']}
  
  # Code
  s.source_files          = 'DryGoogle-iOS/Classes/Code/**/*'
  s.public_header_files   = 'DryGoogle-iOS/Classes/Code/Public/**/*.h'
  
  # System
  s.libraries  = 'z'
  s.frameworks = 'UIKit', 'Foundation'
  
  # ThirdParty
  #s.vendored_libraries  = ''
  #s.vendored_frameworks = ''
  s.dependency 'GoogleSignIn'
  
end
