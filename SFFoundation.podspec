Pod::Spec.new do |spec|
  spec.name                     = "SFFoundation"
  spec.version                  = "1.0.0"
  spec.summary                  = "SFFoundation"
  spec.platform                 = :ios
  spec.license                  = { :type => 'Apache', :file => 'LICENSE' }
  spec.ios.deployment_target 	  = "5.0"
  spec.osx.deployment_target    = "10.7"
  spec.authors                  = { "Yang Zexin" => "yangzexin27@gmail.com" }
  spec.homepage                 = "https://github.com/yangzexin/SFLibraries"
  spec.source                   = { :git => "#{spec.homepage}.git", :tag => "#{spec.version}" }
  spec.requires_arc             = true

  spec.subspec "MRC" do |sp|
    sp.source_files = "SFFoundation/SFFoundation/SFObjcProperty.{h,m}", "SFFoundation/SFFoundation/SFRuntimeUtils.{h,m}"
    sp.requires_arc = false
  end

  spec.subspec "ARC" do |sp|
    sp.dependency 'SFFoundation/MRC'
    sp.source_files = "SFFoundation/SFFoundation/*.{h,m}"
    sp.exclude_files = "SFFoundation/SFFoundation/SFObjcProperty.{h,m}", "SFFoundation/SFFoundation/SFRuntimeUtils.{h,m}"
    sp.requires_arc = true
  end
end
