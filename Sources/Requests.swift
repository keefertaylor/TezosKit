import Foundation

/**
 * An abstract RPC class that defines a request and response handler.
 */
public class TezosRPC<T> {
  public let endpoint: String
  public let payload: String?
  private let responseAdapterClass: AbstractResponseAdapter<T>.Type
  private let completion: (T?, Error?) -> Void
  public var shouldPOSTWithPayload: Bool {
    if let _ = payload {
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
   * @param endpoint The endpoint to which the request is being made.
   * @param responseAdapterClass The class of the response adapter which will take bytes received
   *        from the request and transform them into a specific type.
   * @param payload A payload that should be sent with a POST request.
   * @param completion A completion block which will be called at the end of the request.
   */
  public init(endpoint: String,
              responseAdapterClass: AbstractResponseAdapter<T>.Type,
              payload: String? = nil,
              completion: @escaping (T?, Error?) -> Void) {
    self.endpoint = endpoint
    self.responseAdapterClass = responseAdapterClass
    self.payload = payload
    self.completion = completion
  }

  public func handleResponse(data: Data?, error: Error?) {
    if let error = error {
      let tezosClientError = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.rpcError.rawValue, userInfo: [tezosClientUnderlyingErrorKey: error])
      completion(nil, tezosClientError)
      return
    }

    guard let data = data else {
      let tezosClientError = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unexpectedResponse.rawValue, userInfo:nil)
      completion(nil, tezosClientError)
      return
    }

    let result = self.responseAdapterClass.parse(input: data)
    completion(result, nil)
  }
}

public class GetChainHeadRPC : TezosRPC<[String: Any]> {
  public init(completion: @escaping ([String : Any]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head"
    super.init(endpoint: endpoint, responseAdapterClass: JSONResponseAdapter.self, completion: completion)
  }
}

public class GetChainHeadHashRPC : TezosRPC<String> {
  public init(completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head/hash"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}

public class GetAccountBalanceRPC : TezosRPC<TezosBalance> {
  public init(address: String, completion: @escaping (TezosBalance?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    super.init(endpoint: endpoint, responseAdapterClass: TezosBalanceAdapter.self, completion: completion)
  }
}

public class GetDelegateRPC: TezosRPC<String> {
  public init(address: String, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/delegate"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}

public class GetAddressCounterRPC: TezosRPC<String> {
  public init(address: String, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/counter"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}

public class GetAddressManagerKeyRPC: TezosRPC<[String: Any]> {
  public init(address: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/manager_key"
    super.init(endpoint: endpoint,
               responseAdapterClass: JSONResponseAdapter.self,
               completion: completion)
  }
}
