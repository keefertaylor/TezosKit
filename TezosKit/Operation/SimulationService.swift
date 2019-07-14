// Copyright Keefer Taylor, 2019.

import Foundation

/// Simulates operations.
public class SimulationService {
  /// The network client which makes requests.
  public let networkClient: NetworkClient

  /// An operation factory which can provide reveal operations.
  public let operationFactory: OperationFactory

  /// The operation metadata provider which provides data for operations.
  public let operationMetadataProvider: OperationMetadataProvider

  /// A constant for the length of the signature.
  private static let signatureLength = 64

  /// A default signature to use for simulations as simulations don't need to be properly signed.
  private static let defaultSignature = [UInt8](repeating: 0, count: SimulationService.signatureLength)

  public init(
    networkClient: NetworkClient,
    operationFactory: OperationFactory,
    operationMetadataProvider: OperationMetadataProvider
  ) {
    self.networkClient = networkClient
    self.operationFactory = operationFactory
    self.operationMetadataProvider = operationMetadataProvider
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
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    operationMetadataProvider.metadata(for: source) { [weak self] result in
      guard let self = self else {
        return
      }
      guard case let .success(operationMetadata) = result else {
        completion(
          result.map { _ in [:] }
        )
        return
      }

      let operationPayload = OperationPayload(
        operations: [operation],
        operationFactory: self.operationFactory,
        operationMetadata: operationMetadata,
        source: source,
        signatureProvider: signatureProvider
      )

      guard
        let signedOperationPayload = SignedOperationPayload(
          operationPayload: operationPayload,
          signature: SimulationService.defaultSignature
        )
      else {
          let error = TezosKitError(kind: .signingError, underlyingError: nil)
          completion(.failure(error))
          return
      }

      let rpc = RunOperationRPC(signedOperationPayload: signedOperationPayload)
      self.networkClient.send(rpc, completion: completion)
    }
  }
}
