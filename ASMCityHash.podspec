Pod::Spec.new do |s|
  s.name         = "ASMCityHash"
  s.version      = "0.1"
  s.summary      = "An Objective-C implementation of CityHash (https://code.google.com/p/cityhash/)"

  s.description  = <<-DESC
                   An Objective-C implementation of [CityHash](https://code.google.com/p/cityhash/). This is based on the CityHash repository as of May 19, 2014. It is unlikely to keep up with the original CityHash, but as the original hasn't been updated in nearly a year that probably won't be an issue for most usages. I created this library primarily because I wanted a good hashing function that supported a 64-bit digest.
                   DESC

  s.homepage     = "https://github.com/amolloy/ASMCityHash"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "Andy Molloy" => "andy@themolloys.org" }
  s.social_media_url   = "http://twitter.com/amolloy"

  s.source       = { :git => "https://github.com/amolloy/ASMCityHash.git", :tag => "0.1" }

  s.source_files  = "ASMCityHash/*.{h,m}"
  s.public_header_files = "ASMCityHash/*.h"

  s.requires_arc = true
end
