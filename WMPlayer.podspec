Last login: Thu Nov 17 14:01:55 on ttys001
c%                                                                              ➜  ~ cd /Users/yanyuliang/Documents/git_work/pod库/WMPlayer 
➜  WMPlayer git:(master) ✗ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   WMPlayer.xcodeproj/project.xcworkspace/xcuserdata/yanyuliang.xcuserdatad/UserInterfaceState.xcuserstate

no changes added to commit (use "git add" and/or "git commit -a")
➜  WMPlayer git:(master) ✗ vi WMPlayer.podspec 





























➜  WMPlayer git:(master) ✗  
➜  WMPlayer git:(master) ✗ 
➜  WMPlayer git:(master) ✗ 
➜  WMPlayer git:(master) ✗ git add -A
➜  WMPlayer git:(master) ✗ git commit -m 'pb'
[master 8649c22] pb
 2 files changed, 2 insertions(+), 2 deletions(-)
➜  WMPlayer git:(master) git push
Counting objects: 8, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (8/8), done.
Writing objects: 100% (8/8), 2.50 KiB | 0 bytes/s, done.
Total 8 (delta 4), reused 0 (delta 0)
To http://10.77.77.67:3000/iOS/WMPlayer.git
   fc01816..8649c22  master -> master
➜  WMPlayer git:(master) vi WMPlayer.podspec
➜  WMPlayer git:(master) ✗ git add -A                           
➜  WMPlayer git:(master) ✗ git commit -m 'pb'                   
[master 62de869] pb
 1 file changed, 4 insertions(+), 2 deletions(-)
➜  WMPlayer git:(master) git push                             
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 354 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
To http://10.77.77.67:3000/iOS/WMPlayer.git
   8649c22..62de869  master -> master
➜  WMPlayer git:(master) vi WMPlayer.podspec

#
#  Be sure to run `pod spec lint WMPlayer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "WMPlayer"
  s.version      = "0.0.1"
  s.summary      = "A short description of WMPlayer."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                  播放器VMplayer，详细请看README.MD，包括使用说明
                                        DESC
  s.homepage     = "http://manhuaren.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

#
#  Be sure to run `pod spec lint WMPlayer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "WMPlayer"
  s.version      = "0.0.1"
  s.summary      = "A short description of WMPlayer."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                  播放器VMplayer，详细请看README.MD，包括使用说明
					DESC
  s.homepage     = "http://manhuaren.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "azay" => "yanyuliang@yingqidm.com" }
  # Or just: s.author    = "azay"
  # s.authors            = { "azay" => "yanyuliang@yingqidm.com" }
  # s.social_media_url   = "http://twitter.com/azay"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

   s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "7.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source       = { :git => "https://github.com/azayu/WMPlayer.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #
 s.subspec 'View' do |ss|
    ss.source_files ="WMPlayer/WMPlayer/View/*.{h,m}"
  end
  s.source_files  =    "WMPlayer/WMPlayer/*.{h,m}"

 # s.exclude_files = "Classes/Exclude"

s.public_header_files = "WMPlayer/WMPlayer/","WMPlayer/WMPlayer/View"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

s.resources = "WMPlayer/WMPlayer/WMPlayer.bundle","WMPlayer/WMPlayer/View/FastForwardView.xib"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  s.frameworks = "MediaPlayer", "AVFoundation", "UIKit"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
   s.dependency 'Masonry'

end
