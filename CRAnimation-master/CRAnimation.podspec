#
# Be sure to run `pod lib lint CRAnimation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'CRAnimation'
    s.version          = '0.1.0'
    s.summary          = 'Some incredible animation effects in iOS.'
    s.description      = <<-DESC
        CRAniamtion full name is Couldn't Refuse Aniamtion.
        In here, we can find or create some incredible animation effects in iOS.
                       DESC

    s.homepage         = 'https://github.com/BearRan/CRAnimation.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'BearRan' => '648070256@qq.com' }
    s.source           = { :git => 'https://github.com/BearRan/CRAnimation.git', :tag => s.version.to_s }
    s.ios.deployment_target = '7.0'
    s.frameworks = 'UIKit'
    s.dependency 'BearSkill'
    s.prefix_header_file = 'CRAnimation/CRPCH/CRPrefixHeader.pch'

    s.subspec 'Widget' do |widget|

        widget.subspec 'CRImageGradientView' do |imageGradientView|
            imageGradientView.source_files = 'CRAnimation/CRWidget/CRImageGradientView/*'
        end

        widget.subspec 'CRCardAnimationView' do |cardAnimationView|
            cardAnimationView.source_files = 'CRAnimation/CRWidget/CRCardAnimationView/*'
        end

    end
end
