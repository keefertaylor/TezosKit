// Copyright Keefer Taylor 2019

import PromiseKit

/// Extension for ConseilClient which provides a Promise/PromiseKit based API.
public extension ConseilClient {
  /// Retrieve transactions received from an account.
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  func transactionsReceived(
    from account: String,
    limit: Int = 100
  ) -> Promise<[Transaction]> {
    let rpc = GetReceivedTransactionsRPC(
      account: account,
      limit: limit,
      apiKey: apiKey,
      platform: platform,
      network: network
    )
    return self.send(rpc)
  }

  /// Retrieve transactions sent from an account.
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  func transactionsSent(
    from account: String,
    limit: Int = 100
  ) -> Promise<[Transaction]> {
    let rpc = GetSentTransactionsRPC(
      account: account,
      limit: limit,
      apiKey: apiKey,
      platform: platform,
      network: network
    )
    return send(rpc)
  }
}
