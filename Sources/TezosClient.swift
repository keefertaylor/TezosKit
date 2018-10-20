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
    // TODO: Use Operation model objects here.
    var operation: [String: Any] = [:];
    operation["kind"] = "transaction"
    operation["amount"] = "100000"
    operation["source"] = address
    operation["destination"] = recipientAddress
    operation["storage_limit"] = "10000"
    operation["gas_limit"] = "10000"
    operation["fee"] = "0"

    self.forgeSignPreapplyAndInjectOperation(operation: operation,
                                             address: address,
                                             secretKey: secretKey,
                                             completion: completion)
  }

  /**
   * Forge, sign, preapply and then inject an operation.
   *
   * @param operation The operation which will be used to forge the operation.
   * @param address The address that is performing the operation.
   * @param secretKey The edsk prefixed secret key which will be used to sign the operation.
   * @param completion A completion block that will be called with the results of the operation.
   */
  public func forgeSignPreapplyAndInjectOperation(operation: [String: Any],
                                                  address: String,
                                                  secretKey: String,
                                                  completion: @escaping (String?, Error?) -> Void) {
    guard let operationData = getDataForSignedOperation(address: address) else {
      let error = NSError(domain: tezosClientErrorDomain, code:TezosClientErrorCode.unknown.rawValue, userInfo: nil)
      completion(nil, error)
      return
    }

    let newCounter = String(operationData.operationCounter + 1)

    var mutableOperation = operation
    mutableOperation["counter"] = newCounter

    var operationPayload: [String: Any] = [:]
    operationPayload["contents"] = [ mutableOperation ]
    operationPayload["branch"] = operationData.headHash

    guard let jsonPayload = TezosClient.jsonString(for: operationPayload) else {
      let error = NSError(domain: tezosClientErrorDomain,
                          code:TezosClientErrorCode.unexpectedRequestFormat.rawValue,
                          userInfo: nil)
      completion(nil, error)
      return
    }

    let forgeRPC = ForgeOperationRPC(headChainID: operationData.chainID,
                                     headHash: operationData.headHash,
                                     payload: jsonPayload) { (result, error) in
      guard let result = result else {
        completion(nil, error)
        return
      }
      self.signPreapplyAndInjectOperation(operationPayload: operationPayload,
                                          forgeResult: result,
                                          secretKey: secretKey,
                                          chainID: operationData.chainID,
                                          headHash: operationData.headHash,
                                          protocolHash: operationData.protocolHash,
                                          completion: completion);
    }
    self.sendRequest(rpc: forgeRPC)
  }

  /**
   * Sign the result of a forged operation, preapply and inject it if successful.
   *
   * @param operationPayload The operation payload which was used to forge the operation.
   * @param forgeResult The result of forging the operation payload.
   * @param secretKey The edsk prefixed secret key which will be used to sign the operation.
   * @param chainID The chain which is being operated on.
   * @param headhash The hash of the head of the chain being operated on.
   * @param protocolHash The hash of the protocol being operated on.
   * @param completion A completion block that will be called with the results of the operation.
   */
  private func signPreapplyAndInjectOperation(operationPayload: [String: Any],
                                              forgeResult: String,
                                              secretKey: String,
                                              chainID: String,
                                              headHash: String,
                                              protocolHash: String,
                                              completion: @escaping (String?, Error?) -> Void) {
    guard let signedResult = Crypto.signForgedOperation(operation: forgeResult,
                                                        secretKey: secretKey) else {
      let error = NSError(domain: tezosClientErrorDomain,
                          code:TezosClientErrorCode.unknown.rawValue,
                          userInfo: nil)
      completion(nil, error)
      return
    }

    var mutableOperationPayload = operationPayload
    mutableOperationPayload["signature"] = signedResult.edsig
    mutableOperationPayload ["protocol"] = protocolHash

    guard let signedJsonPayload = TezosClient.jsonString(for: mutableOperationPayload) else {
      let error = NSError(domain: tezosClientErrorDomain,
                          code:TezosClientErrorCode.unexpectedRequestFormat.rawValue,
                          userInfo: nil)
      completion(nil, error)
      return
    }

    // Cheat and just encode this into an array.
    // TODO: Refactor this.
    let arraySignedJSONPayload = "[" + signedJsonPayload + "]"
    let jsonPayload = "\"" + signedResult.signedOperation  + "\""

    self.preapplyAndInjectRPC(payload: arraySignedJSONPayload,
                              signedBytesForInjection: jsonPayload,
                              chainID: chainID,
                              headHash: headHash,
                              completion: completion)
  }

  /**
   * Preapply an operation and inject the operation if successful.
   *
   * @param payload A JSON encoded string that will be preapplied.
   * @param signedBytesForInjection A JSON encoded string that contains signed bytes for the
   *        preapplied operation.
   * @param chainID The chain which is being operated on.
   * @param headhash The hash of the head of the chain being operated on.
   * @param completion A completion block that will be called with the results of the operation.
   */
  private func preapplyAndInjectRPC(payload: String,
                                    signedBytesForInjection: String,
                                    chainID: String,
                                    headHash: String,
                                    completion: @escaping (String?, Error?) -> Void) {
    let preapplyOperationRPC = PreapplyOperationRPC(headChainID: chainID,
                                                    headHash: headHash,
                                                    payload: payload,
                                                    completion: { (result, error) in
      guard let _ = result else {
        completion(nil, error)
        return
      }

      self.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
    })
    self.sendRequest(rpc: preapplyOperationRPC)
  }

  /**
   * Send an injection RPC.
   *
   * @param payload A JSON compatible string representing the singed operation bytes.
   * @param completion A completion block that will be called with the results of the operation.
   */
  private func sendInjectionRPC(payload: String, completion: @escaping (String?, Error?) -> Void) {
    let injectRPC = InjectionRPC(payload: payload, completion: { (txHash, txError) in
      completion(txHash, txError)
    })

    self.sendRequest(rpc: injectRPC)
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
  // TODO: Refactor this tuple to be a first class object.
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
