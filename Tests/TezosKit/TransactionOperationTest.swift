// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

// swiftlint:disable force_cast

class TransactionOperationTest: XCTestCase {
  let destination = "tz1def"
  let balance = Tez(3.50)

  public func testTransation() {
    let operation = OperationFactory.testFactory.transactionOperation(
      amount: balance,
      source: .testAddress,
      destination: .testDestinationAddress,
      operationFees: nil
    )
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, .testAddress)

    XCTAssertNotNil(dictionary["destination"])
    XCTAssertEqual(dictionary["destination"] as? String, .testDestinationAddress)

    XCTAssertNotNil(dictionary["amount"])
    XCTAssertEqual(dictionary["amount"] as? String, balance.rpcRepresentation)
  }

  public func testTransationWithParameter() {
    let parameter = LeftMichelsonParameter(arg: IntMichelsonParameter(int: 42))

    let operation = OperationFactory.testFactory.smartContractInvocationOperation(
      amount: balance,
      parameter: parameter,
      source: .testAddress,
      destination: .testDestinationAddress,
      operationFees: nil
    )
    let dictionary = operation.dictionaryRepresentation

    XCTAssertNotNil(dictionary["source"])
    XCTAssertEqual(dictionary["source"] as? String, .testAddress)

    XCTAssertNotNil(dictionary["destination"])
    XCTAssertEqual(dictionary["destination"] as? String, .testDestinationAddress)

    XCTAssertNotNil(dictionary["amount"])
    XCTAssertEqual(dictionary["amount"] as? String, balance.rpcRepresentation)

    let serializedParameter = JSONUtils.jsonString(for: dictionary["parameters"] as! [String: Any])
    let serializedExpected = JSONUtils.jsonString(for: parameter.networkRepresentation)

    XCTAssertEqual(serializedParameter, serializedExpected)
  }
}
