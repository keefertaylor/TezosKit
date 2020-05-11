Pod::Spec.new do |s|
  s.name         = "TezosKit"
  s.version      = "5.2.0"
  s.summary      = "TezosKit provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosKit provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage     = "https://github.com/keefertaylor/TezosKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Keefer Taylor" => "keefer@keefertaylor.com" }
  s.source       = { :git => "https://github.com/keefertaylor/TezosKit.git", :tag => "5.2.0" }
  s.source_files  = "TezosKit/**/*.swift"
  s.swift_version = "5.1"
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.14"

  s.source_files = [ "TezosKit/**/*.swift", "Extensions/PromiseKit/*.swift"]
  s.frameworks = 'Foundation', "Security"

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.14'

  s.dependency "BigInt", "~> 5.0.0"
  s.dependency "MnemonicKit", "~> 1.3.12"
  s.dependency "PromiseKit", "~> 6.13.1"
  s.dependency "Base58Swift", "~> 2.1.10"
  s.dependency "CryptoSwift", "~> 1.3.0"
  s.dependency "Sodium", "~> 0.8.0"
  s.dependency "secp256k1.swift", "~> 0.1.4"
  s.ios.dependency "DTTJailbreakDetection", "~> 0.4.0"

  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = ["Tests/Common/*.swift", "Tests/TezosKit/*.swift", "Tests/Extensions/PromiseKit/*.swift"]
  end
end
