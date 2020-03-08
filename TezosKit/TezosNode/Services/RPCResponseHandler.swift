// Copyright Keefer Taylor, 2019

import Foundation

/// A response handler handles responses that are received when network requests are completed.
public class RPCResponseHandler {
  /// Handle a response from the network.
  ///
  /// - Parameters:
  ///   - response: The URLResponse associated with the request, if it exists.
  ///   - data: Raw data returned from the network, if it exists.
  ///   - error: An error in the request, if one occurred.
  ///   - responseAdapterClass: A response adapter class that will adapt the raw data to a first class object.
  /// - Returns: A tuple containing the result of the parsing operation if successful, otherwise an error.
  public func handleResponse<T>(
    response: URLResponse?,
    data: Data?,
    error: Error?,
    responseAdapterClass: AbstractResponseAdapter<T>.Type
  ) -> Result<T, TezosKitError> {
    // Check if the response contained a 200 HTTP OK response. If not, then propagate an error.
    if let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode != 200 {
       let httpError = parseError(from: httpResponse, with: data)
      return .failure(httpError)
    }

    // Check for a generic error on the request. If so, propagate.
    if let error = error {
       let desc = error.localizedDescription
       let rpcError = TezosKitError(kind: .rpcError, underlyingError: desc)
      return .failure(rpcError)
    }

    // Ensure that data came back.
    guard let data = data,
          let parsedData = parse(data, with: responseAdapterClass) else {
      let tezosKitError = TezosKitError(kind: .unexpectedResponse, underlyingError: nil)
      return .failure(tezosKitError)
    }

    return .success(parsedData)
  }

// MARK: - Helpers

  /// Parse an error from a given HTTPURLResponse.
  ///
  /// - Note: This method assumes that the HTTPResponse contained an error.
  ///
  /// - Parameters:
  ///   - httpResponse: The HTTPURLResponse to parse.
  ///   -data: Optional data that may have been returned with the response.
  ///  - Returns: An appropriate error based on the inputs.
  private func parseError(from httpResponse: HTTPURLResponse, with data: Data?) -> TezosKitError {
    // Decode the server's response to a string in order to bundle it with the error if it is in
    // a readable format.
    var errorMessage = ""
    if let data = data,
       let dataString = String(data: data, encoding: .utf8) {
      errorMessage = dataString
    }

    // Drop data and send our error to let subsequent handlers know something went wrong and to
    // give up.
    let errorKind = parseErrorKind(from: httpResponse)
    let error = TezosKitError(kind: errorKind, underlyingError: errorMessage)
    return error
  }

  /// Parse an error kind from a given HTTPURLResponse.
  ///
  /// - Note: This method assumes that the HTTPResponse contained an error.
  ///
  /// - Parameter httpResponse: The HTTPURLResponse to parse.
  /// - Returns: An appropriate error kind based on the response.
  private func parseErrorKind(from httpResponse: HTTPURLResponse) -> TezosKitError.ErrorKind {
    // Default to unknown error and try to give a more specific error code if it can be narrowed
    // down based on HTTP response code.
    var errorKind: TezosKitError.ErrorKind = .unknown
    // Status code 40X: Bad request was sent to server.
    if httpResponse.statusCode >= 400, httpResponse.statusCode < 500 {
      errorKind = .unexpectedRequestFormat
    // Status code 50X: Bad request was sent to server.
    } else if httpResponse.statusCode >= 500, httpResponse.statusCode < 600 {
      errorKind = .unexpectedResponse
    }
    return errorKind
  }

  ///  Parse the given data to an object with the given response adapter.
  ///
  /// - Parameters:
  ///   - data: Data to parse.
  ///   -responseAdapterClass: A response adapter class to use for parsing the data.
  /// - Returns: The parsed type if the data was was valid, otherwise nil.
  private func parse<T>(_ data: Data, with responseAdapterClass: AbstractResponseAdapter<T>.Type) -> T? {
    guard let result = responseAdapterClass.parse(input: data) else {
      return nil
    }
    return result
  }
}
