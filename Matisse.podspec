
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "Matisse"
  s.version      = "1.0.1"
  s.homepage     = "https://github.com/konoma/matisse"
  s.summary      = "Matisse is an image retrieval and caching library for iOS inspired by Picasso."
  s.description  = <<-DESC
    With Matisse you can download and display an image in an image view with a single line of code.
    Matisse takes care of downloading, caching and showing the image in an UIImageView. If you use
    it in a UITableViewDataSource it also makes sure that the correct image is shown even in case
    of a cell reuse.
  DESC


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author = { "Markus Gasser" => "markus.gasser@konoma.ch" }


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform = :ios, "8.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source = { :git => "https://github.com/konoma/matisse.git", :tag => "1.0.1" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files = "Sources/**/*.{swift,h,m}"
  s.public_header_files = "Sources/**/*.h"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.frameworks = "Foundation", "UIKit"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

end
