Pod::Spec.new do |s|
  s.name             = 'SVAlert'
  s.version          = '0.1.2'
  s.summary          = 'An Alert View replacement built with Swift'

  s.description      = <<-DESC
UIAlertView replacement with custom show/hide animations
                       DESC

  s.homepage         = 'https://github.com/svlaev/SVAlert'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stanislav Vlaev' => 'stanislav.vlaev@gmail.com' }
  s.source           = { :git => 'https://github.com/svlaev/SVAlert.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'SVAlert/Classes/**/*'
  s.resource_bundles = {
    'SVAlert' => [
        'SVAlert/Classes/**/*.xib'
    ]
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'pop'
end
