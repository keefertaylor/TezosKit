// Copyright Keefer Taylor, 2019

import Foundation

/// An abstract network client that can send RPC requests.
public class AbstractClient {

  /// The URL session that will be used to manage URL requests.
  private let urlSession: URLSession

  /// A URL pointing to a remote node that will handle requests made by this client.
  private let remoteNodeURL: URL

  /// Headers which will be added to every request.
  private let headers: [Header]

  /// A response handler for RPCs.
  private let responseHandler: RPCResponseHandler

  /// The queue that callbacks from requests will be made on.
  internal let callbackQueue: DispatchQueue

  /// Initialize a new AbstractNetworkClient.
  /// - Parameters:
  ///   - remoteNodeURL: The path to the remote node.
  ///   - urlSession: The URLSession that will manage network requests.
  ///   - headers: Headers which will be added to every request.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on.
  ///   - responseHandler: An object which will handle responses.
  public init(
    remoteNodeURL: URL,
    urlSession: URLSession,
    headers: [Header] = [],
    callbackQueue: DispatchQueue,
    responseHandler: RPCResponseHandler
  ) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = urlSession
    self.headers = headers
    self.callbackQueue = callbackQueue
    self.responseHandler = responseHandler
  }

  /// Send an RPC as a GET or POST request.
  public func send<T>(_ rpc: RPC<T>, completion: @escaping (Result<T, TezosKitError>) -> Void) {
    let remoteNodeEndpoint = remoteNodeURL.appendingPathComponent(rpc.endpoint)
//    guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: remoteNodeURL) else {
//      let errorMessage = "Invalid URL: \(remoteNodeURL)\(rpc.endpoint)"
//      let error = TezosKitError(kind: .invalidURL, underlyingError: errorMessage)
//      callbackQueue.async {
//        completion(.failure(error))
//      }
//      return
//    }

    var urlRequest = URLRequest(url: remoteNodeEndpoint)

    if rpc.isPOSTRequest,
      let payload = rpc.payload,
      let payloadData = payload.data(using: .utf8) {
      urlRequest.httpMethod = "POST"
      urlRequest.cachePolicy = .reloadIgnoringCacheData
      urlRequest.httpBody = payloadData
    }

    // Add headers from client.
    for header in headers {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
    }

    // Add headers from RPC.
    for header in rpc.headers {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
    }

    let request = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
      guard let self = self else {
        return
      }

      let result = self.responseHandler.handleResponse(
        response: response,
        data: data,
        error: error,
        responseAdapterClass: rpc.responseAdapterClass
      )
      self.callbackQueue.async {
        completion(result)
      }
    }
    request.resume()
  }
}
