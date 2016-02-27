
Pod::Spec.new do |s|

  s.name         = 'Matisse'
  s.version      = '0.1.0'
  s.homepage     = 'https://github.com/konoma/matisse'
  s.summary      = 'Matisse is an image retrieval and caching library for iOS inspired by Picasso.'
  s.description  = """
  With Matisse you can download and display an image in an image view with a single line of code.
  Matisse takes care of downloading, caching and showing the image in an UIImageView. If you use it in a UITableViewDataSource it also makes sure that
  the correct image is shown even in case of a cell reuse.
  """

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Markus Gasser' => 'markus.gasser@konoma.ch' }
  
  s.source       = { :git => 'git@bitbucket.org:foensi/matisse.git' }
  s.platform     = :ios, '8.0'
  
  s.requires_arc = true

  s.frameworks   = 'Foundation', 'UIKit'
  s.source_files = 'Sources/**/*.{h,m,mm,swift}'
end
