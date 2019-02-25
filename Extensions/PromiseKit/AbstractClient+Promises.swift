// Copyright Keefer Taylor, 2019

import Foundation
import PromiseKit

/// Extension of AbstractClient which provides Promise based functionality.
extension AbstractClient {

  /// Send an RPC and return the result as a promise.
  /// - Parameters:
  ///   - rpc: The RPC to send.
  /// - Returns: A promise which will resolve to the result of the RPC.
  public func send<T>(_ rpc: RPC<T>) -> Promise<T> {
    return Promise { seal in
      send(rpc) { result, error in
        seal.resolve(result, error)
      }
    }
  }
}
