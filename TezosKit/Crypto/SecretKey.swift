// Copyright Keefer Taylor, 2019

import Base58Swift
import CryptoKit
import Foundation
import MnemonicKit
import secp256k1
import Sodium

/// Encapsulation of a secret key.
public struct SecretKey {
  /// Underlying bytes
  public let bytes: [UInt8]

  /// The elliptical curve this key is using.
  public let signingCurve: EllipticalCurve

  /// Base58Check representation of the key.
  public var base58CheckRepresentation: String {
    switch signingCurve {
    case .ed25519:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.Ed25519.secret)
    case .secp256k1:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.Secp256k1.secret)
    case .p256:
      return Base58.encode(message: bytes, prefix: Prefix.Keys.P256.secret)
    }
  }

  /// Initialize a key with the given mnemonic and passphrase.
  ///
  /// - Parameters:
  ///   - mnemonic: A mnemonic phrase to use.
  ///   - passphrase: An optional passphrase to use. Default is the empty string.
  ///   - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  /// - Returns: A representative secret key, or nil if an invalid mnemonic was given.
  public init?(mnemonic: String, passphrase: String = "", signingCurve: EllipticalCurve = .ed25519) {
    guard let seedString = Mnemonic.deterministicSeedString(from: mnemonic, passphrase: passphrase) else {
      return nil
    }
    self.init(
      seedString: String(seedString[..<seedString.index(seedString.startIndex, offsetBy: 64)]),
      signingCurve: signingCurve
    )
  }

  /// Initialize a key with the given hex seed string.
  ///
  ///  - Parameters:
  ///    - seedString a hex encoded seed string.
  ///    - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  /// - Returns: A representative secret key, or nil if the seed string was in an unexpected format.
  public init?(seedString: String, signingCurve: EllipticalCurve = .ed25519) {
    guard
      let seed = Sodium.shared.utils.hex2bin(seedString),
      let keyPair = Sodium.shared.sign.keyPair(seed: seed)
    else {
      return nil
    }

    self.init(keyPair.secretKey, signingCurve: .ed25519)
  }

  /// Initialize a secret key with the given base58check encoded string.
  ///
  ///  - Parameters:
  ///    - string: A base58check encoded string.
  ///    - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  public init?(_ string: String, signingCurve: EllipticalCurve = .ed25519) {
    switch signingCurve {
    case .ed25519:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.Ed25519.secret) else {
        return nil
      }
      self.init(bytes)
    case .secp256k1:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.Secp256k1.secret) else {
        return nil
      }
      self.init(bytes, signingCurve: .secp256k1)
    case .p256:
      guard let bytes = Base58.base58CheckDecodeWithPrefix(string: string, prefix: Prefix.Keys.P256.secret) else {
        return nil
      }
      self.init(bytes, signingCurve: .p256)
    }
  }

  /// Initialize a key with the given bytes.
  ///  - Parameters:
  ///    - bytes: Raw bytes of the private key.
  ///    - signingCurve: The elliptical curve to use for the key. Defaults to ed25519.
  public init(_ bytes: [UInt8], signingCurve: EllipticalCurve = .ed25519) {
    self.bytes = bytes
    self.signingCurve = signingCurve
  }

  /// Sign the given hex encoded string with the given key.
  ///
  /// - Parameters:
  ///   - hex: The hex string to sign.
  ///   - secretKey: The secret key to sign with.
  /// - Returns: A signature from the input.
  public func sign(hex: String) -> [UInt8]? {
    guard let bytes = Sodium.shared.utils.hex2bin(hex) else {
      return nil
    }
    return self.sign(bytes: bytes)
  }

  /// Sign the given hex encoded string with the given key.
  ///
  /// - Parameters:
  ///   - hex: The hex string to sign.
  ///   - secretKey: The secret key to sign with.
  /// - Returns: A signature from the input.
  public func sign(bytes: [UInt8]) -> [UInt8]? {
    guard let bytesToSign = prepareBytesForSigning(bytes) else {
      return nil
    }

    switch signingCurve {
    case .ed25519:
      return Sodium.shared.sign.signature(message: bytesToSign, secretKey: self.bytes)
    case .secp256k1:
      let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
      defer {
        secp256k1_context_destroy(context)
      }

      var signature = secp256k1_ecdsa_signature()
      let signatureLength = 64
      var output = [UInt8](repeating: 0, count: signatureLength)
      guard
        secp256k1_ecdsa_sign(context, &signature, bytesToSign, self.bytes, nil, nil) != 0,
        secp256k1_ecdsa_signature_serialize_compact(context, &output, &signature) != 0
      else {
        return nil
      }

      return output
    case .p256:
      if #available(iOS 13.0, *) {
//        let hashed = SHA256.hash(data: byt)

//        let b1 = SHA256Digest(bytesToSign)
        let b2: Data = Data(bytesToSign)
        let b3: Data = Data(Prefix.Watermark.operation + bytes)
//        let b4 = Blake2Hash()
        let b5 = SHA256.hash(data: b2)

        let secretKey = try! P256.Signing.PrivateKey(rawRepresentation: self.bytes)

        let sig1 = try! secretKey.signature(for: bytesToSign)
        let sig2 = try! secretKey.signature(for: b2)
        let sig3 = try! secretKey.signature(for: b3)
//        let sig4 = try! secretKey.signature(for: b4)
        let sig5 = try! secretKey.signature(for: b5)

        let signingKey = try! P256.Signing.PrivateKey(rawRepresentation: Sodium.shared.utils.hex2bin("e73465ba09a3749f5e64c2b716752d54e02ed55f7d807472d2a1c86a7893e79d")!)
        let signingPublicKey = signingKey.publicKey
        let signingPublicKeyData = signingPublicKey.rawRepresentation
        let initializedSigningPublicKey = try! P256.Signing.PublicKey(rawRepresentation: signingPublicKeyData)
        let dataToSign = "Some sample Data to sign.".data(using: .utf8)!
        let signature = try! signingKey.signature(for: dataToSign)
        if initializedSigningPublicKey.isValidSignature(signature, for: dataToSign) {
            print("The signature is valid.")
        }
        let reconstructed = try! P256.Signing.ECDSASignature(rawRepresentation: Sodium.shared.utils.hex2bin("24cc33210f79066c324d9f031dec89f8616ce8ee287a556bba901331b2b156663afc84ced0daca784a036ca6aaeb1f63ceb04cb4babfd9f87f2c018fc4c50cf6")!)
        if initializedSigningPublicKey.isValidSignature(reconstructed, for: dataToSign) {
          print("reconstructed is also valid.")
        }

        print("Expect: ")
        print("24cc33210f79066c324d9f031dec89f8616ce8ee287a556bba901331b2b156663afc84ced0daca784a036ca6aaeb1f63ceb04cb4babfd9f87f2c018fc4c50cf6")
        print("Actual: ")
        print(Sodium.shared.utils.bin2hex(try! signature.rawRepresentation.bytes))
        fatalError("You lose")

//        guard
//          let secretKey = try? P256.Signing.PrivateKey(rawRepresentation: self.bytes),
//          let signature = try? secretKey.signature(for: Data(bytesToSign))
//        else {
//          return nil
//        }
//        let der = signature.derRepresentation
//        guard let decoded = ASN1DERDecoder.decode(data: der) else {
//          return nil
//        }
//
//        // Scan forward until we hit a 0 byte (two 0 octets), indicating the end of the sequence in ASN1 DER formatting.
//        return decoded.reduce([UInt8](), { (sum, next) -> [UInt8] in
//          let filter = SimpleScanner(data: next.data)
//          if filter.scan(distance: 1)?.firstByte == 0x0 {
//            return sum + filter.scanToEnd()!
//          } else {
//            return sum + next.data
//          }
//        })
//      } else {
//        return nil
      }
      return []
    }
  }

  /// Prepare bytes for signing by applying a watermark and hashing.
  private func prepareBytesForSigning(_ bytes: [UInt8]) -> [UInt8]? {
    let watermarkedOperation = Prefix.Watermark.operation + bytes
    return Sodium.shared.genericHash.hash(message: watermarkedOperation, outputLength: 32)
  }
}

struct Blake2Hash: Digest {
  static var byteCount: Int = 32

  func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
    fatalError()
  }
}

extension SecretKey: CustomStringConvertible {
  public var description: String {
    return base58CheckRepresentation
  }
}

extension SecretKey: Equatable {
  public static func == (lhs: SecretKey, rhs: SecretKey) -> Bool {
    return lhs.base58CheckRepresentation == rhs.base58CheckRepresentation
  }
}

///Users/keefertaylor/fix_tk/tezoskit/Tests/UnitTests/TezosKit/SecretKeyTests.swift:185: error: -[TezosKitTests.SecretKeyTests testSignHex_p256] : XCTAssertEqual failed: ("
//  ("[210, 168, 28, 232, 166, 145, 94, 209, 125, 246, 159, 245, 201, 64, 21, 120, 30, 26, 7, 158, 101, 224, 71, 129, 131, 173, 150, 85, 69, 139, 92, 43, 71, 123, 176, 85, 209, 226, 31, 253, 149, 236, 175, 217, 36, 254, 82, 197, 72, 36, 198, 71, 32, 225, 3, 90, 139, 197, 173, 235, 102, 109, 80, 9]///") is not equal to ("
///[89, 163, 132, 130, 21, 91, 107, 117, 36, 165, 102, 107, 52, 52, 111, 79, 56, 45, 93, 29, 172, 33, 56, 213, 65, 174, 218, 228, 127, 217, 161, 80, 100, 133, 38, 90, 95, 218, 98, 228, 48, 24, 126, 196, 191, 224, 107, 164, 28, 11, 142, 115, 247, 222, 140, 171, 203, 255, 188, 132, 138, 145, 63, 220]")

/// An arbitrary ASN1 Decoder.
///
/// Taken from: https://gist.github.com/hfossli/00adac5c69116e7498e107d8d5ec61d4

struct ASN1DERDecoder {

  enum DERCode: UInt8 {

    //All sequences should begin with this
    case Sequence = 0x30

    //Type tags - add more here!
    case Integer = 0x02

    //A handy method to allow use to enumerate all data types
    static func allTypes() -> [DERCode] {
      return [
        .Integer
      ]
    }
  }

  static func decode(data: Data) -> [ASN1Object]? {

    let scanner = SimpleScanner(data: data)

    //Verify that this is actually a DER sequence
    guard scanner.scan(distance: 1)?.firstByte == DERCode.Sequence.rawValue else {
      return nil
    }

    //The second byte should equate to the length of the data, minus itself and the sequence type
    guard let expectedLength = scanner.scan(distance: 1)?.firstByte, Int(expectedLength) == data.count - 2 else {
      return nil
    }

    //An object we can use to append our output
    var output: [ASN1Object] = []

    //Loop through all the data
    while !scanner.isComplete {

      //Search the current position of the sequence for a known type
      var dataType: DERCode?
      for type in DERCode.allTypes() {
        if scanner.scan(distance: 1)?.firstByte == type.rawValue {
          dataType = type
        } else {
          scanner.rollback(distance: 1)
        }
      }

      guard let type = dataType else {
        //Unsupported type - add it to `DERCode.all()`
        return nil
      }

      guard let length = scanner.scan(distance: 1) else {
        //Expected a byte describing the length of the proceeding data
        return nil
      }

      let lengthInt = length.firstByte

      guard let actualData = scanner.scan(distance: Int(lengthInt)) else {
        //Expected to be able to scan `lengthInt` bytes
        return nil
      }

      let object = ASN1Object(type: type, data: actualData)
      output.append(object)
    }

    return output
  }
}

class SimpleScanner {
  let data: Data
  private(set) var position = 0

  init(data: Data) {
    self.data = data
  }

  var isComplete: Bool {
    return position >= data.count
  }

  func rollback(distance: Int) {
    position = position - distance

    if position < 0 {
      position = 0
    }
  }

  func scan(distance: Int) -> Data? {
    return popByte(s: distance)
  }

  func scanToEnd() -> Data? {
    return scan(distance: data.count - position)
  }

  private func popByte(s: Int = 1) -> Data? {

    guard s > 0 else { return nil }
    guard position <= (data.count - s) else { return nil }

    defer {
      position = position + s
    }

    return data.subdata(in: data.startIndex.advanced(by: position)..<data.startIndex.advanced(by: position + s))
  }
}

struct ASN1Object {
  public let type: ASN1DERDecoder.DERCode
  public let data: Data
}

extension Data {
  var firstByte: UInt8 {
    var byte: UInt8 = 0
    copyBytes(to: &byte, count: MemoryLayout<UInt8>.size)
    return byte
  }
}

// signed 123456 to 195,119,183,18,12,190,179,75,72,168,76,209,222,122,160,58,17,208,155,113,163,221,179,213,15,58,205,194,57,155,46,185,126,40,17,96,158,54,115,29,205,143,96,49,180,124,135,239,126,205,190,193,245,116,15,67,216,22,24,66,61,242,213,163
