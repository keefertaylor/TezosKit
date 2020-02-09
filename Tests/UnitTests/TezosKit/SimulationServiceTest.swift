// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class SimulationServiceTest: XCTestCase {
//  func testSimulationSync() {
//    let operationFactory = OperationFactory(feeEstimator: .testFeeEstimator)
//    let networkClient = FakeNetworkClient.tezosNodeNetworkClient
//    let operationMetadataProvider = OperationMetadataProvider.testOperationMetadataProvider
//    let simulationService = SimulationService(
//      networkClient: networkClient,
//      operationMetadataProvider: operationMetadataProvider
//    )
//
//    let operation = operationFactory.delegateOperation(
//      source: .testAddress,
//      to: .testDestinationAddress,
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let result = simulationService.simulateSync(
//      operation,
//      from: .testAddress,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )
//
//    guard case .success = result else {
//      XCTFail()
//      return
//    }
//  }
//
//  func testSimulation() {
//    let operationFactory = OperationFactory(feeEstimator: .testFeeEstimator)
//    let networkClient = FakeNetworkClient.tezosNodeNetworkClient
//    let operationMetadataProvider = OperationMetadataProvider.testOperationMetadataProvider
//    let simulationService = SimulationService(
//      networkClient: networkClient,
//      operationMetadataProvider: operationMetadataProvider
//    )
//
//    let operation = operationFactory.delegateOperation(
//      source: .testAddress,
//      to: .testDestinationAddress,
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//      )!
//
//    let simulationCompletionExpectation = XCTestExpectation(description: "Simulation completion called.")
//    simulationService.simulate(
//      operation,
//      from: .testAddress,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    ) { result in
//      switch result {
//      case .failure:
//        XCTFail()
//      case .success:
//        simulationCompletionExpectation.fulfill()
//      }
//    }
//    wait(for: [simulationCompletionExpectation], timeout: .expectationTimeout)
//  }
//
//  // swiftlint:disable force_cast
//
//  func testSimulationMetadataRetrievalFailed() {
//    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
//    networkClient.endpointToResponseMap["/chains/main/blocks/head"] = "nonsense"
//
//    let operationFactory = OperationFactory(feeEstimator: .testFeeEstimator)
//    let operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)
//    let simulationService = SimulationService(
//      networkClient: networkClient,
//      operationMetadataProvider: operationMetadataProvider
//    )
//
//    let operation = operationFactory.delegateOperation(
//      source: .testAddress,
//      to: .testDestinationAddress,
//      operationFeePolicy: .default,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    )!
//
//    let simulationCompletionExpectation = XCTestExpectation(description: "Simulation completion called.")
//    simulationService.simulate(
//      operation,
//      from: .testAddress,
//      signatureProvider: FakeSignatureProvider.testSignatureProvider
//    ) { result in
//      switch result {
//      case .failure:
//        simulationCompletionExpectation.fulfill()
//      case .success:
//        XCTFail()
//      }
//    }
//    wait(for: [simulationCompletionExpectation], timeout: .expectationTimeout)
//  }
}
