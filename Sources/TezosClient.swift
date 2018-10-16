import Foundation

public class TezosClient {
  private let urlSession: URLSession
  private let remoteNodeURL: URL

  public init(remoteNodeURL: URL) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = URLSession.shared
  }

  public func getHead(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let rpc = GetChainHeadRPC(completion: completion)
    self.sendRequest(rpc: rpc);
  }

  public func getBalance(wallet: Wallet, completion:  @escaping (TezosBalance?, Error?) -> Void) {
    self.getBalance(address: wallet.address, completion: completion)
  }

  public func getBalance(address: String, completion:  @escaping (TezosBalance?, Error?) -> Void) {
    let rpc = GetAccountBalanceRPC(address: address, completion: completion)
    self.sendRequest(rpc: rpc);
  }

  public func sendRequest<T>(rpc: TezosRPC<T>) {
    guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: self.remoteNodeURL) else {
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      rpc.handleResponse(data: nil, error: error);
      return;
    }

    let request = self.urlSession.dataTask(with: remoteNodeEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
      rpc.handleResponse(data: data, error: error)
    }
    request.resume()
  }
}
