Pod::Spec.new do |s|
  s.name         = "FlightAnimator"
  s.version      = "0.8.0"
  s.summary      = "Natural Animation Engine on Top of Core Animation"
  s.homepage     = "https://github.com/AntonTheDev/FlightAnimator/"
  s.license      = 'MIT'
  s.author       = { "Anton Doudarev" => "antonthedev@gmail.com" }
  s.source       = { :git => 'https://github.com/AntonTheDev/FlightAnimator.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = "Source/*.*", "Source/FAAnimation/Extensions/*.*", "Source/Extras/*.*", "Source/FAAnimatable/*.*", "Source/FAAnimatable/Implementation/*.*", "Source/FAAnimation/*.*","Source/FAInterpolation/*.*" 
  s.requires_arc = true
  s.frameworks = 'UIKit'
end
