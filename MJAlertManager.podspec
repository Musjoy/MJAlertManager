#
# Be sure to run `pod lib lint MJAlertManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MJAlertManager'
  s.version          = '0.1.8'
  s.summary          = 'A Manager of alert.'

  s.homepage         = 'https://github.com/Musjoy/MJAlertManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Raymond' => 'Raymond.huang@musjoy.com' }
  s.source           = { :git => 'https://github.com/Musjoy/MJAlertManager.git', :tag => "v-#{s.version}" }

  s.ios.deployment_target = '8.0'

  s.source_files = 'MJAlertManager/Classes/**/*'

  s.user_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS' => 'MODULE_ALERT_MANAGER'
  }

  s.dependency 'ModuleCapability'
  s.prefix_header_contents = '#import "ModuleCapability.h"'

end
