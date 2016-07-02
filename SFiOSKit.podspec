Pod::Spec.new do |spec|
  spec.name                     = "SFiOSKit"
  spec.version                  = "1.0.0"
  spec.summary                  = "SFiOSKit"
  spec.platform                 = :ios
  spec.license                  = { :type => 'Apache', :file => 'LICENSE' }
  spec.ios.deployment_target 	  = "5.0"
  spec.authors                  = { "Yang Zexin" => "yangzexin27@gmail.com" }
  spec.homepage                 = "https://github.com/yangzexin/SFLibraries"
  spec.source                   = { :git => "#{spec.homepage}.git", :tag => "#{spec.version}" }
  spec.requires_arc             = true
  spec.source_files = "SFiOSKit/SFiOSKit/*.{h,m}"
  
  spec.dependency "SFFoundation"
end
