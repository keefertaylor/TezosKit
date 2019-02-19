// Copyright Keefer Taylor, 2019

import Foundation

/// An abstract network client that can send RPC requests.
public class AbstractClient {

  /// The URL session that will be used to manage URL requests.
  private let urlSession: URLSession

  /// A URL pointing to a remote node that will handle requests made by this client.
  private let remoteNodeURL: URL

  /// A response handler for RPCs.
  private let responseHandler: RPCResponseHandler

  /// The queue that callbacks from requests will be made on.
  private let callbackQueue: DispatchQueue

  /**
   * Initialize a new AbstractNetworkClient.
   *
   * - Parameter remoteNodeURL: The path to the remote node.
   * - Parameter urlSession: The URLSession that will manage network requests.
   * - Parameter callbackQueue: A dispatch queue that callbacks will be made on.
   * - Parameter responseHandler: An object which will handle responses.
   */
  public init(
    remoteNodeURL: URL,
    urlSession: URLSession,
    callbackQueue: DispatchQueue,
    responseHandler: RPCResponseHandler
  ) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = urlSession
    self.callbackQueue = callbackQueue
    self.responseHandler = responseHandler
  }

  /**
   * Send an RPC as a GET or POST request.
   */
  public func send<T>(rpc: TezosRPC<T>) {
    guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: self.remoteNodeURL) else {
      let error = TezosClientError(kind: .unknown, underlyingError: nil)
      callbackQueue.async {
        rpc.completion(nil, error)
      }
      return
    }

    var urlRequest = URLRequest(url: remoteNodeEndpoint)

    if rpc.isPOSTRequest,
      let payload = rpc.payload,
      let payloadData = payload.data(using: .utf8) {
      urlRequest.httpMethod = "POST"
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.cachePolicy = .reloadIgnoringCacheData
      urlRequest.httpBody = payloadData
    }

    let request = urlSession.dataTask(with: urlRequest as URLRequest) { [weak self] data, response, error in
      guard let self = self else {
        return
      }

      let (result, error) = self.responseHandler.handleResponse(
        response: response,
        data: data,
        error: error,
        responseAdapterClass: rpc.responseAdapterClass
      )
      self.callbackQueue.async {
        rpc.completion(result, error)
      }
    }
    request.resume()
  }
}
