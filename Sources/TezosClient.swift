import Foundation

// Response adapters bound to request objects

public class TezosClient {

  private let urlSession: URLSession
  private let remoteNodeURL: URL

  public init(remoteNodeURL: URL) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = URLSession.shared
  }

  public func getHead(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head"
    self.sendRequest(endpoint: endpoint, responseAdapter: JSONResponseAdapter.self, completion: completion)
  }

  public func getBalance(address: String, completion:  @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    self.sendRequest(endpoint: endpoint, responseAdapter: StringResponseAdapter.self, completion: completion)
  }

  private func sendRequest<T: ResponseAdapter>(endpoint: String, responseAdapter: T.Type, completion: @escaping (T.ParsedType?, Error?) -> Void) {
    guard let remoteNodeEndpoint = URL(string: endpoint, relativeTo: self.remoteNodeURL) else {
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      self.handleResponse(data: nil, error: error, responseAdapter: responseAdapter, completion: completion)
      return;
    }

    let request = self.urlSession.dataTask(with: remoteNodeEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
      self.handleResponse(data:data, error: error, responseAdapter: responseAdapter, completion: completion)
    }
    request.resume()
  }

  private func handleResponse<T: ResponseAdapter>(data: Data?, error: Error?, responseAdapter: T.Type, completion: (T.ParsedType?, Error? ) -> Void) {
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

    let result = responseAdapter.parse(input: data)
    completion(result, nil)
  }
}
