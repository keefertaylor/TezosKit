// Copyright Keefer Taylor, 2020

@testable import TezosKit
import XCTest

// swiftlint:disable force_cast

class SmartContractInvocationOperationTest: XCTestCase {
  let destination = "tz1def"
  let balance = Tez(3.50)
  let parameter = LeftMichelsonParameter(arg: IntMichelsonParameter(int: 42))
//
//  public func testDictionaryRepresentationWithParameter() {
//    let operation = OperationFactory.testFactory.smartContractInvocationOperation(
//      amount: balance,
//      entrypoint: nil,
//      parameter: parameter,
//      source: .testAddress,
//      destination: .testDestinationAddress,
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//    let dictionary = operation.dictionaryRepresentation
//
//    // Verify parameter is as expected.
//    let parametersDictionary = dictionary[SmartContractInvocationOperation.JSON.Keys.parameters] as! [String: Any]
//    let serializedParameter =
//      JSONUtils.jsonString(for: parametersDictionary[SmartContractInvocationOperation.JSON.Keys.value] as! [String: Any])
//    let serializedExpected = JSONUtils.jsonString(for: parameter.networkRepresentation)
//    XCTAssertEqual(serializedParameter, serializedExpected)
//
//    // Verify entrypoint is as expected.
//    let entrypoint = parametersDictionary[SmartContractInvocationOperation.JSON.Keys.entrypoint] as! String
//    XCTAssertEqual(entrypoint, SmartContractInvocationOperation.JSON.Values.default)
//  }
//
//  public func testDictionaryRepresentationWithParameterAndCustomEntrypoint() {
//    let entrypoint = "TezosKit"
//
//    let operation = OperationFactory.testFactory.smartContractInvocationOperation(
//      amount: balance,
//      entrypoint: entrypoint,
//      parameter: parameter,
//      source: .testAddress,
//      destination: .testDestinationAddress,
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//    let dictionary = operation.dictionaryRepresentation
//
//    // Verify parameter is as expected.
//    let parametersDictionary = dictionary[SmartContractInvocationOperation.JSON.Keys.parameters] as! [String: Any]
//    let serializedParameter =
//      JSONUtils.jsonString(for: parametersDictionary[SmartContractInvocationOperation.JSON.Keys.value] as! [String: Any])
//    let serializedExpected = JSONUtils.jsonString(for: parameter.networkRepresentation)
//    XCTAssertEqual(serializedParameter, serializedExpected)
//
//    // Verify entrypoint is as expected.
//    let dictionaryEntrypoint = parametersDictionary[SmartContractInvocationOperation.JSON.Keys.entrypoint] as! String
//    XCTAssertEqual(dictionaryEntrypoint, entrypoint)
//  }
//
//  public func testDictionaryRepresentationWithoutParameter() {
//    let operation = OperationFactory.testFactory.smartContractInvocationOperation(
//      amount: balance,
//      entrypoint: nil,
//      parameter: nil,
//      source: .testAddress,
//      destination: .testDestinationAddress,
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//    let dictionary = operation.dictionaryRepresentation
//
//    // Verify parameter is as expected.
//    let expectedParameter = UnitMichelsonParameter()
//    let parametersDictionary = dictionary[SmartContractInvocationOperation.JSON.Keys.parameters] as! [String: Any]
//    let serializedParameter = JSONUtils.jsonString(for: parametersDictionary[SmartContractInvocationOperation.JSON.Keys.value] as! [String: Any])
//    let serializedExpected = JSONUtils.jsonString(for: expectedParameter.networkRepresentation)
//    XCTAssertEqual(serializedParameter, serializedExpected)
//
//    // Verify entrypoint is as expected.
//    let entrypoint = parametersDictionary[SmartContractInvocationOperation.JSON.Keys.entrypoint] as! String
//    XCTAssertEqual(entrypoint, SmartContractInvocationOperation.JSON.Values.default)
//  }

}
