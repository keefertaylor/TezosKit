// Copyright Keefer Taylor, 2018

import Foundation

/**
 * An abstract RPC class that defines a request and response handler.
 *
 * RPCs have a generic type associated with them, which is the expected type of the decoded bytes
 * recived from the network. The given RepsonseAdapter must meet this type.
 *
 * RPCs represent a network request to the Tezos network. RPCs are implicitly considered GET
 * requests by default. If a payload is defined, then the RPC should be interpreted as a POST. This
 * schema is represented in the derived |isPOSTRequest| variable.
 *
 * Concrete subclasses should construct an endpoint and payload and inform this class by calling
 * |super.init|.
 */
// TODO: Genericize this class and other classes.
public class TezosRPC<T> {
  public let endpoint: String
  public let payload: String?
  public let responseAdapterClass: AbstractResponseAdapter<T>.Type
  public let completion: (T?, Error?) -> Void
  public var isPOSTRequest: Bool {
    if payload != nil {
      return true
    }
    return false
  }

  /**
   * Initialize a new request.
   *
   * By default, requests are considered to be GET requests with an empty body. If payload is set
   * the request should be interpreted as a POST request with the given payload.
   *
   * - Parameter endpoint: The endpoint to which the request is being made.
   * - Parameter responseAdapterClass: The class of the response adapter which will take bytes received from the
   *             request and transform them into a specific type.
   * - Parameter payload: A payload that should be sent with a POST request.
   * - Parameter completion: A completion block which will be called at the end of the request.
   */
  public init(
    endpoint: String,
    responseAdapterClass: AbstractResponseAdapter<T>.Type,
    payload: String? = nil,
    completion: @escaping (T?, Error?) -> Void
  ) {
    self.endpoint = endpoint
    self.responseAdapterClass = responseAdapterClass
    self.payload = payload
    self.completion = completion
  }

  /**
   * Handle a response from the network.
   *
   * This method will attempt to deserialize the given data with the given response adapter and call
   * completion with the resulting data or error.
   *
   * - Parameter data: Optional data returned from the network request.
   * - Parameter error: Optional error returned from the network request.
   * - Parameter callbackQueue: A thread that the completion handler will be executed on, default is the main thread.
   */
  public func handleResponse(data: Data?, error: Error?, callbackQueue: DispatchQueue = DispatchQueue.main) {
    if let error = error {
      let desc = error.localizedDescription
      let tezosClientError = TezosClientError(kind: .rpcError, underlyingError: desc)
      callbackQueue.async {
        self.completion(nil, tezosClientError)
      }
      return
    }

    guard let data = data,
      let result = self.responseAdapterClass.parse(input: data) else {
      let tezosClientError = TezosClientError(kind: .unexpectedResponse, underlyingError: nil)
      callbackQueue.async {
        self.completion(nil, tezosClientError)
      }
      return
    }

    callbackQueue.async {
      self.completion(result, nil)
    }
  }
}
