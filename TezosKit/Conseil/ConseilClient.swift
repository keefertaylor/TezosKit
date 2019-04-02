// Copyright Keefer Taylor, 2019

/// A client for a Conseil Server.
public class ConseilClient: AbstractClient {
  /// Initialize a new client for a Conseil Service.
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
    let remoteNodeWithPlatformAndNetwork =
      remoteNodeURL.appendingPathComponent(platform.rawValue).appendingPathComponent(network.rawValue)
    let headers = [
      Header(field: "apiKey", value: apiKey)
    ]

    super.init(
      remoteNodeURL: remoteNodeWithPlatformAndNetwork,
      urlSession: urlSession,
      headers: headers,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )
  }

  /// Retrieve transactions received from an account.
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
    send(rpc, completion: completion)
  }

  /// Retrieve transactions sent from an account.
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
    send(rpc, completion: completion)
  }
}
