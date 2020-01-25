// Copyright Keefer Taylor, 2019

import PromiseKit

/// Extension for ConseilClient which provides a Promise/PromiseKit based API.
extension ConseilClient {
  /// Retrieve originated accounts.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of accounts to return, defaults to 100.
  ///   - completion: A completion callback.
  public func originatedAccounts(
    from account: String,
    limit: Int = 100
  ) -> Promise<[[String: Any]]> {
    let rpc = GetOriginatedAccountsRPC(account: account, limit: limit)
    return networkClient.send(rpc)
  }

  /// Retrieve originated contracts.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of contracts to return, defaults to 100.
  ///   - completion: A completion callback.
  public func originatedContracts(
    from account: String,
    limit: Int = 100
  ) -> Promise<[[String: Any]]> {
    let rpc = GetOriginatedContractsRPC(account: account, limit: limit)
    return networkClient.send(rpc)
  }

  /// Retrieve transactions both sent and received from an account.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  ///   - completion: A completion callback.
  public func transactions(
    from account: String,
    limit: Int = 100
  ) -> Promise<[Transaction]> {
    return Promise { seal in
      transactions(from: account, limit: limit) { result in
        switch result {
        case .success(let data):
          seal.fulfill(data)
        case .failure(let error):
          seal.reject(error)
        }
      }
    }
  }

  /// Retrieve transactions received from an account.
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  public func transactionsReceived(
    from account: String,
    limit: Int = 100
  ) -> Promise<[Transaction]> {
    let rpc = GetReceivedTransactionsRPC(
      account: account,
      limit: limit
    )
    return networkClient.send(rpc)
  }

  /// Retrieve transactions sent from an account.
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  public func transactionsSent(
    from account: String,
    limit: Int = 100
  ) -> Promise<[Transaction]> {
    let rpc = GetSentTransactionsRPC(
      account: account,
      limit: limit
    )
    return networkClient.send(rpc)
  }
}
