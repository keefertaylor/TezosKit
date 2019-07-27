// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class MichelineTests: XCTestCase {
  static let michelineUnit = MichelineUnitParam()
  static let expectedMichelineUnitEncoding = "{\"prim\":\"unit\"}"

  static let michelineString = MichelineStringParam(string: "tezoskit")
  static let expectedMichelineStringEncoding = "{\"string\":\"tezoskit\"}"

  static let michelineInt = MichelineIntParam(int: 42)
  static let expectedMichelineIntEncoding = "{\"int\":\"42\"}"

  static let michelinePair = MichelinePairParam(left: michelineString, right: michelineInt)
  static let expectedMichelinePairEncoding = "{\"prim\":\"pair\",\"args\":[\(expectedMichelineStringEncoding),\(expectedMichelineIntEncoding)]}"

  static let michelineLeft = MichelineLeftParam(arg: michelineString)
  static let expectedMichelineLeftEncoding = "{\"prim\":\"left\",\"args\":[\(expectedMichelineStringEncoding)]}"

  static let michelineRight = MichelineRightParam(arg: michelineInt)
  static let expectedMichelineRightEncoding = "{\"prim\":\"right\",\"args\":[\(expectedMichelineIntEncoding)]}"

  static let michelineTrue = MichelineBoolParam(bool: true)
  static let expectedMichelineTrueEncoding = "{\"prim\":\"true\"}"

  static let michelineFalse = MichelineBoolParam(bool: false)
  static let expectedMichelineFalseEncoding = "{\"prim\":\"false\"}"

  static let michelineBytes = MichelineBytesParam(hex: "deadbeef")
  static let expectedMichelineBytesEncoding = "{\"bytes\":\"deadbeef\"}"

  static let michelineSome = MichelineSomeParam(some: michelineInt)
  static let expectedMichelineSomeEncoding = "{\"prim\":\"some\",\"args\":[\(expectedMichelineIntEncoding)]}"

  static let michelineNone = MichelineNoneParam()
  static let expectedMichelineNoneEncoding = "{\"prim\":\"none\"}"

  func testEncodeUnitToJSON() {
    let micheline = MichelineTests.michelineUnit
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineUnitEncoding))
  }


  func testEncodeStringToJSON() {
    let micheline = MichelineTests.michelineString
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineStringEncoding))
  }

  func testEncodeIntToJSON() {
    let micheline = MichelineTests.michelineInt
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineIntEncoding))
  }

  func testEncodePairToJSON() {
    let micheline = MichelineTests.michelinePair
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelinePairEncoding))
  }

  func testEncodeLeftToJSON() {
    let micheline = MichelineTests.michelineLeft
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineLeftEncoding))
  }

  func testEncodeRightToJSON() {
    let micheline = MichelineTests.michelineRight
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineRightEncoding))
  }

  func testEncodeTrueToJSON() {
    let micheline = MichelineTests.michelineTrue
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineTrueEncoding))
  }

  func testEncodeFalseToJSON() {
    let micheline = MichelineTests.michelineFalse
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineFalseEncoding))
  }

  func testEncodeHexBytesToJSON() {
    let micheline = MichelineTests.michelineBytes
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineBytesEncoding))
  }

  func testEncodeBinaryBytesToJSON() {
    let bytes = CodingUtil.hexToBin("deadbeef")!
    let micheline = MichelineBytesParam(bytes: bytes)!
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineBytesEncoding))
  }


  func testEncodeSomeToJSON() {
    let micheline = MichelineTests.michelineSome
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineSomeEncoding))
  }

  func testEncodeNoneToJSON() {
    let micheline = MichelineTests.michelineNone
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(MichelineTests.expectedMichelineNoneEncoding))
  }

  func testDexterInvocation() {
    let expected = "{\"prim\":\"right\",\"args\":[{\"prim\":\"right\",\"args\":[{\"prim\":\"left\",\"args\":[{\"prim\":\"pair\",\"args\":[{\"int\":\"10\"},{\"prim\":\"pair\",\"args\":[{\"int\":\"1\"},{\"string\":\"2020-06-29T18:00:21Z\"}]}]}]}]}]}"
    let micheline =
      MichelineRightParam(
        arg: MichelineRightParam(
          arg: MichelineLeftParam(
            arg: MichelinePairParam(
              left: MichelineIntParam(int: 10),
              right: MichelinePairParam(
                left: MichelineIntParam(int: 1),
                right: MichelineStringParam(string: "2020-06-29T18:00:21Z")
              )
            )
          )
        )
      )
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(expected))
  }

  /// Fix the expected input to the expected output of Swift's JSON serializer.
  ///
  /// Expected output is taken from the human readable version of the JSON serialization format. Swift outputs JSON
  /// keys either (1) non-deterministically or (2) ordered by key. This function re-orders the expected outputs of a
  /// input JSON string by key so that asserts can work properly.
  func fixExpected(_ expected: String) -> String {
    let data = expected.data(using: .utf8)!
    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    return JSONUtils.jsonString(for: dictionary)!
  }
}
