// Copyright Keefer Taylor, 2019

import Foundation

/// A client for a Conseil Server.
public class ConseilClient {
  /// The network client.
  public let networkClient: NetworkClient

  /// The callback queue that all callbacks will be made on.
  public let callbackQueue: DispatchQueue

  /// Initialize a new client for a Conseil Service.
  ///
  /// - Parameters:
  ///   - remoteNodeURL: The path to the remote Conseil service.
  ///   - apiKey: The API key for the remote Conseil service.
  ///   - platform: The platform to query, defaults to tezos.
  ///   - network: The network to query, defaults to mainnet.
  ///   - urlSession: The URLSession that will manage network requests, defaults to the shared session.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
  public convenience init(
    remoteNodeURL: URL,
    apiKey: String,
    platform: ConseilPlatform = .tezos,
    network: ConseilNetwork = .mainnet,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    var nodeBaseURL = remoteNodeURL
    nodeBaseURL.appendPathComponent("v2")
    nodeBaseURL.appendPathComponent("data")
    nodeBaseURL.appendPathComponent(platform.rawValue)
    nodeBaseURL.appendPathComponent(network.rawValue)

    let headers = [
      Header(field: "apiKey", value: apiKey)
    ]

    let networkClient = NetworkClientImpl(
      remoteNodeURL: nodeBaseURL,
      urlSession: urlSession,
      headers: headers,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )

    self.init(
      callbackQueue: callbackQueue,
      networkClient: networkClient
    )
  }

  /// Initialize a new client for a Conseil Service.
  ///
  /// This initializer allows a network client to be injected for testing.
  ///
  /// - Parameters:
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
  ///   - networkClient: A networkClient to use.
  internal init(
    callbackQueue: DispatchQueue = DispatchQueue.main,
    networkClient: NetworkClient
  ) {
    self.networkClient = networkClient
    self.callbackQueue = callbackQueue
  }

  /// Retrieve originated accounts.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of accounts to return, defaults to 100.
  ///   - completion: A completion callback.
  public func originatedAccounts(
    from account: String,
    limit: Int = 100,
    completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void
  ) {
    let rpc = GetOriginatedAccountsRPC(account: account, limit: limit)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve originated contracts.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of contracts to return, defaults to 100.
  ///   - completion: A completion callback.
  public func originatedContracts(
    from account: String,
    limit: Int = 100,
    completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void
  ) {
    let rpc = GetOriginatedContractsRPC(account: account, limit: limit)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve transactions both sent and received from an account.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  ///   - completion: A completion callback.
  public func transactions(
    from account: String,
    limit: Int = 100,
    completion: @escaping (Result<[Transaction], TezosKitError>) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
    let transactionsDispatchGroup = DispatchGroup()

    // Fetch sent transactions.
    transactionsDispatchGroup.enter()
    var receivedResult: Result<[Transaction], TezosKitError>?
    self.transactionsReceived(from: account, limit: limit) { result in
      receivedResult = result
      transactionsDispatchGroup.leave()
    }

    // Fetch received transactions.
    transactionsDispatchGroup.enter()
    var sentResult: Result<[Transaction], TezosKitError>?
    self.transactionsSent(from: account, limit: limit) { result in
      sentResult = result
      transactionsDispatchGroup.leave()
    }
    transactionsDispatchGroup.wait()

    guard let combinedResult = ConseilClient.combine(receivedResult, sentResult) else {
      self.callbackQueue.async {
        completion(.failure(TezosKitError(kind: .unknown)))
      }
      return
    }
    switch combinedResult {
    case .success(let combined):
      // Sort the combined results and trim down to the limit.
      let sorted = combined.sorted { $0.timestamp < $1.timestamp }
      let trimmed = Array(sorted.prefix(limit))
      self.callbackQueue.async {
        completion(.success(trimmed))
      }
    case .failure:
      self.callbackQueue.async {
        completion(combinedResult)
      }
    }
    }
  }

  /// Retrieve transactions received from an account.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  ///   - completion: A completion callback.
  public func transactionsReceived(
    from account: String,
    limit: Int = 100,
    completion: @escaping (Result<[Transaction], TezosKitError>) -> Void
  ) {
    let rpc = GetReceivedTransactionsRPC(
      account: account,
      limit: limit
    )
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve transactions sent from an account.
  ///
  /// - Parameters:
  ///   - account: The account to query.
  ///   - limit: The number of transactions to return, defaults to 100.
  ///   - completion: A completion callback.
  public func transactionsSent(
    from account: String,
    limit: Int = 100,
    completion: @escaping (Result<[Transaction], TezosKitError>) -> Void
  ) {
    let rpc = GetSentTransactionsRPC(
      account: account,
      limit: limit
    )
    networkClient.send(rpc, completion: completion)
  }

  // MARK: - Private Methods

  /// Combine the result of two optional results.
  ///
  /// Returns nil if either optional is nil, otherwise, returns the result of combining.
  internal static func combine<T>(
    _ a: Result<[T], TezosKitError>?,
    _ b: Result<[T], TezosKitError>?
  ) -> Result<[T], TezosKitError>? {
    guard let a = a,
          let b = b else {
        return nil
    }
    return combineResults(a, b)
  }

  /// Combine two array results.
  ///
  /// If any result is .failure, then that failure is returned. If both results are failures, return failureA.
  internal static func combineResults<T>(
    _ a: Result<[T], TezosKitError>,
    _ b: Result<[T], TezosKitError>
  ) -> Result<[T], TezosKitError> {
    return [a, b].reduce(.success([])) { accumulated, nextPartial -> Result<[T], TezosKitError> in
      // If there is a failure, keep returning a failure.
      guard case let .success(accumulatedArray) = accumulated else {
        return accumulated
      }

      switch nextPartial {
      case .success(let nextPartialArray):
        return .success(accumulatedArray + nextPartialArray)
      case .failure:
        return nextPartial
      }
    }
  }
}
