import Foundation

public class TezosRPC<T> {
  public let endpoint: String
  private let responseAdapterClass: AbstractResponseAdapter<T>.Type
  private let completion: (T?, Error?) -> Void

  public init(endpoint: String, responseAdapterClass: AbstractResponseAdapter<T>.Type, completion: @escaping (T?, Error?) -> Void) {
    self.endpoint = endpoint
    self.responseAdapterClass = responseAdapterClass
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

public class GetAccountBalanceRPC : TezosRPC<TezosBalance> {
  public init(address: String, completion: @escaping (TezosBalance?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    super.init(endpoint: endpoint, responseAdapterClass: TezosBalanceAdapter.self, completion: completion)
  }
}

public class GetDelegateRPC : TezosRPC<String> {
  public init(address: String, completion: @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/delegate"
    super.init(endpoint: endpoint,
               responseAdapterClass: StringResponseAdapter.self,
               completion: completion)
  }
}
