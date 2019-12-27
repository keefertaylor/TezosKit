// Copyright Keefer Taylor, 2019.

import Foundation

public class InjectionService {
  /// The network client.
  private let networkClient: NetworkClient

  public init(networkClient: NetworkClient) {
    self.networkClient = networkClient
  }

  /// Inject the given hex into the remote node.
  ///
  /// - Parameters:
  ///   - payload: A hex payload to inject.
  ///   - completion: A completion block that will be called with either an operation hash or an error.
  public func inject(payload: Hex, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let injectRPC = InjectionRPC(payload: payload)
    networkClient.send(injectRPC) { result in
      switch result {
      case .failure(let txError):
        completion(.failure(txError))
      case .success(let txHash):
        completion(.success(txHash))
      }
    }
  }
}
