// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will retrieve the sum of ballots cast so far during a voting period.
 */
public class GetBallotsRPC: TezosRPC<String> {
  /**
   * @param blockID The level to count ballots at.
   * @param completion A block to be called at the completion of the operation.
   */
  public init(blockID: UInt, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/\(blockID)/votes/ballots"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
