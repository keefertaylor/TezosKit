// Copyright Keefer Taylor, 2019.

import Foundation

/// A service which pre-applies operations.
public class PreapplicationService {
  /// JSON keys and values used in the PreapplicationService.
  private enum JSON {
    public enum Keys {
      public static let contents = "contents"
      public static let metadata = "metadata"
      public static let operationResult = "operation_result"
      public static let status = "status"
      public static let errors = "errors"
      public static let id = "id"
    }

    public enum Values {
      public static let failed = "failed"
    }
  }

  /// The network client.
  private let networkClient: NetworkClient

  public init(networkClient: NetworkClient) {
    self.networkClient = networkClient
  }

  /// Preapply an operation
  ///
  /// - Parameters:
  ///   - signedProtocolOperationPayload: A payload for preapplication.
  ///   - signedBytesForInjection: A JSON encoded string that contains signed bytes for the preapplied operation.
  ///   - operationMetadata: Metadata related to the operation.
  ///   - completion: A completion block that will be called with an optional error which occurred.
  public func preapply(
    signedProtocolOperationPayload: SignedProtocolOperationPayload,
    signedBytesForInjection: String,
    operationMetadata: OperationMetadata,
    completion: @escaping (TezosKitError?) -> Void
  ) {
    let preapplyOperationRPC = PreapplyOperationRPC(
      signedProtocolOperationPayload: signedProtocolOperationPayload,
      operationMetadata: operationMetadata
    )
    networkClient.send(preapplyOperationRPC) { result in
      switch result {
      case .failure(let error):
        completion(error)
      case .success(let preapplicationResult):
        if let preapplicationError = PreapplicationService.preapplicationError(from: preapplicationResult) {
          completion(preapplicationError)
          return
        }
        completion(nil)
      }
    }
  }

  /// Parse a preapplication RPC response and extract an error if one occurred.
  internal static func preapplicationError(from preapplicationResponse: [[String: Any]]) -> TezosKitError? {
    let contents: [[String: Any]] = preapplicationResponse.compactMap { operation in
      operation[JSON.Keys.contents] as? [[String: Any]]
    }.flatMap { $0 }

    let metadatas: [[String: Any]] = contents.compactMap { content in
      content[JSON.Keys.metadata] as? [String: Any]
    }

    let operationResults: [[String: Any]] = metadatas.compactMap { metadata in
      metadata[JSON.Keys.operationResult] as? [String: Any]
    }

    let failedOperationResults: [[String: Any]] = operationResults.filter { operationResult in
      guard let status = operationResult[JSON.Keys.status] as? String,
        status == JSON.Values.failed else {
          return false
      }
      return true
    }

    let errors: [[String: Any]] = failedOperationResults.compactMap { failedOperationResult in
      failedOperationResult[JSON.Keys.errors] as? [[String: Any]]
    }.flatMap { $0 }

    guard !errors.isEmpty else {
      return nil
    }

    let firstError: String = errors.reduce("") { prev, next in
      guard prev.isEmpty,
        let id = next[JSON.Keys.id] as? String else {
          return prev
      }
      return id
    }
    return TezosKitError(kind: .preapplicationError, underlyingError: firstError)
  }
}
