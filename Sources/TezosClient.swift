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
// Plumb errors back to client

public class TezosClient {

  private let urlSession: URLSession
  private let remoteNodeURL: URL

  public init(remoteNodeURL: URL) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = URLSession.shared
  }

  public func getHead(completion: @escaping ([String: Any]?) -> Void) {
    let endpoint = "chains/main/blocks/head"
    self.sendRequest(endpoint: endpoint, responseAdapter: JSONResponseAdapter(), completion: completion)
  }

  public func getBalance(address: String, completion:  @escaping (String?) -> Void) {
    let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/balance"
    self.sendRequest(endpoint: endpoint, responseAdapter: StringResponseAdapter(), completion: completion)
  }

  private func handleResponse<T>(data: Data?, error: Error?, responseAdapter: ResponseAdapter<T>, completion: (T?) -> Void) {
    if let error = error {
      print("Error: " + String(describing: error))
      completion(nil)
      return
    }

    guard let data = data else {
      print("Unknown error result.")
      completion(nil)
      return
    }

    let result = responseAdapter.parse(input: data)
    completion(result)
  }

  private func sendRequest<T>(endpoint: String, responseAdapter: ResponseAdapter<T>, completion: @escaping (T?) -> Void) {
    guard let remoteNodeEndpoint = URL(string: endpoint, relativeTo: self.remoteNodeURL) else {
      print("Error constructing URL :(")
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      self.handleResponse(data: nil, error: error, responseAdapter: responseAdapter, completion: completion)
      return;
    }

    print("Sending request to URL: " + remoteNodeEndpoint.absoluteString)

    let request = self.urlSession.dataTask(with: remoteNodeEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
      self.handleResponse(data:data, error: error, responseAdapter: responseAdapter, completion: completion)
    }
    request.resume()
  }
}
