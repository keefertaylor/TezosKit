// Copyright Keefer Taylor, 2019

/// Conseil Client is a WIP.
/// Remaining Work:
/// - Support for query parameters
/// - First class respoonse objects
/// - Promises Extension
/// - Integration Tests
/// - Updating documentation

// swiftlint:disable todo

/// A client for a Conseil Server.
public class ConseilClient: AbstractClient {
  /// The platfom that this client will query.
  private let platform: ConseilPlatform

  /// The network that this client will query.
  private let network: ConseilNetwork

  /// The API key for the remote Conseil service.
  private let apiKey: String

  /// Initialize a new client for a Conseil Service.
  ///
  /// - Parameters:
  ///   - remoteNodeURL: The path to the remote Conseil service.
  ///   - apiKey: The API key for the remote Conseil service.
  ///   - platform: The platform to query, defaults to tezos.
  ///   - network: The network to query, defaults to mainnet.
  ///   - urlSession: The URLSession that will manage network requests, defaults to the shared session.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
  public init(
    remoteNodeURL: URL,
    apiKey: String,
    platform: ConseilPlatform = .tezos,
    network: ConseilNetwork = .mainnet,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    self.platform = platform
    self.network = network
    self.apiKey = apiKey

    super.init(
      remoteNodeURL: remoteNodeURL,
      urlSession: urlSession,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )
  }

  /// Retrieve sent and received transactions from an account.
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
    let transactionsDispatchGroup = DispatchGroup()

    // Fetch sent transactions.
    transactionsDispatchGroup.enter()
    var receivedResult: Result<[Transaction], TezosKitError>? = nil
    self.transactionsReceived(from: account, limit: limit) { result in
      receivedResult = result
      transactionsDispatchGroup.enter()
    }

    // Fetch received transactions.
    transactionsDispatchGroup.enter()
    var sentResult: Result<[Transaction], TezosKitError>? = nil
    self.transactionsReceived(from: account, limit: limit) { result in
      sentResult = result
      transactionsDispatchGroup.enter()
    }

    transactionsDispatchGroup.wait()

    /// If:
    /// - Any input is nil, return error
    /// - Both are successful, return a result with the concatenation
    /// - If one is failed, return the failed error
    /// - If both failed, return an error from a.
    func combineResults<T>(a: Result<Array<T>, TezosKitError>?, b: Result<Array<T>, TezosKitError>?) -> Result<Array<T>, TezosKitError> {
      guard let a = a,
            let b = b else {
          return .failure(TezosKitError(kind: .unknown))
      }

      return [a, b].reduce(.success([])) { accumulated, nextPartial -> Result<Array<T>, TezosKitError> in
        // If there is a failure, keep returning a failure.
        guard case let .success(accumulatedArray) = nextPartial else {
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

    let combinedResult = combineResults(a: receivedResult, b: sentResult)
    switch (combinedResult) {
    case .success(let combined):
      // TODO: correctly thread
      completion(.success(combined.sorted { $0.timestamp < $1.timestamp }))
    case .failure:
      completion(combinedResult)
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
    guard let rpc = GetReceivedTransactionsRPC(
      account: account,
      limit: limit,
      apiKey: apiKey,
      platform: platform,
      network: network
      ) else {
        self.callbackQueue.async {
          completion(.failure(TezosKitError(kind: .invalidURL, underlyingError: nil)))
        }
        return
    }
    send(rpc, completion: completion)
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
    guard let rpc = GetSentTransactionsRPC(
      account: account,
      limit: limit,
      apiKey: apiKey,
      platform: platform,
      network: network
    ) else {
      self.callbackQueue.async {
        completion(.failure(TezosKitError(kind: .invalidURL, underlyingError: nil)))
      }
      return
    }
    send(rpc, completion: completion)
  }
}

//extension Array where Element == Result<Any, TezosKitError> {
//  public func reduce<T>(
//    initialResult: Result<T, TezosKitError>,
//    fn: (Result<T, TezosKitError>, Result<T, TezosKitError>) -> Result<T, TezosKitError>
//    ) -> Result<T, TezosKitError> {
//
//    workingResult: Result<T, TezosKitError>, nextPartial: Result<T, TezosKitError>) {
//    if case .failure(_) = workingResult {
//      return workingResult
//    }
////
//    guard case let .success(metadata) = result else {
//      completion(
//        result.map { _ in [:] }
//      )
//      return
//    }
//
//    guard case let
//
//
//    // If the result is already an error, ditch out and go with that.
//    switch workingResult {
//    case .success(let data):
//      switch nextPartial {
//      case .success(let nextData):
//
//      }
//
//
//    case .failure:
//      return workingResult
////    }
//  }
//}
