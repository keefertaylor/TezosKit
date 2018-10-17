# CKMnemonic
An implementation of BIP39 used Swift

<!--[![CI Status](http://img.shields.io/travis/work_cocody@hotmail.com/CKMnemonic.svg?style=flat)](https://travis-ci.org/work_cocody@hotmail.com/CKMnemonic)-->
[![Version](https://img.shields.io/cocoapods/v/CKMnemonic.svg?style=flat)](http://cocoapods.org/pods/CKMnemonic)
[![License](https://img.shields.io/cocoapods/l/CKMnemonic.svg?style=flat)](http://cocoapods.org/pods/CKMnemonic)
[![Platform](https://img.shields.io/cocoapods/p/CKMnemonic.svg?style=flat)](http://cocoapods.org/pods/CKMnemonic)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

```Swift
do {
    let language: CKMnemonicLanguageType = .chinese
    let mnemonic = try CKMnemonic.generateMnemonic(strength: 128, language: language)
    print(mnemonic)
    let seed = try CKMnemonic.deterministicSeedString(from: mnemonic, passphrase: "Test", language: language)
    print(seed)
} catch {
    print(error)
}
```

## Requirements
Xcode 8.3.2 with Swift 3.0

## Installation

CKMnemonic is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CKMnemonic"
```

## Author

work_cocody@hotmail.com, qiuhongyang@askcoin.org

## License

CKMnemonic is available under the MIT license. See the LICENSE file for more info.
