Pod::Spec.new do |s|
  s.name                = "RBCoreDataStack"
  s.version             = "0.0.2"
  s.summary             = "A simple wrapper around Core Data."
  s.description         = <<-DESC
                          A simple wrapper around Core Data.
                          DESC
  s.homepage            = "https://github.com/rob-brown/RBCoreDataStack"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Robert Brown" => "ammoknight@gmail.com" }
  s.social_media_url    = "http://twitter.com/robby_brown"
  s.platform            = :ios, '7.0'
  s.source              = { :git => "git@github.com:rob-brown/RBCoreDataStack.git", :tag => "0.0.2" }
  s.source_files        = 'Source/Classes/*.{h,m}'
  s.public_header_files = 'Source/Classes/*.h'
  s.framework           = 'CoreData'
  s.requires_arc        = true
end
