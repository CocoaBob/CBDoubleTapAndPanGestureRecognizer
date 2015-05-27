Pod::Spec.new do |s|
  s.name         = "CBDoubleTapAndPanGestureRecognizer"
  s.version      = "1.0.0"
  s.summary      = "A UIGestureRecognizer subclass inspired by Google Maps."
  s.description  = <<-DESC
                   A UIGestureRecognizer subclass allows you to double tap and pan for zooming in/out like Google Maps.
                   DESC
  s.homepage     = "https://github.com/CocoaBob/CBDoubleTapAndPanGestureRecognizer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author    = "CocoaBob"
  s.social_media_url = 'https://twitter.com/CocoaBob'
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/CocoaBob/CBDoubleTapAndPanGestureRecognizer.git", :tag => "1.0.0" }
  s.source_files  = "CBDoubleTapAndPanGestureRecognizer"
  s.requires_arc = true
end
