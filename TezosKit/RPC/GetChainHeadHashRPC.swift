// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve the hash of the head of the main chain.
public class GetChainHeadHashRPC: RPC<String> {
  public init() {
    let endpoint = "chains/main/blocks/head/hash"
    super.init(endpoint: endpoint, responseAdapterClass: StringResponseAdapter.self)
  }
}
