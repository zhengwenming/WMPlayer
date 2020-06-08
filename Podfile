#source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Artsy/Specs.git'
source 'https://cdn.cocoapods.org/'
platform :ios, '8.0'
# 引用框架
use_frameworks!
# ignore all warnings from all pods(注解)
inhibit_all_warnings!

target 'PlayerDemo' do
    pod 'Masonry'
    pod 'GPUImage'
    pod 'AFNetworking', '~> 4.0.1'
    pod 'FDFullscreenPopGesture'
    pod 'MJRefresh'
    pod 'SDWebImage'
    pod 'TZImagePickerController', '~> 2.1.6'
end

#Xcode里配置：项目名->Target->Build Settings->Enable BitCode中设置为NO就可以了.
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
