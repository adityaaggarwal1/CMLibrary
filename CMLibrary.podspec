#
# Be sure to run `pod lib lint CMLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CMLibrary"
  s.version          = "0.1.9"
  s.summary          = "Library for calling web services."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
s.description      = "This CocoaPod provides the ability to fetch/push data through a web service call. It contains lots of customization that you can configure following features: caching, response type, request type etc."

  s.homepage         = "https://github.com/adityaaggarwal1/CMLibrary"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "adityaaggarwal1" => "aditya.aggarwal@yahoo.co.in" }
  s.source           = { :git => "https://github.com/adityaaggarwal1/CMLibrary.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource = 'Pod/Assets/*.sqlite'
##s.resource_bundles = {
##  'CMLibrary' => ['Pod/Assets/*.png']
##}

  s.library = 'sqlite3'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
