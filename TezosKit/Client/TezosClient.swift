// Copyright Keefer Taylor, 2018

import Foundation

/**
 * TezosClient is the gateway into the Tezos Network.
 *
 * Configuration
 * -------------
 * The client is initialized with a node URL which points to a node who can receive JSON RPC
 * requests from this client. The default not is rpc.tezrpc.me, a public node provided by TezTech.
 *
 * RPCs
 * -------------
 * TezosClient contains support for GET and POST RPCS and will make requests based on the
 * RPCs provided to it.
 *
 * All supported RPC operations are provided in the Sources/Requests folder of the project. In
 * addition, TezosClient provides convenience methods for constructing and sending all supported
 * operations.
 *
 * Clients who extend TezosKit functionality can send arbitrary RPCs by creating an RPC object that
 * conforms the the |TezosRPC| protocol and calling:
 *      func send<T>(rpc: TezosRPC<T>)
 *
 * Operations
 * -------------
 * TezosClient also contains support for performing signed operations on the Tezos blockchain. These
 * operations require a multi-step process to perform (forge, sign, pre-apply, inject).
 *
 * All supported signed operations are provided in the Sources/Operations folder of the project. In
 * addition, TezosClient provides convenience methods for constructing and performing all supported
 * signed operations.
 *
 * Operations are sent with a fee and a limit for gas and storage to use to include the transaction
 * on the blockchain. These parameters are encapsulated in an OperationFees object which is optionally passed
 * to operation objects. Operations will fall back to default fees if no custom fees are provided.
 *
 * Clients who extend TezosKit functionality can send arbitrary signed operations by creating an
 * Operation object that conforms to the |Operation| protocol and calling:
 *      func forgeSignPreapplyAndInjectOperation(operation: Operation,
 *                                               source: String,
 *                                               keys: Keys,
 *                                               completion: @escaping (String?, Error?) -> Void)
 *
 * Clients can also send multiple signed operations at once by constructing an array of operations.
 * Operations are applied in the order they are given in the array. Clients should pass the array
 * to:
 *      func forgeSignPreapplyAndInjectOperations(operations: [Operation],
 *                                                source: String,
 *                                                keys: Keys,
 *                                                completion: @escaping (String?, Error?) -> Void)
 *
 * Some signed operations require an address be revealed in order to complete the operation. For
 * operations supported in TezosKit, the reveal operation will be automatically applied when needed.
 * For clients who create their own custom signed operations, TezosKit will apply the reveal
 * operation correctly as long as the |requiresReveal| bit on the custom Operation object is set
 * correctly.
 */
public class TezosClient {
  /** The default node URL to use. */
  public static let defaultNodeURL = URL(string: "https://rpc.tezrpc.me")!

  /** The URL session that will be used to manage URL requests. */
  private let urlSession: URLSession

  /** A URL pointing to a remote node that will handle requests made by this client. */
  private let remoteNodeURL: URL

  /**
   * Initialize a new TezosClient using the default Node URL.
   */
  public convenience init() {
    self.init(remoteNodeURL: type(of: self).defaultNodeURL)
  }

  /**
   * Initialize a new TezosClient.
   *
   * @param removeNodeURL The path to the remote node.
   */
  public convenience init(remoteNodeURL: URL) {
    let urlSession = URLSession.shared
    self.init(remoteNodeURL: remoteNodeURL, urlSession: urlSession)
  }

  /**
   * Initialize a new TezosClient.
   *
   * @param removeNodeURL The path to the remote node.
   */
  public init(remoteNodeURL: URL, urlSession: URLSession) {
    self.remoteNodeURL = remoteNodeURL
    self.urlSession = urlSession
  }

  /** Retrieve data about the chain head. */
  public func getHead(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let rpc = GetChainHeadRPC(completion: completion)
    send(rpc: rpc)
  }

  /** Retrieve the balance of a given wallet. */
  public func getBalance(wallet: Wallet, completion: @escaping (TezosBalance?, Error?) -> Void) {
    getBalance(address: wallet.address, completion: completion)
  }

  /** Retrieve the balance of a given address. */
  public func getBalance(address: String, completion: @escaping (TezosBalance?, Error?) -> Void) {
    let rpc = GetAddressBalanceRPC(address: address, completion: completion)
    send(rpc: rpc)
  }

  /** Retrieve the delegate of a given wallet. */
  public func getDelegate(wallet: Wallet, completion: @escaping (String?, Error?) -> Void) {
    getDelegate(address: wallet.address, completion: completion)
  }

  /** Retrieve the delegate of a given address. */
  public func getDelegate(address: String, completion: @escaping (String?, Error?) -> Void) {
    let rpc = GetDelegateRPC(address: address, completion: completion)
    send(rpc: rpc)
  }

  /** Retrieve the hash of the block at the head of the chain. */
  public func getHeadHash(completion: @escaping (String?, Error?) -> Void) {
    let rpc = GetChainHeadHashRPC(completion: completion)
    send(rpc: rpc)
  }

  /** Retrieve the address counter for the given address. */
  public func getAddressCounter(address: String, completion: @escaping (Int?, Error?) -> Void) {
    let rpc = GetAddressCounterRPC(address: address, completion: completion)
    send(rpc: rpc)
  }

  /** Retrieve the address manager key for the given address. */
  public func getAddressManagerKey(address: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
    let rpc = GetAddressManagerKeyRPC(address: address, completion: completion)
    send(rpc: rpc)
  }

  /**
   * Transact Tezos between accounts.
   *
   * @param balance The balance to send.
   * @param recipientAddress The address which will receive the balance.
   * @param source The address sending the balance.
   * @param keys The keys to use to sign the operation for the address.
   * @param parameters Optional parameters to include in the transaction if the call is being made to a smart contract.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
  public func send(amount: TezosBalance,
                   to recipientAddress: String,
                   from source: String,
                   keys: Keys,
                   parameters: [String: Any]? = nil,
                   operationFees: OperationFees? = nil,
                   completion: @escaping (String?, Error?) -> Void) {
    let transactionOperation =
      TransactionOperation(amount: amount, source: source, destination: recipientAddress, parameters: parameters, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(operation: transactionOperation,
                                        source: source,
                                        keys: keys,
                                        completion: completion)
  }

  /**
   * Delegate the balance of an originated account.
   *
   * Note that only KT1 accounts can delegate. TZ1 accounts are not able to delegate. This invariant
   * is not checked on an input to this methods. Thus, the source address must be a KT1 address and
   * the keys to sign the operation for the address are the keys used to manage the TZ1 address.
   *
   * @param recipientAddress The address which will receive the balance.
   * @param source The address sending the balance.
   * @param keys The keys to use to sign the operation for the address.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
  public func delegate(from source: String,
                       to delegate: String,
                       keys: Keys,
                       operationFees: OperationFees? = nil,
                       completion: @escaping (String?, Error?) -> Void) {
    let delegationOperation = DelegationOperation(source: source, to: delegate, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(operation: delegationOperation,
                                        source: source,
                                        keys: keys,
                                        completion: completion)
  }

  /**
   * Clear the delegate of an originated account.
   *
   * @param source The address which is removing the delegate.
   * @param keys The keys to use to sign the operation for the address.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
  public func undelegate(from source: String,
                         keys: Keys,
                         operationFees: OperationFees? = nil,
                         completion: @escaping (String?, Error?) -> Void) {
    let undelegateOperatoin = UndelegateOperation(source: source, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(operation: undelegateOperatoin,
                                        source: source,
                                        keys: keys,
                                        completion: completion)
  }

  /**
   * Register an address as a delegate.
   *
   * @param recipientAddress The address which will receive the balance.
   * @param source The address sending the balance.
   * @param keys The keys to use to sign the operation for the address.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
  public func registerDelegate(delegate: String, keys: Keys,
                               operationFees: OperationFees? = nil,
                               completion: @escaping (String?, Error?) -> Void) {
    let registerDelegateOperation = RegisterDelegateOperation(delegate: delegate, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(operation: registerDelegateOperation,
                                        source: delegate,
                                        keys: keys,
                                        completion: completion)
  }

  /**
   * Originate a new account from the given account.
   *
   * @param managerAddress The address which will manage the new account.
   * @param keys The keys to use to sign the operation for the address.
   * @param contractCode Optional code to associate with the originated contract.
   * @param operationFees OperationFees for the transaction. If nil, default fees are used.
   * @param completion A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
  public func originateAccount(managerAddress: String,
                               keys: Keys,
                               contractCode: ContractCode? = nil,
                               operationFees: OperationFees? = nil,
                               completion: @escaping (String?, Error?) -> Void) {
    let originateAccountOperation = OriginateAccountOperation(address: managerAddress, contractCode: contractCode, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(operation: originateAccountOperation,
                                        source: managerAddress,
                                        keys: keys,
                                        completion: completion)
  }

  /**
   * Returns the code associated with the address as a NSDictionary.
   *
   * @param address The address of the contract to load.
   */
  public func getAddressCode(address: String, completion: @escaping (ContractCode?, Error?) -> Void) {
    let rpc = GetAddressCodeRPC(address: address, completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve ballots cast so far during a voting period.
   */
  public func getBallotsList(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let rpc = GetBallotsListRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve the expected quorum.
   */
  public func getExpectedQuorum(completion: @escaping (Int?, Error?) -> Void) {
    let rpc = GetExpectedQuorumRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve the current period kind for voting.
   */
  public func getCurrentPeriodKind(completion: @escaping (PeriodKind?, Error?) -> Void) {
    let rpc = GetCurrentPeriodKindRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve the sum of ballots cast so far during a voting period.
   */
  public func getBallots(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let rpc = GetBallotsRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve a list of proposals with number of supporters.
   */
  public func getProposalsList(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let rpc = GetProposalsListRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve the current proposal under evaluation.
   */
  public func getProposalUnderEvaluation(completion: @escaping (String?, Error?) -> Void) {
    let rpc = GetProposalUnderEvaluationRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Retrieve a list of delegates with their voting weight, in number of rolls.
   */
  public func getVotingDelegateRights(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
    let rpc = GetVotingDelegateRightsRPC(completion: completion)
    self.send(rpc: rpc)
  }

  /**
   * Forge, sign, preapply and then inject a single operation.
   *
   * @param operation The operation which will be used to forge the operation.
   * @param source The address performing the operation.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block that will be called with the results of the operation.
   */
  public func forgeSignPreapplyAndInjectOperation(operation: Operation,
                                                  source: String,
                                                  keys: Keys,
                                                  completion: @escaping (String?, Error?) -> Void) {
    forgeSignPreapplyAndInjectOperations(operations: [operation],
                                         source: source,
                                         keys: keys,
                                         completion: completion)
  }

  /**
   * Forge, sign, preapply and then inject a set of operations.
   *
   * Operations are processed in the order they are placed in the operation array.
   *
   * @param operation The operation which will be used to forge the operation.
   * @param source The address performing the operation.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block that will be called with the results of the operation.
   */
  public func forgeSignPreapplyAndInjectOperations(operations: [Operation],
                                                   source: String,
                                                   keys: Keys,
                                                   completion: @escaping (String?, Error?) -> Void) {
    guard let operationMetadata = getMetadataForOperation(address: source) else {
      let error = TezosClientError(kind: .unknown, underlyingError: nil)
      completion(nil, error)
      return
    }

    // Create a mutable copy of operations in case we need to add a reveal operation.
    var mutableOperations = operations

    // Determine if the address performing the operations has been revealed. If it has not been,
    // check if any of the operations to perform requires the address to be revealed. If so,
    // prepend a reveal operation to the operations to perform.
    if operationMetadata.key == nil {
      for operation in operations {
        if operation.requiresReveal {
          let revealOperation = RevealOperation(from: source, publicKey: keys.publicKey)
          mutableOperations.insert(revealOperation, at: 0)
          break
        }
      }
    }

    // Process all operations to have increasing counters and place them in the contents array.
    var contents: [[String: Any]] = []
    var counter = operationMetadata.addressCounter
    for operation in mutableOperations {
      counter = counter + 1

      var mutableOperation = operation.dictionaryRepresentation
      mutableOperation["counter"] = String(counter)

      contents.append(mutableOperation)
    }

    var operationPayload: [String: Any] = [:]
    operationPayload["contents"] = contents
    operationPayload["branch"] = operationMetadata.headHash

    guard let jsonPayload = JSONUtils.jsonString(for: operationPayload) else {
      let error = TezosClientError(kind: .unexpectedRequestFormat, underlyingError: nil)
      completion(nil, error)
      return
    }

    let forgeRPC = ForgeOperationRPC(chainID: operationMetadata.chainID,
                                     headHash: operationMetadata.headHash,
                                     payload: jsonPayload) { [weak self] result, error in
      guard let self = self,
        let result = result else {
        completion(nil, error)
        return
      }
      self.signPreapplyAndInjectOperation(operationPayload: operationPayload,
                                          operationMetadata: operationMetadata,
                                          forgeResult: result,
                                          source: source,
                                          keys: keys,
                                          completion: completion)
    }
    send(rpc: forgeRPC)
  }

  /**
   * Sign the result of a forged operation, preapply and inject it if successful.
   *
   * @param operationPayload The operation payload which was used to forge the operation.
   * @param operationMetadata Metadata related to the operation.
   * @param forgeResult The result of forging the operation payload.
   * @param source The address performing the operation.
   * @param keys The keys to use to sign the operation for the address.
   * @param completion A completion block that will be called with the results of the operation.
   */
  private func signPreapplyAndInjectOperation(operationPayload: [String: Any],
                                              operationMetadata: OperationMetadata,
                                              forgeResult: String,
                                              source _: String,
                                              keys: Keys,
                                              completion: @escaping (String?, Error?) -> Void) {
    guard let operationSigningResult = Crypto.signForgedOperation(operation: forgeResult,
                                                                  secretKey: keys.secretKey),
      let jsonSignedBytes = JSONUtils.jsonString(for: operationSigningResult.sbytes) else {
      let error = TezosClientError(kind: .unknown, underlyingError: nil)
      completion(nil, error)
      return
    }

    var mutableOperationPayload = operationPayload
    mutableOperationPayload["signature"] = operationSigningResult.edsig
    mutableOperationPayload["protocol"] = operationMetadata.protocolHash

    let operationPayloadArray = [mutableOperationPayload]
    guard let signedJsonPayload = JSONUtils.jsonString(for: operationPayloadArray) else {
      let error = TezosClientError(kind: .unexpectedRequestFormat, underlyingError: nil)
      completion(nil, error)
      return
    }

    preapplyAndInjectRPC(payload: signedJsonPayload,
                         signedBytesForInjection: jsonSignedBytes,
                         operationMetadata: operationMetadata,
                         completion: completion)
  }

  /**
   * Preapply an operation and inject the operation if successful.
   *
   * @param payload A JSON encoded string that will be preapplied.
   * @param signedBytesForInjection A JSON encoded string that contains signed bytes for the
   *        preapplied operation.
   * @param operationMetadata Metadata related to the operation.
   * @param completion A completion block that will be called with the results of the operation.
   */
  private func preapplyAndInjectRPC(payload: String,
                                    signedBytesForInjection: String,
                                    operationMetadata: OperationMetadata,
                                    completion: @escaping (String?, Error?) -> Void) {
    let preapplyOperationRPC = PreapplyOperationRPC(chainID: operationMetadata.chainID,
                                                    headHash: operationMetadata.headHash,
                                                    payload: payload,
                                                    completion: { [weak self] result, error in
                                                      guard let self = self,
                                                        let _ = result else {
                                                        completion(nil, error)
                                                        return
                                                      }

                                                      self.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
    })
    send(rpc: preapplyOperationRPC)
  }

  /**
   * Send an injection RPC.
   *
   * @param payload A JSON compatible string representing the singed operation bytes.
   * @param completion A completion block that will be called with the results of the operation.
   */
  private func sendInjectionRPC(payload: String, completion: @escaping (String?, Error?) -> Void) {
    let injectRPC = InjectionRPC(payload: payload, completion: { txHash, txError in
      completion(txHash, txError)
    })

    send(rpc: injectRPC)
  }

  /**
   * Send an RPC as a GET or POST request.
   */
  public func send<T>(rpc: TezosRPC<T>) {
    guard let remoteNodeEndpoint = URL(string: rpc.endpoint, relativeTo: self.remoteNodeURL) else {
      let error = TezosClientError(kind: .unknown, underlyingError: nil)
      rpc.handleResponse(data: nil, error: error)
      return
    }

    var urlRequest = URLRequest(url: remoteNodeEndpoint)

    if rpc.isPOSTRequest,
      let payload = rpc.payload,
      let payloadData = payload.data(using: .utf8) {
      urlRequest.httpMethod = "POST"
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.cachePolicy = .reloadIgnoringCacheData
      urlRequest.httpBody = payloadData
    }

    let request = urlSession.dataTask(with: urlRequest as URLRequest) { data, response, error in
      // Check if the response contained a 200 HTTP OK response. If not, then propagate an error.
      if let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode != 200 {
        // Default to unknown error and try to give a more specific error code if it can be narrowed
        // down based on HTTP response code.
        var errorKind: TezosClientError.ErrorKind = .unknown
        // Status code 40X: Bad request was sent to server.
        if httpResponse.statusCode >= 400, httpResponse.statusCode < 500 {
          errorKind = .unexpectedRequestFormat
          // Status code 50X: Bad request was sent to server.
        } else if httpResponse.statusCode >= 500 {
          errorKind = .unexpectedResponse
        }

        // Decode the server's response to a string in order to bundle it with the error if it is in
        // a readable format.
        var errorMessage = ""
        if let data = data,
          let dataString = String(data: data, encoding: .utf8) {
          errorMessage = dataString
        }

        // Drop data and send our error to let subsequent handlers know something went wrong and to
        // give up.
        let error = TezosClientError(kind: errorKind, underlyingError: errorMessage)
        rpc.handleResponse(data: nil, error: error)
        return
      }

      rpc.handleResponse(data: data, error: error)
    }
    request.resume()
  }

  /**
   * Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
   *
   * This method parallelizes fetches to get chain and address data and returns all required data
   * together as an OperationData object.
   */
  private func getMetadataForOperation(address: String) -> OperationMetadata? {
    let fetchersGroup = DispatchGroup()

    // Fetch data about the chain being operated on.
    var chainID: String?
    var headHash: String?
    var protocolHash: String?
    let chainHeadRequestRPC = GetChainHeadRPC { json, _ in
      if let json = json,
        let fetchedChainID = json["chain_id"] as? String,
        let fetchedHeadHash = json["hash"] as? String,
        let fetchedProtocolHash = json["protocol"] as? String {
        chainID = fetchedChainID
        headHash = fetchedHeadHash
        protocolHash = fetchedProtocolHash
      }
      fetchersGroup.leave()
    }

    // Fetch data about the address being operated on.
    var operationCounter: Int?
    let getAddressCounterRPC =
      GetAddressCounterRPC(address: address) { fetchedOperationCounter, _ in
        if let fetchedOperationCounter = fetchedOperationCounter {
          operationCounter = fetchedOperationCounter
        }
        fetchersGroup.leave()
      }

    // Fetch data about the key.
    var addressKey: String?
    let getAddressManagerKeyRPC = GetAddressManagerKeyRPC(address: address) { fetchedManagerAndKey, _ in
      if let fetchedManagerAndKey = fetchedManagerAndKey,
        let fetchedKey = fetchedManagerAndKey["key"] as? String {
        addressKey = fetchedKey
      }
      fetchersGroup.leave()
    }

    // Send RPCs and wait for results
    fetchersGroup.enter()
    send(rpc: chainHeadRequestRPC)

    fetchersGroup.enter()
    send(rpc: getAddressCounterRPC)

    fetchersGroup.enter()
    send(rpc: getAddressManagerKeyRPC)

    fetchersGroup.wait()

    // Return fetched data as an OperationData if all data was successfully retrieved.
    if let operationCounter = operationCounter,
      let headHash = headHash,
      let chainID = chainID,
      let protocolHash = protocolHash {
      return OperationMetadata(chainID: chainID,
                               headHash: headHash,
                               protocolHash: protocolHash,
                               addressCounter: operationCounter,
                               key: addressKey)
    }
    return nil
  }
}
