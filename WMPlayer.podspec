Pod::Spec.new do |s|
s.name         = 'WMPlayer'
s.version      = '5.2.0'
s.summary      = 'A lightweight Video Player for iOS to play local or network video,base on AVPlayer.'
s.homepage     = 'https://github.com/zhengwenming/WMPlayer'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { 'zhengwenming' => '740747055@qq.com', 'wvqusrtg' => '1911398892@qq.com' }
s.platform     = :ios, '9.0'
s.source       = { :git => 'https://github.com/zhengwenming/WMPlayer.git', :tag => s.version }
s.source_files  = 'WMPlayer/**/*.{h,m}'
s.private_header_files = 'WMPlayer/WMPlayer+Private.h'
s.resources     = 'WMPlayer/WMPlayer.bundle'
s.frameworks    = 'Foundation', 'UIKit', 'MediaPlayer', 'AVFoundation', 'AVKit'
s.dependency    'Masonry'
s.requires_arc  = true
end
