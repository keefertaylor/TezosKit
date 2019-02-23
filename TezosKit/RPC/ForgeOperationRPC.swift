// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An RPC which will forge an operation.
 */
public class ForgeOperationRPC: RPC<String> {
  /**
   * - Parameter chainID: The chain which is being operated on.
   * - Parameter headhash: The hash of the head of the chain being operated on.
   * - Parameter payload: A JSON encoded string representing the operation to inject.
   */
  public init(
    chainID: String,
    headHash: String,
    payload: String
  ) {
    let endpoint = "/chains/" + chainID + "/blocks/" + headHash + "/helpers/forge/operations"
    super.init(
      endpoint: endpoint,
      responseAdapterClass: StringResponseAdapter.self,
      payload: payload
    )
  }
}
