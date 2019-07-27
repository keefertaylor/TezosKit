// Copyright Keefer Taylor, 2019

import TezosKit
import XCTest

final class MichelineTests: XCTestCase {
  static let michelineUnit = MichelineUnit()
  static let expectedMichelineUnitEncoding = "{\"prim\":\"unit\"}"

  // TODO: Use test objects?
  static let michelineString = MichelineString(string: "tezoskit")
  static let expectedMichelineStringEncoding = "{\"string\":\"tezoskit\"}"

  static let michelineInt = MichelineInt(int: 42)
  static let expectedMichelineIntEncoding = "{\"int\":\"42\"}"

  static let michelinePair = MichelinePair(left: michelineString, right: michelineInt)
  static let expectedMichelinePairEncoding = "{\"prim\":\"pair\",\"args\":[\(expectedMichelineStringEncoding),\(expectedMichelineIntEncoding)]}"

  static let michelineLeft = MichelineLeft(arg: michelineString)
  static let expectedMichelineLeftEncoding = "{\"prim\":\"left\",\"args\":[\(expectedMichelineStringEncoding)]}"

  static let michelineRight = MichelineRight(arg: michelineInt)
  static let expectedMichelineRightEncoding = "{\"prim\":\"right\",\"args\":[\(expectedMichelineIntEncoding)]}"

  static let michelineTrue = MichelineBool(bool: true)
  static let expectedMichelineTrueEncoding = "{\"prim\":\"true\"}"

  static let michelineFalse = MichelineBool(bool: false)
  static let expectedMichelineFalseEncoding = "{\"prim\":\"false\"}"

  static let michelineBytes = MichelineBytes(hex: "deadbeef")
  static let expectedMichelineBytesEncoding = "{\"bytes\":\"deadbeef\"}"

  static let michelineSome = MichelineSome(some: michelineInt)
  static let expectedMichelineSomeEncoding = "{\"prim\":\"some\",\"args\":[\(expectedMichelineIntEncoding)]}"

  static let michelineNone = MichelineNone()
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

  func testEncodeBytesToJSON() {
    let micheline = MichelineTests.michelineBytes
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
      MichelineRight(
        arg: MichelineRight(
          arg: MichelineLeft(
            arg: MichelinePair(
              left: MichelineInt(int: 10),
              right: MichelinePair(
                left: MichelineInt(int: 1),
                right: MichelineString(string: "2020-06-29T18:00:21Z")
              )
            )
          )
        )
      )
    let encoded = JSONUtils.jsonString(for: micheline.json)
    XCTAssertEqual(encoded, fixExpected(expected))
  }

  // TODO: Cleanup this fn.
  func fixExpected(_ expected: String) -> String {
    let data = expected.data(using: .utf8)!
    let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
    return JSONUtils.jsonString(for: dictionary)!
  }
}
