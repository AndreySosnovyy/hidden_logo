Pod::Spec.new do |s|
  s.name             = 'hidden_logo'
  s.version          = '1.2.0'
  s.summary          = 'Flutter plugin to display hidden logo behind hardware barriers for iPhones'
  s.description      = <<-DESC
A Flutter plugin that allows you to add widgets under the Notch or Dynamic Island
for iPhones. They will only be visible in certain scenarios like screenshots.
                       DESC
  s.homepage         = 'https://github.com/AndreySosnovyy/hidden_logo'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Andrey Sosnovyy' => 'rphb018@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'hidden_logo/Sources/hidden_logo/**/*.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
end
