// Copyright Keefer Taylor, 2019

import Foundation
@testable import TezosKit

public struct FakePublicKey: PublicKeyProtocol {
  public let base58CheckRepresentation: String
  public let signingCurve: EllipticalCurve
}

/// A fake SignatureProvider.
public class FakeSignatureProvider: SignatureProvider {
  private let signature: [UInt8]
  public let publicKey: PublicKeyProtocol

  public init(signature: [UInt8], publicKey: PublicKeyProtocol) {
    self.signature = signature
    self.publicKey = publicKey
  }

  public func sign(_ payload: String) -> [UInt8]? {
    return signature
  }
}

/// A fake URLSession that will return data tasks which will call completion handlers with the given parameters.
public class FakeURLSession: URLSession {
  public var urlResponse: URLResponse?
  public var data: Data?
  public var error: Error?

  public override func dataTask(
    with request: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
    return FakeURLSessionDataTask(
      urlResponse: urlResponse,
      data: data,
      error: error,
      completionHandler: completionHandler
    )
  }
}

/// A fake data task that will immediately call completion.
public class FakeURLSessionDataTask: URLSessionDataTask {
  private let urlResponse: URLResponse?
  private let data: Data?
  private let fakedError: Error?
  private let completionHandler: (Data?, URLResponse?, Error?) -> Void

  public init(
    urlResponse: URLResponse?,
    data: Data?,
    error: Error?,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
    self.urlResponse = urlResponse
    self.data = data
    self.fakedError = error
    self.completionHandler = completionHandler
  }

  public override func resume() {
    completionHandler(data, urlResponse, fakedError)
  }
}

/// A fake network client which has default responses for given paths.
public class FakeNetworkClient: NetworkClient {

  public var endpointToResponseMap: [String: String]
  public let responseHandler: RPCResponseHandler

  /// Initialize a new fake network client.
  ///
  /// - Parameter endpointToResponseMap: A map of string endpoints to plain-text UTF-8 encoded responses.
  public init(endpointToResponseMap: [String: String]) {
    self.endpointToResponseMap = endpointToResponseMap
    self.responseHandler = RPCResponseHandler()
  }

  public func send<T>(
    _ rpc: RPC<T>,
    completion: @escaping (Result<T, TezosKitError>) -> Void
  ) {
    send(rpc, callbackQueue: nil, completion: completion)
  }

  public func send<T>(
    _ rpc: RPC<T>,
    callbackQueue: DispatchQueue? = nil,
    completion: @escaping (Result<T, TezosKitError>) -> Void
  ) {
    var statusCode = 400
    var responseData: Data?

    // Add response data and fix HTTP status code if there was a response for that endpoint.
    if let response = endpointToResponseMap[rpc.endpoint] {
      statusCode = 200
      responseData = response.data(using: .utf8)
    }

    let urlResponse = HTTPURLResponse(
      url: URL(string: "http://keefertaylor.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )

    let result = self.responseHandler.handleResponse(
      response: urlResponse,
      data: responseData,
      error: nil,
      responseAdapterClass: rpc.responseAdapterClass
    )

    // If there's a custom thread to call back on, use that. Otherwise default to the current thread.
    if let callbackQueue = callbackQueue {
      callbackQueue.async {
        completion(result)
      }
      return
    }
    completion(result)
  }
}

extension FakeNetworkClient: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    return FakeNetworkClient(endpointToResponseMap: self.endpointToResponseMap)
  }
}
