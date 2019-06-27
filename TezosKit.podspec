Pod::Spec.new do |s|
  s.name         = "TezosKit"
  s.version      = "3.2.1"
  s.summary      = "TezosKit provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosKit provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage     = "https://github.com/keefertaylor/TezosKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Keefer Taylor" => "keefer@keefertaylor.com" }
  s.source       = { :git => "https://github.com/keefertaylor/TezosKit.git", :tag => "3.2.1" }
  s.source_files  = "TezosKit/**/*.swift"
  s.swift_version = "4.2"
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.14"
  s.default_subspecs = 'TezosKitCore', 'TezosKitPromises'
  
  s.subspec 'TezosKitCore' do |ss|
      ss.source_files = "TezosKit/**/*.swift"
      ss.frameworks = 'Foundation'
    
      ss.ios.deployment_target = '10.0'
      ss.osx.deployment_target = '10.14'
      
      ss.dependency "BigInt"
      ss.dependency "MnemonicKit"
      ss.dependency "TezosCrypto"
  end
  
  s.subspec 'TezosKitPromises' do |ss|
      ss.source_files = "Extensions/PromiseKit/*.swift"
      ss.frameworks = 'Foundation'
    
      ss.ios.deployment_target = '10.0'
      ss.osx.deployment_target = '10.14'
      
      ss.dependency 'TezosKit/TezosKitCore'      
      ss.dependency "PromiseKit"
  end

  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = ["Tests/*.swift", "Tests/TezosKit/*.swift", "Tests/Extensions/PromiseKit/*.swift"]
  end    
end
