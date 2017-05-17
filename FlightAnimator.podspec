Pod::Spec.new do |s|
  s.name         = "FlightAnimator"
  s.version      = "0.9.8"
  s.summary      = "Natural Animation Engine on Top of Core Animation"
  s.homepage     = "https://github.com/AntonTheDev/FlightAnimator/"
  s.license      = 'MIT'
  s.author       = { "Anton Doudarev" => "antonthedev@gmail.com" }
  s.source       = { :git => 'https://github.com/AntonTheDev/FlightAnimator.git', :tag => s.version }

  s.platform     = :ios, "8.0"
  s.platform     = :tvos, "9.0"

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = "Source/*.*", "Source/Extensions/*.*", "Source/FAAnimation/*.*", "Source/FAInterpolation/*.*"
end
