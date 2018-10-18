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
    self.sendRequest(rpc: rpc)
  }

  public func getBalance(wallet: Wallet, completion: @escaping (TezosBalance?, Error?) -> Void) {
    self.getBalance(address: wallet.address, completion: completion)
  }

  public func getBalance(address: String, completion: @escaping (TezosBalance?, Error?) -> Void) {
    let rpc = GetAccountBalanceRPC(address: address, completion: completion)
    self.sendRequest(rpc: rpc)
  }

  public func getDelegate(wallet: Wallet, completion: @escaping (String?, Error?) -> Void) {
    self.getDelegate(address: wallet.address, completion: completion)
  }

  public func getDelegate(address: String, completion: @escaping (String?, Error?) -> Void) {
    let rpc = GetDelegateRPC(address: address, completion: completion)
    self.sendRequest(rpc: rpc)
  }

  public func getHeadHash(completion: @escaping (String?, Error?) -> Void) {
    let rpc = GetChainHeadHashRPC(completion: completion)
    self.sendRequest(rpc: rpc)
  }

  public func getAddressCounter(address: String, completion: @escaping (String?, Error?) -> Void) {
    let rpc = GetAddressCounterRPC(address: address, completion: completion)
    self.sendRequest(rpc: rpc)
  }

  public func getAddressManagerKey(address: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let rpc = GetAddressManagerKeyRPC(address: address, completion: completion)
    self.sendRequest(rpc: rpc)
  }

  public func setDelegate(for address: String, to delegateAddress: String, completion: @escaping (Error?) -> Void) {
    guard let forgeData = getDataForSignedOperation(address: address) else {
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      completion(error)
      return
    }

    // TODO: Implement forge operation.
    completion(nil)
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

  private func getDataForSignedOperation(address: String) -> (chainID: String, headHash: String, operationCounter: String)? {
    let fetchersGroup = DispatchGroup()

    var chainID: String? = nil
    var headHash: String? = nil
    let chainHeadRequestRPC = GetChainHeadRPC() { (json: [String : Any]?, error: Error?) in
      if let json = json,
         let returnedChainID = json["chain_id"] as? String,
         let returnedHeadHash = json["hash"] as? String  {
         chainID = returnedChainID
         headHash = returnedHeadHash
      }
      fetchersGroup.leave()
    }

    var operationCounter: String? = nil
    let getAddressCounterRPC =
        GetAddressCounterRPC(address: address) { (returnedOperationCounter: String?, error: Error?) in
      if let returnedOperationCounter = returnedOperationCounter {
        operationCounter = returnedOperationCounter
      }
      fetchersGroup.leave()
    }

    fetchersGroup.enter()
    self.sendRequest(rpc: chainHeadRequestRPC)

    fetchersGroup.enter()
    self.sendRequest(rpc: getAddressCounterRPC)

    fetchersGroup.wait()

    // If all data was retrived successfully return them in a tuple. Otherwise, return nil.
    if let operationCounter = operationCounter,
       let headHash = headHash,
       let chainID = chainID {
       return (chainID: chainID, headHash: headHash, operationCounter: operationCounter)
    }
    return nil;
  }
}
