// Copyright Keefer Taylor, 2019

import Foundation

/**
 * A response handler handles responses that are received when network requests are completed.
 */
public class RPCResponseHandler {
  /** The queue that callbacks from requests will be made on. */
  private let callbackQueue: DispatchQueue

  /** Initialize a new response handler with the given callback queue. */
  public init(callbackQueue: DispatchQueue) {
    self.callbackQueue = callbackQueue
  }

  /** Handle the given response from making the given RPC. */
  public func handleResponse<T>(rpc: TezosRPC<T>, data: Data?, response: URLResponse?, error: Error?) {
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
}
