Pod::Spec.new do |s|
  s.name         = "TezosKitLib"
  s.version      = "0.0.1"
  s.summary      = "TezosKit provides a Swift based toolchain for interacting with the Tezos blockchain"
  s.description  = <<-DESC
  TezosKit provides utilities for interacting with the Tezos Blockchain over an RPC API.
                   DESC

  s.homepage     = "https://github.com/keefertaylor/TezosKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Keefer Taylor" => "keefer@keefertaylor.com" }
  s.source       = { :git => "https://github.com/keefertaylor/TezosKit.git", :commit => "06d64d0be02d075689ee8b3b4ee7d295f4ea0348" }
  s.source_files  = "Sources/**/*.swift", "Base58String/*.swift"
  s.exclude_files = "Sources/App/*.swift"
  s.swift_version = '4.2'
  s.ios.deployment_target = '8.0'
  # TODO: Support OSX when supported by dependencies.
  # s.osx.deployment_target = '10.10'
		
  s.dependency "CKMnemonic"
  s.dependency 'Sodium', '~> 0.7.0'
  s.dependency 'BigInt', '~> 3.1'
end
