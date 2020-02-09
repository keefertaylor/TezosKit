// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class FeeEstimatorTest: XCTestCase {
<<<<<<< HEAD
  func testEstimateFees() {
    let address = Address.testAddress
    let signatureProvider = FakeSignatureProvider.testSignatureProvider
    let operationFactory = OperationFactory.testFactory
    guard
      case let .success(operation) = operationFactory.delegateOperation(
        source: address,
        to: .testDestinationAddress,
        operationFeePolicy: .default,
        signatureProvider: signatureProvider
      )
    else {
      XCTFail()
      return
    }

    let feeEstimator = FeeEstimator(
      forgingService: .testForgingService,
      operationMetadataProvider: .testOperationMetadataProvider,
      simulationService: .testSimulationService
    )

    let completionExpectation = XCTestExpectation(description: "completion called")

    feeEstimator.estimate(operation: operation, address: address, signatureProvider: signatureProvider) { result in
      switch result {
      case .success:
        completionExpectation.fulfill()
      case .failure:
        XCTFail()
      }
    }

    wait(for: [completionExpectation], timeout: .expectationTimeout)

    }
=======
//  func testEstimateFees() {
//    let address = Address.testAddress
//    let signatureProvider = FakeSignatureProvider.testSignatureProvider
//    let operationFactory = OperationFactory.testFactory
//    guard
//      let operation = operationFactory.delegateOperation(
//        source: address,
//        to: .testDestinationAddress,
//        operationFeePolicy: .default,
//        signatureProvider: signatureProvider
//      )
//    else {
//      XCTFail()
//      return
//    }
//
//    let feeEstimator = FeeEstimator(
//      forgingService: .testForgingService,
//      operationMetadataProvider: .testOperationMetadataProvider,
//      simulationService: .testSimulationService
//    )
//
//    let completionExpectation = XCTestExpectation(description: "completion called")
//
//    feeEstimator.estimate(operation: operation, address: address, signatureProvider: signatureProvider) { result in
//      guard result != nil else {
//        XCTFail()
//        return
//      }
//      completionExpectation.fulfill()
//    }
//
//    wait(for: [completionExpectation], timeout: .expectationTimeout)
//
//  }
>>>>>>> master
}
