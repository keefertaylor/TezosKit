// Copyright Keefer Taylor, 2019.

import Foundation

/// A delegate of the ForgingService.
public protocol ForgingServiceDelegate: class {
  /// Request that the delegate perform a remote forge of the given operation.
  ///
  /// - Parameters:
  ///   - forgingService: The forging service making the request.
  ///   - operationPayload: The operation payload to forge.
  ///   - operationMetadata: Metadata to forge with the operation.
  ///   - completion: A completion block to call with the result of the remote forge.
  func forgingService(
    _ forgingService: ForgingService,
    requestedRemoteForgeForPayload operationPayload: OperationPayload,
    withMetadata operationMetadata: OperationMetadata,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  )
}

/// A service which manages forging of operations, in accordance with a ForgingPolicy.
public class ForgingService {
  /// The forging policy to apply to all operations.
  private let forgingPolicy: ForgingPolicy

  public weak var delegate: ForgingServiceDelegate?

  /// - Parameter forgingPolicy: The forging policy to apply to all operations.
  public init(forgingPolicy: ForgingPolicy) {
    self.forgingPolicy = forgingPolicy
  }

  /// Forge the given operation by applying the forging policy encapsulated by this service.
  ///
  /// - Parameters:
  ///   - operationPayload: The operation payload to forge.
  ///   - operationMetadata: Metadata to forge with the operation.
  ///   - completion: A completion block to call with the result of the  forge.
  public func forge(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    switch forgingPolicy {
    case .remote:
      remoteForge(operationPayload: operationPayload, operationMetadata: operationMetadata, completion: completion)
    case .local:
      completion(localForge(operationPayload: operationPayload, operationMetadata: operationMetadata))
    case .localWithRemoteFallBack:
      // If a local forge is successful, return the data synchronously. Otherwise, perform a remote forge.
      let localForgeResult = localForge(operationPayload: operationPayload, operationMetadata: operationMetadata)
      switch localForgeResult {
      case .success:
        completion(localForgeResult)
      case .failure:
        remoteForge(operationPayload: operationPayload, operationMetadata: operationMetadata, completion: completion)
      }
    }
  }

  /// Forge the given operation locally.
  /// - Parameters:
  ///   - operationPayload: The operation payload to forge.
  ///   - operationMetadata: Metadata to forge with the operation.
  /// - Returns: The result of the forge.
  private func localForge(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata
  ) -> Result<String, TezosKitError> {
    // Local forging is not currently supported.
    let forgingUnsupportedError = TezosKitError(kind: .localForgingNotSupportedForOperation)
    return .failure(forgingUnsupportedError)
  }

  /// Forge the given operation remotely on a node.
  ///
  /// - Parameters:
  ///   - operationPayload: The operation payload to forge.
  ///   - operationMetadata: Metadata to forge with the operation.
  ///   - completion: A completion block to call with the result of the forge.
  private func remoteForge(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    guard let delegate = self.delegate else {
      let noDelegateFailure: Result<String, TezosKitError> = .failure(
        TezosKitError(
          kind: .internalError,
          underlyingError: "Forging service was not able to find a delegate to perform a remote forge. Check that " +
          "ForgingService has an allocated delegate."
        )
      )
      completion(noDelegateFailure)
      return
    }

    delegate.forgingService(
      self,
      requestedRemoteForgeForPayload: operationPayload,
      withMetadata: operationMetadata,
      completion: completion
    )
  }
}
