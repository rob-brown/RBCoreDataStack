Pod::Spec.new do |s|
  s.name                = "RBCoreDataStack"
  s.version             = "0.1.5"
  s.summary             = "A simple wrapper around Core Data."
  s.description         = <<-DESC
                          A simple wrapper around Core Data designed to work with one or many Core Data stacks.
                          DESC
  s.homepage            = "https://github.com/rob-brown/RBCoreDataStack"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Robert Brown" => "robs.email.filter+RBCoreDataStack@gmail.com" }
  s.social_media_url    = "http://twitter.com/robby_brown"
  s.platform            = :ios, '6.0'
  s.source              = { :git => "https://github.com/rob-brown/RBCoreDataStack.git", :tag => s.version }
  s.source_files        = 'Source/Classes/*.{h,m}'
  s.public_header_files = 'Source/Classes/*.h'
  s.framework           = 'CoreData'
  s.requires_arc        = true
end
