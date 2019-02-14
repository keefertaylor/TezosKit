// Copyright Keefer Taylor, 2019.

import Foundation

/**
 * An abstract client that issues and registers RPCs.
 */
public class NetworkClient {
  /** The URL session that will be used to manage URL requests. */
  private let urlSession: URLSession

  /** A URL pointing to a remote node that will handle requests made by this client. */
  private let remoteNodeURL: URL

  /** The queue that callbacks from requests will be made on. */
  private let callbackQueue: DispatchQueue

  /**
   * Initialize a new RPCClient.
   *
   * - Parameter remoteNodeURL: The path to the remote node.
   * - Parameter urlSession: The URLSession that will manage network requests.
   * - Parameter callbackQueue: A dispatch queue that callbacks will be made on.
   */
  public init(
    remoteNodeURL: URL,
    urlSession: URLSession,
    callbackQueue: DispatchQueue
  ) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = urlSession
    self.callbackQueue = callbackQueue
  }

  /**
   * Send an RPC as a GET or POST request.
   */
  public func send<T>(rpc: TezosRPC<T>) {
    guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: self.remoteNodeURL) else {
      let error = TezosClientError(kind: .unknown, underlyingError: nil)
      rpc.handleResponse(data: nil, error: error, callbackQueue: callbackQueue)
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

      // Check if the response contained a 200 HTTP OK response. If not, then propagate an error.
      if let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode != 200 {
        // Default to unknown error and try to give a more specific error code if it can be narrowed
        // down based on HTTP response code.
        var errorKind: TezosClientError.ErrorKind = .unknown
        // Status code 40X: Bad request was sent to server.
        if httpResponse.statusCode >= 400, httpResponse.statusCode < 500 {
          errorKind = .unexpectedRequestFormat
          // Status code 50X: Bad request was sent to server.
        } else if httpResponse.statusCode >= 500 {
          errorKind = .unexpectedResponse
        }

        // Decode the server's response to a string in order to bundle it with the error if it is in
        // a readable format.
        var errorMessage = ""
        if let data = data,
          let dataString = String(data: data, encoding: .utf8) {
          errorMessage = dataString
        }

        // Drop data and send our error to let subsequent handlers know something went wrong and to
        // give up.
        let error = TezosClientError(kind: errorKind, underlyingError: errorMessage)
        rpc.handleResponse(data: nil, error: error, callbackQueue: self.callbackQueue)
        return
      }

      rpc.handleResponse(data: data, error: error, callbackQueue: self.callbackQueue)
    }
    request.resume()
  }
}
