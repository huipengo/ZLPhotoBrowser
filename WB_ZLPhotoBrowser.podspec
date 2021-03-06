Pod::Spec.new do |s|
  s.name         = 'WB_ZLPhotoBrowser'
  s.version      = '3.2.4'
  s.summary      = '原项目地址：https://github.com/longitachi/ZLPhotoBrowser.git. 本库为项目所需个人定制版本. Forked from v3.2.0.'
  
  s.description      = <<-DESC
  A simple way to multiselect photos from ablum, force touch to preview photo, 
  support portrait and landscape, edit photo, multiple languages(Chinese,English,Japanese)
                         DESC
  
  s.homepage     = 'https://github.com/huipengo/ZLPhotoBrowser'
  s.license      = 'MIT'
  s.platform     = :ios
  s.author       = {'huipeng' => 'penghui_only@163.com'}
  s.source       = {:git => 'https://github.com/huipengo/ZLPhotoBrowser.git', :tag => s.version.to_s}
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  
  s.source_files = [ 'ZLPhotoBrowser/Classes/**/*.{h,m}' ]
  s.resources    = [ 'ZLPhotoBrowser/Classes/Resources/*.{png,xib,nib,bundle}' ]
  s.frameworks   = [ 'UIKit','Photos','PhotosUI' ]

  s.dependency 'SDWebImage'
end


# pod lib lint WB_ZLPhotoBrowser.podspec --allow-warnings --use-libraries --verbose
# pod trunk push WB_ZLPhotoBrowser.podspec --allow-warnings --use-libraries --verbose
