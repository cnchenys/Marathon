#
# Be sure to run `pod lib lint Marathon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Marathon'
  s.version          = '0.1.1'
  s.summary          = '基于AFNetworking封装的离散网络请求库'
  s.description      = <<-DESC
                        Marathon是基于AFNetworking封装的离散网络请求库,可以以插件中间层的形式对请求进行处理
                       DESC

  s.homepage         = 'https://github.com/cnchenys/Marathon'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TechSen' => 'cnchenys@qq.com' }
  s.source           = { :git => 'https://github.com/cnchenys/Marathon.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  
  s.subspec 'Core' do |ss|
      ss.source_files = 'Marathon/Classes/Marathon/**/*'
      ss.dependency 'AFNetworking', '~> 3.2.1'
  end
  s.default_subspec = 'Core'
end
