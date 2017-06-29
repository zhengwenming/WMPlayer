Pod::Spec.new do |s|

    s.name         = "WMPlayer"
    s.version      = "3.0.5"
    s.summary      = "A lightweight UIView for iOS to play local or network video,base on AVPlayer."
    s.homepage     = "https://github.com/zhengwenming/WMPlayer"
    s.license      = "MIT"
    s.authors      = { 'zhengwenming' => '740747055@qq.com' }
    s.platform     = :ios, '8.0'
    s.source       = { :git => 'https://github.com/zhengwenming/WMPlayer.git',:tag => "3.0.5" }

    s.source_files  = "WMPlayer", "WMPlayer/**/*.{h,m}"
    s.resource     = "WMPlayer/WMPlayer.bundle"
    s.framework    = "UIKit","MediaPlayer","AVFoundation"

    s.requires_arc = true

    s.dependency "Masonry"

end
