// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class SimulationServiceTest: XCTestCase {
  func testSimulation() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient
    let operationFactory = OperationFactory()
    let operationMetadataProvider = OperationMetadataProvider.testOperationMetadataProvider
    let simulationService = SimulationService(
      networkClient: networkClient,
      operationFactory: operationFactory,
      operationMetadataProvider: operationMetadataProvider
    )

    let operation = operationFactory.delegateOperation(
      source: .testAddress,
      to: .testDestinationAddress,
      operationFees: nil
    )

    let simulationCompletionExpectation = XCTestExpectation(description: "Simulation completion called.")
    simulationService.simulate(
      operation,
      from: .testAddress,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) { result in
      switch result {
      case .failure:
        XCTFail()
      case .success:
        simulationCompletionExpectation.fulfill()
      }
    }
    wait(for: [simulationCompletionExpectation], timeout: .expectationTimeout)
  }

  // swiftlint:disable force_cast

  func testSimulationMetadataRetrievalFailed() {
    let networkClient = FakeNetworkClient.tezosNodeNetworkClient.copy() as! FakeNetworkClient
    networkClient.endpointToResponseMap["/chains/main/blocks/head"] = "nonsense"

    let operationFactory = OperationFactory()
    let operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)
    let simulationService = SimulationService(
      networkClient: networkClient,
      operationFactory: operationFactory,
      operationMetadataProvider: operationMetadataProvider
    )

    let operation = operationFactory.delegateOperation(
      source: .testAddress,
      to: .testDestinationAddress,
      operationFees: nil
    )

    let simulationCompletionExpectation = XCTestExpectation(description: "Simulation completion called.")
    simulationService.simulate(
      operation,
      from: .testAddress,
      signatureProvider: FakeSignatureProvider.testSignatureProvider
    ) { result in
      switch result {
      case .failure:
        simulationCompletionExpectation.fulfill()
      case .success:
        XCTFail()
      }
    }
    wait(for: [simulationCompletionExpectation], timeout: .expectationTimeout)
  }
}
