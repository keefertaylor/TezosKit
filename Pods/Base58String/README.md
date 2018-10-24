# Swift Base58String

Base58String is based off of go-base58 string, available [here](https://github.com/jbenet/go-base58).

This library provides an idiomatic Swift version of the go library.

## How to Install

### Swift Package Manager

Add the following to your Package.swift file in "dependencies".

```
.package(url: "https://github.com/cloutiertyler/Base58String.git", from: "0.1.0")
```

### CocoaPods

Add the following to your Podfile:

```
pod 'Base58String', :git => 'https://github.com/keefertaylor/Base58String.git'	
```

## Usage

```Swift
import Foundation
import Base58String

func test() {

    let data = Data([222, 100, 50])
    print("Data: \(Array(data))")

    let encoded = String(base58Encoding: data)
    print("Encoded string: \(encoded)")

    let decoded = Data(base58Decoding: encoded)!
    print("Decoded data: \(Array(decoded))")

}
```
