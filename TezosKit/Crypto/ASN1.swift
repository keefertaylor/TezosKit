/// An arbitrary ASN1 Decoder.
///
/// Taken from: https://gist.github.com/hfossli/00adac5c69116e7498e107d8d5ec61d4

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
