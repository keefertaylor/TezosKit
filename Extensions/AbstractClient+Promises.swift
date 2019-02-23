// Copyright Keefer Taylor, 2019

import Foundation
import PromiseKit

public extension AbstractClient {
  public func send<T>(rpc: RPC<T>) -> Promise<T> {
    // TODO: Implement me.
    return Promise { seal in
    }
  }
}
