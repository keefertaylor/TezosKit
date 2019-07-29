// Copyright Keefer Taylor, 2019

@testable import TezosKit
import XCTest

// swiftlint:disable force_cast
// swiftlint:disable force_try
// swiftlint:disable line_length

final class MichelsonTests: XCTestCase {
  static let michelsonUnit = UnitMichelsonParameter()
  static let expectedMichelsonUnitEncoding = "{\"prim\":\"unit\"}"

  static let michelsonString = StringMichelsonParameter(string: "tezoskit")
  static let expectedMichelsonStringEncoding = "{\"string\":\"tezoskit\"}"

  static let michelsonInt = IntMichelsonParameter(int: 42)
  static let expectedMichelsonIntEncoding = "{\"int\":\"42\"}"

  static let michelsonPair = PairMichelsonParameter(left: michelsonString, right: michelsonInt)
  static let expectedMichelsonPairEncoding =
    "{\"prim\":\"Pair\",\"args\":[\(expectedMichelsonStringEncoding),\(expectedMichelsonIntEncoding)]}"

  static let michelsonLeft = LeftMichelsonParameter(arg: michelsonString)
  static let expectedMichelsonLeftEncoding = "{\"prim\":\"Left\",\"args\":[\(expectedMichelsonStringEncoding)]}"

  static let michelsonRight = RightMichelsonParameter(arg: michelsonInt)
  static let expectedMichelsonRightEncoding = "{\"prim\":\"Right\",\"args\":[\(expectedMichelsonIntEncoding)]}"

  static let michelsonTrue = BoolMichelsonParameter(bool: true)
  static let expectedMichelsonTrueEncoding = "{\"prim\":\"true\"}"

  static let michelsonFalse = BoolMichelsonParameter(bool: false)
  static let expectedMichelsonFalseEncoding = "{\"prim\":\"false\"}"

  static let michelsonBytes = BytesMichelsonParameter(hex: "deadbeef")
  static let expectedMichelsonBytesEncoding = "{\"bytes\":\"deadbeef\"}"

  static let michelsonSome = SomeMichelsonParameter(some: michelsonInt)
  static let expectedMichelsonSomeEncoding = "{\"prim\":\"some\",\"args\":[\(expectedMichelsonIntEncoding)]}"

  static let michelsonNone = NoneMichelsonParameter()
  static let expectedMichelsonNoneEncoding = "{\"prim\":\"none\"}"

  func testEncodeUnitToJSON() {
    let michelson = MichelsonTests.michelsonUnit
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonUnitEncoding))
  }

  func testEncodeStringToJSON() {
    let michelson = MichelsonTests.michelsonString
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonStringEncoding))
  }

  func testEncodeIntToJSON() {
    let michelson = MichelsonTests.michelsonInt
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonIntEncoding))
  }

  func testEncodePairToJSON() {
    let michelson = MichelsonTests.michelsonPair
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonPairEncoding))
  }

  func testEncodeLeftToJSON() {
    let michelson = MichelsonTests.michelsonLeft
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonLeftEncoding))
  }

  func testEncodeRightToJSON() {
    let michelson = MichelsonTests.michelsonRight
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonRightEncoding))
  }

  func testEncodeTrueToJSON() {
    let michelson = MichelsonTests.michelsonTrue
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonTrueEncoding))
  }

  func testEncodeFalseToJSON() {
    let michelson = MichelsonTests.michelsonFalse
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonFalseEncoding))
  }

  func testEncodeHexBytesToJSON() {
    let michelson = MichelsonTests.michelsonBytes
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonBytesEncoding))
  }

  func testEncodeBinaryBytesToJSON() {
    let bytes = CodingUtil.hexToBin("deadbeef")!
    let michelson = BytesMichelsonParameter(bytes: bytes)!
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonBytesEncoding))
  }

  func testEncodeSomeToJSON() {
    let michelson = MichelsonTests.michelsonSome
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonSomeEncoding))
  }

  func testEncodeNoneToJSON() {
    let michelson = MichelsonTests.michelsonNone
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(MichelsonTests.expectedMichelsonNoneEncoding))
  }

  func testCustomParameter() {
    let jsonDict: [String: Any] = [
      MichelineConstants.primitive: MichelineConstants.left,
      MichelineConstants.args: [ MichelsonTests.michelsonInt.networkRepresentation ],
      "annots": [ "@TezosKitAnnotation" ]
    ]
    let expected = "{\"prim\":\"Left\",\"args\":[\(MichelsonTests.expectedMichelsonIntEncoding)],\"annots\":[\"@TezosKitAnnotation\"]}"
    let michelson = CustomMichelsonParameter(networkRepresentation: jsonDict)

    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, fixExpected(expected))
  }

  // MARK: - Dexter / Token Contract

  func testTransferTokens() {
    let param = LeftMichelsonParameter(
      arg: PairMichelsonParameter(
        left: StringMichelsonParameter(string: "tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3"),
        right: PairMichelsonParameter(
          left: StringMichelsonParameter(string: "tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW"),
          right: IntMichelsonParameter(int: 10)
        )
      )
    )

    let expected = "{ \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"string\": \"tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3\" }, { \"prim\": \"Pair\", \"args\": [ { \"string\": \"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\" }, { \"int\": \"10\" } ] } ] } ] }"
    let json = JSONUtils.jsonString(for: param.networkRepresentation)
    XCTAssertEqual(json, fixExpected(expected))
  }

  // MARK: - Dexter / Exchange

  func testAddLiquidity() {
    let param = LeftMichelsonParameter(
      arg: LeftMichelsonParameter(
        arg: PairMichelsonParameter(
          left: IntMichelsonParameter(int: 1),
          right: PairMichelsonParameter(
            left: IntMichelsonParameter(int: 100),
            right: StringMichelsonParameter(string: "2020-06-29T18:00:21Z")
          )
        )
      )
    )
    let expected = "{ \"prim\": \"Left\", \"args\": [ { \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"int\": \"1\" }, { \"prim\": \"Pair\", \"args\": [ { \"int\": \"100\" }, { \"string\": \"2020-06-29T18:00:21Z\" } ] } ] } ] } ] }"

    let json = JSONUtils.jsonString(for: param.networkRepresentation)
    XCTAssertEqual(json, fixExpected(expected))
  }

  func testBuyTokens() {
    let param = RightMichelsonParameter(
      arg: LeftMichelsonParameter(
        arg: PairMichelsonParameter(
          left: IntMichelsonParameter(int: 1),
          right: StringMichelsonParameter(string: "2020-06-29T18:00:21Z")
        )
      )
    )
    let expected = "{\"prim\":\"Right\",\"args\":[{\"prim\":\"Left\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"int\":\"1\"},{\"string\":\"2020-06-29T18:00:21Z\"}]}]}]}"

    let json = JSONUtils.jsonString(for: param.networkRepresentation)
    XCTAssertEqual(json, fixExpected(expected))
  }

  func testBuyTez() {
    let param = RightMichelsonParameter(
      arg: RightMichelsonParameter(
        arg: LeftMichelsonParameter(
          arg: PairMichelsonParameter(
            left: IntMichelsonParameter(int: 10),
            right: PairMichelsonParameter(
              left: IntMichelsonParameter(int: 1),
              right: StringMichelsonParameter(string: "2020-06-29T18:00:21Z")
            )
          )
        )
      )
    )

    let expected = "{ \"prim\": \"Right\", \"args\": [ { \"prim\": \"Right\", \"args\": [ { \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"int\": \"10\" }, { \"prim\": \"Pair\", \"args\":[ { \"int\": \"1\" }, { \"string\": \"2020-06-29T18:00:21Z\" } ] } ] } ] } ] } ] }"

    let json = JSONUtils.jsonString(for: param.networkRepresentation)
    XCTAssertEqual(json, fixExpected(expected))
  }

  func testRemoveLiquidity() {
    let param = LeftMichelsonParameter(
      arg: RightMichelsonParameter(
        arg: PairMichelsonParameter(
          left: PairMichelsonParameter(
            left: IntMichelsonParameter(int: 100),
            right: IntMichelsonParameter(int: 1)
          ),
          right: PairMichelsonParameter(
            left: IntMichelsonParameter(int: 1),
            right: StringMichelsonParameter(string: "2020-06-29T18:00:21Z")
          )
        )
      )
    )
    let expected = "{ \"prim\": \"Left\", \"args\": [ { \"prim\": \"Right\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"int\": \"100\" }, { \"int\": \"1\" } ] }, { \"prim\": \"Pair\", \"args\": [ { \"int\": \"1\" }, { \"string\": \"2020-06-29T18:00:21Z\" } ] } ] } ] } ] }"

    let json = JSONUtils.jsonString(for: param.networkRepresentation)
    XCTAssertEqual(json, fixExpected(expected))
  }

  // MARK: - Helpers

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
