#
#  Be sure to run `pod spec lint QXQrCodeScan.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "QXQrCodeScan"
  s.version      = "1.0.2"
  s.summary      = "A short description of QXQrCodeScan."
  s.description  = "二维码扫描"
  s.homepage     = "https://github.com/cctvbtv123456/QXQrCodeScan"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "王智鹏" => "1272524311@qq.com" }
  s.platform     = :ios, "9.0"
  s.source   = { :git => "https://github.com/cctvbtv123456/QXQrCodeScan.git", :tag => "1.0.2" }
  s.source_files  = "Classes", "QXQrCodeScan/QXQrCodeScan/**/*.{h,m}"
  s.requires_arc = true#
end
