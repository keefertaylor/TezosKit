import Foundation

public class ResponseAdapter<ParsedType> {
  public func parse(input: Data) -> ParsedType? {
    return nil;
  }
}

public class StringResponseAdapter : ResponseAdapter<String> {
  public override func parse(input: Data) -> String? {
    return String(data: input, encoding: .ascii)
  }
}

public class JSONResponseAdapter : ResponseAdapter<Dictionary<String, Any>> {
  public override func parse(input: Data) -> Dictionary<String, Any>? {
    do {
      let json = try JSONSerialization.jsonObject(with: input)
      guard let typedJSON = json as? Dictionary<String, Any> else {
        return nil
      }
      return typedJSON
    } catch {
      print("Can't deserialize JSON :(")
      return nil
    }
  }
}

public class TezosAccountBalanceResponseAdapter : StringResponseAdapter {
  public override func parse(input: Data) -> String? {
    return super.parse(input: input)
  }
}

public struct TezosAccountBalance {
  public let balance: String
}

// Inheritance tree on adapters
// Class funcs on adapters
// Response adapters bound to request objects, A la GTM

public class TezosClient {

  private let urlSession: URLSession
  private let remoteNodeURL: URL

  public init(remoteNodeURL: URL) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = URLSession.shared
  }

  public func getHead(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let endpoint = "chains/main/blocks/head"
    self.sendRequest(endpoint: endpoint, responseAdapter: JSONResponseAdapter(), completion: completion)
  }

  public func getBalance(address: String, completion:  @escaping (String?, Error?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    self.sendRequest(endpoint: endpoint, responseAdapter: StringResponseAdapter(), completion: completion)
  }

  private func handleResponse<T>(data: Data?, error: Error?, responseAdapter: ResponseAdapter<T>, completion: (T?, Error?) -> Void) {
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

  private func sendRequest<T>(endpoint: String, responseAdapter: ResponseAdapter<T>, completion: @escaping (T?, Error?) -> Void) {
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
}
