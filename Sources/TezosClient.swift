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

  public func send(amount: Double,
                   to recipientAddress: String,
                   from address: String,
                   secretKey: String,
                   completion: @escaping (String?, Error?) -> Void) {
    guard let operationData = getDataForSignedOperation(address: address) else {
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      completion(nil, error)
      return
    }

    let newCounter = String(operationData.operationCounter + 1)

    // TODO: Use Operation model objects here.
    var operation: [String: Any] = [:];
    operation["kind"] = "transaction"
    operation["amount"] = "100000"
    operation["source"] = address
    operation["destination"] = recipientAddress
    operation["storage_limit"] = "0"
    operation["gas_limit"] = "0"
    operation["fee"] = "0"
    operation["counter"] = newCounter

    var payload: [String: Any] = [:]
    payload["contents"] = [ operation ]
    payload["branch"] = operationData.headHash

    guard let jsonPayload = TezosClient.jsonString(for: payload) else {
      let error = NSError(domain: tezosClientErrorDomain,
                          code:TezosClientErrorCode.unexpectedRequestFormat.rawValue,
                          userInfo: nil)
      completion(nil, error)
      return
    }
    print("FYI, JSON encoded payload was: " + jsonPayload)

    let forgeRPC = ForgeOperationRPC(headChainID: operationData.chainID,
                                headHash: operationData.headHash,
                                counter: operationData.operationCounter,
                                payload: jsonPayload) { (result, error) in
      guard let result = result else {
        completion(nil, error)
        return
      }

      print("FYI, Result of forge was: " + result)

      guard let signedResult = Crypto.signForgedOperation(operation: result,
                                                          secretKey: secretKey) else {
        let error = NSError(domain: tezosClientErrorDomain,
                            code:TezosClientErrorCode.unknown.rawValue,
                            userInfo: nil)
        completion(nil, error)
        return
      }
      payload["signature"] = signedResult.edsig
      payload["protocol"] = operationData.protocolHash

      guard let signedJsonPayload = TezosClient.jsonString(for: payload) else {
        let error = NSError(domain: tezosClientErrorDomain,
                            code:TezosClientErrorCode.unexpectedRequestFormat.rawValue,
                            userInfo: nil)
        completion(nil, error)
        return
      }
      print("FYI, signed JSON is: " + signedJsonPayload)

      let preApplyRPC = PreapplyOperationRPC(headChainID: operationData.chainID,
                                             headHash: operationData.headHash,
                                             payload: signedJsonPayload,
                                             completion: { (preapplyJSON, error) in
          print("FYI, edsig was " + signedResult.edsig)
          print("FYI, signed bytes was: " + signedResult.signedOperation);

          let jsonPayload = "\"" + signedResult.signedOperation  + "\""
          let injectRPC = InjectionRPC(payload: jsonPayload, completion: { (txHash, txError) in
            completion(txHash, txError)
          })

          self.sendRequest(rpc: injectRPC)
      })
      self.sendRequest(rpc: preApplyRPC)
    }
    self.sendRequest(rpc: forgeRPC)
  }

  /**
   * Send an RPC as a GET or POST request.
   */
  public func sendRequest<T>(rpc: TezosRPC<T>) {
    guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: self.remoteNodeURL) else {
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      rpc.handleResponse(data: nil, error: error);
      return;
    }

    var urlRequest = URLRequest(url: remoteNodeEndpoint)

    if rpc.shouldPOSTWithPayload,
       let payload = rpc.payload,
       let payloadData = payload.data(using: .utf8) {
      urlRequest.httpMethod = "POST"
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.cachePolicy = .reloadIgnoringCacheData
      urlRequest.httpBody = payloadData
    }

    let request = self.urlSession.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
      rpc.handleResponse(data: data, error: error)
    }
    request.resume()
  }

  /**
   * Returns a JSON string representation of a given dictionary.
   */
  private static func jsonString(for dictionary: [String: Any]) -> String? {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
      guard let jsonPayload = String(data: jsonData, encoding: .utf8) else {
        return nil
      }
      return jsonPayload
    } catch {
      return nil
    }
  }

  /**
   * Retrieve data needed to forge / pre-apply / sign / inject an operation.
   */
  private func getDataForSignedOperation(address: String) -> (chainID: String,
                                                              headHash: String,
                                                              protocolHash: String,
                                                              operationCounter: Int)? {
    let fetchersGroup = DispatchGroup()

    var chainID: String? = nil
    var headHash: String? = nil
    var protocolHash: String? = nil
    let chainHeadRequestRPC = GetChainHeadRPC() { (json: [String : Any]?, error: Error?) in
      if let json = json,
         let returnedChainID = json["chain_id"] as? String,
         let returnedHeadHash = json["hash"] as? String,
         let returnedProtocolHash = json["protocol"] as? String  {
         chainID = returnedChainID
         headHash = returnedHeadHash
         protocolHash = returnedProtocolHash
      }
      fetchersGroup.leave()
    }

    var operationCounter: Int? = nil
    let getAddressCounterRPC =
        GetAddressCounterRPC(address: address) { (returnedOperationCounter: String?, error: Error?) in
      if let returnedOperationCounter = returnedOperationCounter,
         let returnedOperationCounterIntValue = Int(returnedOperationCounter) {
        operationCounter = returnedOperationCounterIntValue
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
       let chainID = chainID,
       let protocolHash = protocolHash {
       return (chainID: chainID, headHash: headHash, protocolHash: protocolHash, operationCounter: operationCounter)
    }
    return nil;
  }
}
