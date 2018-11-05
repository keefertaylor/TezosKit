# MnemonicKit  &nbsp;&nbsp;&nbsp; [![Build Status](https://travis-ci.org/keefertaylor/MnemonicKit.svg?branch=master)](https://travis-ci.org/keefertaylor/MnemonicKit) &nbsp;&nbsp;&nbsp;  [![codecov](https://codecov.io/gh/keefertaylor/MnemonicKit/branch/master/graph/badge.svg)](https://codecov.io/gh/keefertaylor/MnemonicKit)
An implementation of BIP39 in Swift. MnemonicKit supports both English and Chinese mnemonics.

This library is originally forked from CKMnemonic: https://github.com/CikeQiu/CKMnemonic. Modifications are made for non-throwing APIs and support on OSX as well as iOS. Credit for most of this work is given to work_cocody@hotmail.com, qiuhongyang@askcoin.org.

## Installation

### CocoaPods
TezosKit supports installation via CocoaPods. You can depened on MnemonicKit by adding the following to your Podfile:

```
pod "MnemonicKit"
```

## Usage

### Generate a Mnemonic

```swift
  let englishMnemonic = Mnemonic.generateMnemonic(strength: 64, language: .english)
  let chineseMnemonic = Mnemonic.generateMnemonic(strength: 128, language: .chinese)
```


### Generate a Mnemonic from a Hex Representation

```swift
  let hexRepresentation: String = ...
  let mnemonic = Mnemonic.mnemonicString(from: hexRepresentation)
  print("Mnemonic: \(mnemonic)\nFrom hex string: \(hexRepresentation)")
```

### Generate a Seed String

```swift
  let englishMnemonic = Mnemonic.generateMnemonic(strength: 64, language: .english)
  let passphrase: String = ...
  let deterministicSeedString = Mnemonic.deterministicSeedString(from: mnemonicString,
                                                                 passphrase: passphrase,
                                                                 language: .english)
  print("Deterministic Seed String: \(deterministicSeedString)")
```

## Contributions

I am happy to accept pull requests. If anyone is able to reach the original authors of CKMnemonic, I am happy to merge this library upstream with them.

## License

MIT
