// Copyright Keefer Taylor, 2019

import Foundation
import PromiseKit

extension AbstractClient {
  public func send<T>(rpc: RPC<T>) -> Promise<T> {
    return Promise { seal in
      send(rpc: rpc) { result, error in
        seal.resolve(result, error)
      }
    }
  }
}
