//
//  Asn.swift
//  TezosKit
//
//  Created by Keefer Taylor on 5/2/19.
//  Copyright © 2019 Keefer Taylor. All rights reserved.
//

import Foundation

//
//  ASN1.swift
//  ASN1
//
//  Created by Håvard Fossli on 29.08.2018.
//  Copyright © 2018 Håvard Fossli. All rights reserved.
//
import Foundation

struct ASN1DERDecoder {

  enum DERCode: UInt8 {

    //All sequences should begin with this
    case Sequence = 0x30

    //Type tags - add more here!
    case Integer = 0x02

    //A handy method to allow use to enumerate all data types
    static func allTypes() -> [DERCode] {
      return [
        .Integer,
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

//
//enum ASN1 {
//  enum DER {}
//}
//
//extension ASN1.DER {
//
//  enum Error: Swift.Error {
//    case badLength
//    case missingTagIdentifier
//    case badObjectIdentifier
//  }
//
//  enum TagIdentifier: UInt8 {
//    case sequence = 0x30
//    case integer = 0x02
//    case objectIdentifier = 0x06
//  }
//
//  struct Decoder {}
//  struct Encoder {}
//
//  indirect enum TLV: Equatable {
//    case sequence([TLV])
//    case integer(Data)
//    case objectIdentifier(String)
//    case unknown(Data)
//  }
//}
//
//extension ASN1.DER.TLV {
//
//  var tagIdentifier: UInt8 {
//    switch self {
//    case .sequence:
//      return ASN1.DER.TagIdentifier.sequence.rawValue
//    case .integer:
//      return ASN1.DER.TagIdentifier.integer.rawValue
//    case .objectIdentifier:
//      return ASN1.DER.TagIdentifier.objectIdentifier.rawValue
//    case .unknown(let data):
//      return data.first ?? 0
//    }
//  }
//
//  static func ==(lhs: ASN1.DER.TLV, rhs: ASN1.DER.TLV) -> Bool {
//    switch (lhs, rhs) {
//    case (let .sequence(a), let .sequence(b)):
//      return a == b
//    case (let .integer(a), let .integer(b)):
//      return a == b
//    case (let .objectIdentifier(a), let .objectIdentifier(b)):
//      return a == b
//    case (let .unknown(a), let .unknown(b)):
//      return a == b
//    default:
//      return false
//    }
//  }
//}
//
//extension ASN1.DER.Encoder {
//
//  static func base128Encode(_ int: Int) -> Data {
//    var result = Data()
//    var value = int
//    repeat {
//      let byte = UInt8(value & 0b0111_1111) | 0b1000_0000
//      result.insert(byte, at: 0)
//      value >>= 7
//    } while value != 0
//    result.append((result.popLast() ?? 0) & 0b0111_1111)
//    return result
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-encoded-length-and-value-bytes
//  static func LENGTH(count: Int) -> Data {
//    if count < 0 {
//      return Data([0])
//    } else if count < 128 {
//      return Data([UInt8(count)])
//    } else {
//      var value = count
//      var result = Data()
//      repeat {
//        let byte = UInt8(value & 0b1111_1111)
//        value >>= 8
//        result.insert(byte, at: 0)
//      } while value != 0
//      let firstByte = UInt8(128 + result.count)
//      result.insert(firstByte, at: 0)
//      return result
//    }
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-integer
//  static func INTEGER(_ int: Data) -> Data {
//    return int
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-object-identifier
//  static func OBJECT_IDENTIFIER(_ id: String) -> Data {
//    var ints = id.split(separator: ".").map { Int(String($0)) ?? 0 }
//    let firstNode = ints.count > 0 ? ints.removeFirst() : 0
//    let secondNode = ints.count > 1 ? ints.removeFirst() : 0
//    let combined = UInt8(firstNode * 40 + secondNode) // fixme: check size
//    let mapped = ints.map {
//      base128Encode($0)
//      }.joined()
//    return Data([combined]) + Data(mapped)
//  }
//
//  static func bytes(_ identifier: ASN1.DER.TagIdentifier, bytes: Data) -> Data {
//    switch identifier {
//    case .sequence,
//         .integer,
//         .objectIdentifier:
//      return Data([identifier.rawValue]) + LENGTH(count: bytes.count) + bytes
//    }
//  }
//
//  static func encode(_ tlv: ASN1.DER.TLV) throws -> Data {
//    switch tlv {
//    case .sequence(let tlvs):
//      let encoded = try tlvs.map { sequence in
//        return try encode(sequence)
//        }.joined()
//      return bytes(.sequence, bytes: Data(encoded))
//    case .integer(let int):
//      return bytes(.integer, bytes: INTEGER(int))
//    case .objectIdentifier(let id):
//      return bytes(.objectIdentifier, bytes: OBJECT_IDENTIFIER(id))
//    case .unknown(let data):
//      return data
//    }
//  }
//
//}
//
//extension ASN1.DER.Decoder {
//
//  static func firstBitIsZero(_ value: UInt8) -> Bool {
//    return value & 0b1000_0000 == 0
//  }
//
//  static func lastSevenBits(_ value: UInt8) -> UInt8 {
//    return value & 0b0111_1111
//  }
//
//  static func base128Decode(read bytes: @autoclosure () -> UInt8?) -> Int? {
//    var node: Int = 0
//    while let byte = bytes() {
//      node <<= 7
//      node |= Int(byte & 0b0111_1111)
//      if byte & 0b1000_0000 == 0 {
//        return node
//      }
//    }
//    return nil
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-integer
//  static func INTEGER(value: Data) throws -> Data {
//    return value
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-integer
//  static func OBJECT_ID_INT(value: Data) throws -> Int {
//    var result = Int64(0)
//    for tuple in value.reversed().enumerated() {
//      result += Int64(tuple.element) << (Int64(tuple.offset) * 8)
//      guard result < Int.max else { // fixme
//        throw ASN1.DER.Error.badLength
//      }
//    }
//    return Int(result)
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-object-identifier
//  static func OBJECT_IDENTIFIER(value: Data) throws -> String {
//    var bytes = value
//    guard let firstTwoNodes = bytes.popFirst() else {
//      throw ASN1.DER.Error.badObjectIdentifier
//    }
//    let firstNode = Int(firstTwoNodes / 40)
//    let secondNode = Int(firstTwoNodes % 40)
//    var nodes: [Int] = [firstNode, secondNode]
//    while let node = base128Decode(read: bytes.popFirst()) {
//      nodes.append(node)
//    }
//    return nodes.map { String($0) }.joined(separator: ".")
//  }
//
//  // https://docs.microsoft.com/nb-no/windows/desktop/SecCertEnroll/about-encoded-length-and-value-bytes
//  static func LENGTH(bytes: inout Data) throws -> Int {
//    guard let firstByte = bytes.popFirst() else {
//      throw ASN1.DER.Error.badLength
//    }
//    if firstBitIsZero(firstByte) {
//      return Int(firstByte)
//    } else {
//      let numberOfLengthBytes = Int(lastSevenBits(firstByte))
//      let lengthBytes = bytes.prefix(numberOfLengthBytes)
//      guard lengthBytes.count == numberOfLengthBytes else {
//        throw ASN1.DER.Error.badLength
//      }
//      bytes.removeFirst(numberOfLengthBytes)
//      return try ASN1.DER.Decoder.OBJECT_ID_INT(value: lengthBytes)
//    }
//  }
//
//  static func parse(_ bytes: inout Data) throws -> ASN1.DER.TLV {
//    let received = bytes
//    guard let tagIdentifier = bytes.popFirst() else {
//      throw ASN1.DER.Error.missingTagIdentifier
//    }
//    if let knownIdentifier = ASN1.DER.TagIdentifier(rawValue: tagIdentifier) {
//      let length = try LENGTH(bytes: &bytes)
//      guard length <= bytes.count else {
//        throw ASN1.DER.Error.badLength
//      }
//      switch knownIdentifier {
//      case .sequence:
//        var tlvs: [ASN1.DER.TLV] = []
//        var sequenceBytes = bytes.prefix(length)
//        while sequenceBytes.count > 0 {
//          let tlv = try parse(&sequenceBytes)
//          tlvs.append(tlv)
//        }
//        bytes.removeFirst(length)
//        return .sequence(tlvs)
//      case .integer:
//        let int = try INTEGER(value: bytes.prefix(length))
//        bytes.removeFirst(length)
//        return .integer(int)
//      case .objectIdentifier:
//        let id = try OBJECT_IDENTIFIER(value: bytes.prefix(length))
//        bytes.removeFirst(length)
//        return .objectIdentifier(id)
//      }
//    } else {
//      bytes.removeAll()
//      return .unknown(received)
//    }
//  }
//}
