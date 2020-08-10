Pod::Spec.new do |s|
  s.name         = 'WB_ZLPhotoBrowser'
  s.version      = '1.0.0'
  s.summary      = '原项目地址：https://github.com/longitachi/ZLPhotoBrowser.git. 本库为项目所需个人定制版本. Forked from v3.2.0. 
  A simple way to multiselect photos from ablum, force touch to preview photo, 
  support portrait and landscape, 
  edit photo, multiple languages(Chinese,English,Japanese)'
  s.homepage     = 'https://github.com/huipengo/ZLPhotoBrowser'
  s.license      = 'MIT'
  s.platform     = :ios
  s.author       = {'penghui' => 'penghui_only@163.com'}

  s.ios.deployment_target = '8.0'
  s.source       = {:git => 'https://github.com/huipengo/ZLPhotoBrowser.git', :tag => s.version}
  s.source_files = 'ZLPhotoBrowser/PhotoBrowser/**/*.{h,m}'
  s.resources    = 'ZLPhotoBrowser/PhotoBrowser/resource/*.{png,xib,nib,bundle}'

  s.requires_arc = true
  s.frameworks   = 'UIKit','Photos','PhotosUI'

  s.dependency 'SDWebImage'
end
