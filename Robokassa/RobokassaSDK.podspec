Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name           = 'RobokassaSDK'
  spec.version        = '1.0.0'
  spec.summary        = 'Robokassa iOS SDK'
  spec.description    = 'This is the Robokassa iOS SDK'
  spec.homepage       = 'https://gitlab.itfactory.site/ipol/opol_ios'
  spec.license        = 'MIT'
  spec.author         = { 'madjios' => 'majit.ios.dev@icloud.com' }
  spec.platform       = :ios, '14.0'
  spec.source         = { :git => 'https://gitlab.itfactory.site/ipol/opol_ios.git', :tag => spec.version.to_s }
  spec.source_files   = 'Robokassa/**/*.{swift}'
  spec.swift_versions = '5.0'
  
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"
  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"
  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"
  # spec.requires_arc = true
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
