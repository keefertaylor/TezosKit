// Copyright Keefer Taylor, 2018

import Foundation

/// An RPC which will retrieve the sum of ballots cast so far during a voting period.
public class GetBallotsRPC: RPC<[String: Any]> {
  public init() {
    let endpoint = "chains/main/blocks/head/votes/ballots"
    super.init(endpoint: endpoint, responseAdapterClass: JSONDictionaryResponseAdapter.self)
  }
}
