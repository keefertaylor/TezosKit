// Copyright Keefer Taylor, 2019

import Foundation
import PromiseKit

/// Extension of NetworkClient which provides Promise based functionality.
extension NetworkClient {
  /// Send an RPC and return the result as a promise.
  /// - Parameters:
  ///   - rpc: The RPC to send.
  /// - Returns: A promise which will resolve to the result of the RPC.
  public func send<T>(_ rpc: RPC<T>) -> Promise<T> {
    return Promise { seal in
      send(rpc) { result in
        switch result {
        case .success(let data):
            seal.fulfill(data)
        case .failure(let error):
            seal.reject(error)
        }
      }
    }
  }
}
