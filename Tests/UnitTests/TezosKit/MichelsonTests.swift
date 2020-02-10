// Copyright Keefer Taylor, 2019

@testable import TezosKit
import XCTest

// swiftlint:disable line_length

final class MichelsonTests: XCTestCase {
  static let michelsonUnit = UnitMichelsonParameter()
  static let expectedMichelsonUnitEncoding = "{\"prim\":\"Unit\"}"

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
  static let expectedMichelsonTrueEncoding = "{\"prim\":\"True\"}"

  static let michelsonFalse = BoolMichelsonParameter(bool: false)
  static let expectedMichelsonFalseEncoding = "{\"prim\":\"False\"}"

  static let michelsonBytes = BytesMichelsonParameter(hex: "deadbeef")
  static let expectedMichelsonBytesEncoding = "{\"bytes\":\"deadbeef\"}"

  static let michelsonSome = SomeMichelsonParameter(some: michelsonInt)
  static let expectedMichelsonSomeEncoding = "{\"prim\":\"Some\",\"args\":[\(expectedMichelsonIntEncoding)]}"

  static let michelsonNone = NoneMichelsonParameter()
  static let expectedMichelsonNoneEncoding = "{\"prim\":\"None\"}"

  func testEncodeUnitToJSON() {
    let michelson = MichelsonTests.michelsonUnit
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonUnitEncoding))
  }

  func testEncodeDateToJSON() {
    let date = Date(timeIntervalSince1970: 1_593_453_621) // Monday, June 29, 2020 6:00:21 PM, GMT
    let michelson = StringMichelsonParameter(date: date)
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString("{\"string\":\"2020-06-29T18:00:21Z\"}"))
  }

  func testEncodeStringToJSON() {
    let michelson = MichelsonTests.michelsonString
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonStringEncoding))
  }

  func testEncodeIntToJSON() {
    let michelson = MichelsonTests.michelsonInt
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonIntEncoding))
  }

  func testEncodePairToJSON() {
    let michelson = MichelsonTests.michelsonPair
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonPairEncoding))
  }

  func testEncodeLeftToJSON() {
    let michelson = MichelsonTests.michelsonLeft
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonLeftEncoding))
  }

  func testEncodeRightToJSON() {
    let michelson = MichelsonTests.michelsonRight
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonRightEncoding))
  }

  func testEncodeTrueToJSON() {
    let michelson = MichelsonTests.michelsonTrue
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonTrueEncoding))
  }

  func testEncodeFalseToJSON() {
    let michelson = MichelsonTests.michelsonFalse
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonFalseEncoding))
  }

  func testEncodeHexBytesToJSON() {
    let michelson = MichelsonTests.michelsonBytes
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonBytesEncoding))
  }

  func testEncodeBinaryBytesToJSON() {
    let bytes = CryptoUtils.hexToBin("deadbeef")!
    let michelson = BytesMichelsonParameter(bytes: bytes)!
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonBytesEncoding))
  }

  func testEncodeSomeToJSON() {
    let michelson = MichelsonTests.michelsonSome
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonSomeEncoding))
  }

  func testEncodeNoneToJSON() {
    let michelson = MichelsonTests.michelsonNone
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(MichelsonTests.expectedMichelsonNoneEncoding))
  }

  func testCustomParameter() {
    let jsonDict: [String: Any] = [
      MichelineConstants.primitive: MichelineConstants.left,
      MichelineConstants.args: [ MichelsonTests.michelsonInt.networkRepresentation ],
      "annots": [ "@TezosKitAnnotation" ]
    ]
    let expected = "{\"prim\":\"Left\",\"args\":[\(MichelsonTests.expectedMichelsonIntEncoding)],\"annots\":[\"@TezosKitAnnotation\"]}"
    let michelson = AbstractMichelsonParameter(networkRepresentation: jsonDict)

    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(expected))
  }

  func testAnnotation() {
    guard let annotation = MichelsonAnnotation(annotation: "@tezoskit") else {
      XCTFail()
      return
    }
    let michelson = PairMichelsonParameter(
      left: MichelsonTests.michelsonInt,
      right: MichelsonTests.michelsonString,
      annotations: [ annotation ]
    )

    let expected = "{\"prim\": \"Pair\", \"args\": [ \(MichelsonTests.expectedMichelsonIntEncoding), \(MichelsonTests.expectedMichelsonStringEncoding) ], \"annots\": [\"\(annotation.value)\"] }"
    let encoded = JSONUtils.jsonString(for: michelson.networkRepresentation)
    XCTAssertEqual(encoded, Helpers.orderJSONString(expected))
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
    XCTAssertEqual(json, Helpers.orderJSONString(expected))
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
    XCTAssertEqual(json, Helpers.orderJSONString(expected))
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
    XCTAssertEqual(json, Helpers.orderJSONString(expected))
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
    XCTAssertEqual(json, Helpers.orderJSONString(expected))
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
    XCTAssertEqual(json, Helpers.orderJSONString(expected))
  }

  public func testListParameter() {
    let parameter = LeftMichelsonParameter(
      arg: ListMichelsonParameter(args:
        [
        PairMichelsonParameter(
          left: PairMichelsonParameter(
            left: IntMichelsonParameter(int: 1),
            right: StringMichelsonParameter(string: "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb")
          ),
          right: PairMichelsonParameter(
            left: StringMichelsonParameter(string: "tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6"),
            right: RightMichelsonParameter(arg: UnitMichelsonParameter()))
          )
        ]
      )
    )

    let expected = "{    \"prim\": \"Left\",    \"args\": [      [{        \"prim\": \"Pair\",        \"args\": [{            \"prim\": \"Pair\",            \"args\": [{                \"int\": \"1\"              },{                \"string\": \"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb\"}]},{\"prim\": \"Pair\",\"args\": [{\"string\": \"tz1aSkwEot3L2kmUvcoxzjMomb9mvBNuzFK6\"},{\"prim\": \"Right\",\"args\": [{\"prim\": \"Unit\"}]}]}]}]]}"

    let json = JSONUtils.jsonString(for: parameter.networkRepresentation)
    XCTAssertEqual(json, Helpers.orderJSONString(expected))
  }
}
