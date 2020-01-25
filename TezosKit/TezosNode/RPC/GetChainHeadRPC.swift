// Copyright Keefer Taylor, 2018

import Foundation

///  An RPC which will retrieve a JSON dictionary of info about the head of the current chain.
public class GetChainHeadRPC: RPC<[String: Any]> {
  public init() {
    let endpoint = "/chains/main/blocks/head"
    super.init(endpoint: endpoint, responseAdapterClass: JSONDictionaryResponseAdapter.self)
  }
}
