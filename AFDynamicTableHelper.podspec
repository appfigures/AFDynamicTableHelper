Pod::Spec.new do |s|
  s.name             = "AFDynamicTableHelper"
  s.version          = "0.1.0"
  s.summary          = "Create dynamic height table cells with auto layout in iOS >= 7.0."
  s.description      = <<-DESC
                       Are you building an app that targets iOS >= 7.0 and need to create table views with dynamic cell heights? This little helper takes care of all the quirks you need to do it right. On iOS 8.0 it takes advantage of the new auto-sizing capabilities automatically.
                       DESC
  s.homepage         = "https://github.com/appFigures/AFDynamicTableHelper"
  s.license          = 'MIT'
  s.author           = { "Oz" => "oz" }
  s.source           = { :git => "https://github.com/appFigures/AFDynamicTableHelper.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/appFigures'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'AFDynamicTableHelper' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
