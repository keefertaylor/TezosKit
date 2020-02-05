// Copyright Keefer Taylor, 2019.

import Foundation

/// Simulates operations.
public class SimulationService {
  /// The network client which makes requests.
  public let networkClient: NetworkClient

  /// The operation metadata provider which provides data for operations.
  private let operationMetadataProvider: OperationMetadataProvider

  /// A constant for the length of the signature.
  private static let signatureLength = 64

  /// A default signature to use for simulations as simulations don't need to be properly signed.
  private static let defaultSignature = [UInt8](repeating: 0, count: SimulationService.signatureLength)

  /// Identifier for the internal dispatch queue.
  private static let queueIdentifier = "com.keefertaylor.TezosKit.SimulationService"

  /// Internal Queue to use in order to perform asynchronous work.
  private let simulationServiceQueue: DispatchQueue

  public init(
    networkClient: NetworkClient,
    operationMetadataProvider: OperationMetadataProvider
  ) {
    self.networkClient = networkClient
    self.operationMetadataProvider = operationMetadataProvider
    simulationServiceQueue = DispatchQueue(label: SimulationService.queueIdentifier)
  }

  /// Simulate the given operation in a synchronous manner.
  ///
  /// - Note: This method blocks the calling thread.
  ///
  /// - Parameters:
  ///   - operation: The operation to run.
  ///   - source: The address requesting the run.
  ///   - signatureProvider: The object which will provide a public key, if a reveal is needed.
  /// - Returns: The result of the simulation.
  public func simulateSync(
    _ operation: Operation,
    from source: Address,
    signatureProvider: SignatureProvider
  ) -> Result<SimulationResult, TezosKitError> {
    let simulationDispatchGroup = DispatchGroup()

    simulationDispatchGroup.enter()
    var result: Result<SimulationResult, TezosKitError> = .failure(TezosKitError(kind: .unknown))
    simulationServiceQueue.async {
      self.simulate(operation, from: source, signatureProvider: signatureProvider) { simulationResult in
        result = simulationResult
        simulationDispatchGroup.leave()
      }
    }

    simulationDispatchGroup.wait()
    return result
  }

  /// Simulate the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to run.
  ///   - source: The address requesting the run.
  ///   - signatureProvider: The object which will provide a public key, if a reveal is needed.
  ///   - completion: A completion block to call.
  public func simulate(
    _ operation: Operation,
    from source: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<SimulationResult, TezosKitError>) -> Void
  ) {
    operationMetadataProvider.metadata(for: source) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case .failure(let error):
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      case .success(let operationMetadata):
        guard
          let operationPayload = OperationPayloadFactory.operationPayload(
            from: [operation],
            source: source,
            signatureProvider: signatureProvider,
            operationMetadata: operationMetadata
          ),
          let signedOperationPayload = SignedOperationPayload(
            operationPayload: operationPayload,
            signature: SimulationService.defaultSignature,
            signingCurve: .ed25519
          )
        else {
          let error = TezosKitError(kind: .signingError, underlyingError: nil)
          completion(.failure(error))
          return
        }

        let runOperationPayload = RunOperationPayload(
          signedOperationPayload: signedOperationPayload,
          operationMetadata: operationMetadata
        )

        let rpc = RunOperationRPC(runOperationPayload: runOperationPayload)
        self.networkClient.send(rpc, callbackQueue: self.simulationServiceQueue, completion: completion)
      }
    }
  }
}
