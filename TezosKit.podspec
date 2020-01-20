Pod::Spec.new do |s|
  s.name         = "TezosKit"
  s.version      = "4.2.0"
  s.summary      = "TezosKit provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosKit provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage     = "https://github.com/keefertaylor/TezosKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Keefer Taylor" => "keefer@keefertaylor.com" }
  s.source       = { :git => "https://github.com/keefertaylor/TezosKit.git", :tag => "4.2.0" }
  s.source_files  = "TezosKit/**/*.swift"
  s.swift_version = "4.2"
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.14"

  s.source_files = [ "TezosKit/**/*.swift", "Extensions/PromiseKit/*.swift"]
  s.frameworks = 'Foundation'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.14'

  s.dependency "BigInt"
  s.dependency "MnemonicKit"
  s.dependency "TezosCrypto"
  s.dependency "PromiseKit"

  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = ["Tests/Common/*.swift", "Tests/TezosKit/*.swift", "Tests/Extensions/PromiseKit/*.swift"]
  end
end
