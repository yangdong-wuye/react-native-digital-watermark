require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-digital-watermark"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-digital-watermark
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-digital-watermark"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-digital-watermark.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift,hpp,cpp,mm}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "OpenCV", "~> 3.4.6"

  s.static_framework = true
  # ...
  # s.dependency "..."
end

