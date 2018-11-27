Pod::Spec.new do |s|
  s.name         = "TezosKit"
  s.version      = "1.1.0"
  s.summary      = "TezosKit provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosKit provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage     = "https://github.com/keefertaylor/TezosKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Keefer Taylor" => "keefer@keefertaylor.com" }
  s.source       = { :git => "https://github.com/keefertaylor/TezosKit.git", :tag => "1.1.0" }
  s.source_files  = "Sources/**/*.swift", "Base58String/*.swift"
  s.exclude_files = "Sources/App/*.swift"
  s.swift_version = "4.2"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.dependency "BigInt", "~> 3.1"		
  s.dependency "MnemonicKit"
  s.dependency "Sodium", "~> 0.7.0"  
  
  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = "TezosKitTests/*.swift"
  end    
end
