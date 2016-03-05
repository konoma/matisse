
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "FPSCounter"
  s.version      = "1.0.0"
  s.homepage     = "https://github.com/konoma/fps-counter"
  s.summary      = "A small library to measure the frame rate of an iOS Application."
  s.description  = <<-DESC
  FPSCounter is a small library to measure the frame rate of an iOS Application.
  
  You can display the current frames per second in the status bar with a single line.
  Or if you'd like more control, you can have your own code notified of FPS changes
  and display it as needed.
  DESC


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author = { "Markus Gasser" => "markus.gasser@konoma.ch" }
  

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform = :ios, "8.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source = { :git => "https://github.com/konoma/fps-counter.git", :tag => "1.0.0" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files = "Sources/**/*.{swift,h,m}"
  s.public_header_files = "Sources/**/*.h"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.frameworks = "Foundation", "UIKit"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

end
