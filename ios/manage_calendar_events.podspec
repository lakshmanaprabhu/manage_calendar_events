#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'manage_calendar_events'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin which will help you add, edit and remove  the events from your (Android&#x2F;ios) device calendar'
  s.description      = <<-DESC
A flutter plugin which will help you add, edit and remove  the events from your (Android&#x2F;ios) device calendar
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end

