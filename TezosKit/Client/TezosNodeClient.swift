// Copyright Keefer Taylor, 2018

import Foundation
import PromiseKit
import TezosCrypto

/**
 * TezosNodeClient is the gateway into the Tezos Network via a Tezos Node.
 *
 * Configuration
 * -------------
 * The client is initialized with a node URL which points to a node who can receive JSON RPC
 * requests from this client. The default not is rpc.tezrpc.me, a public node provided by TezTech.
 *
 * The client can be initialized with a custom URLSession can be provided to manage network requests. By default, the
 * shared URLSession is used.
 *
 * The client can also be initialized with a custom DispatchQueue that all callbacks are called on. By default, the main
 * dispatch queue is used.
 *
 * RPCs
 * -------------
 * TezosNodeClient contains support for GET and POST RPCS and will make requests based on the
 * RPCs provided to it.
 *
 * All supported RPC operations are provided in the Sources/Requests folder of the project. In
 * addition, TezosNodeClient provides convenience methods for constructing and sending all supported
 * operations.
 *
 * Clients who extend TezosKit functionality can send arbitrary RPCs by creating an RPC object that
 * conforms the the |RPC| protocol and calling:
 *      func send<T>(rpc: RPC<T>)
 *
 * Operations
 * -------------
 * TezosNodeClient also contains support for performing signed operations on the Tezos blockchain. These
 * operations require a multi-step process to perform (forge, sign, pre-apply, inject).
 *
 * All supported signed operations are provided in the Sources/Operations folder of the project. In
 * addition, TezosNodeClient provides convenience methods for constructing and performing all supported
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
public class TezosNodeClient: AbstractClient {
  /** The default node URL to use. */
  public static let defaultNodeURL = URL(string: "https://rpc.tezrpc.me")!

  /**
   * Initialize a new TezosNodeClient.
   *
   * - Parameter remoteNodeURL: The path to the remote node, defaults to the default URL
   * - Parameter urlSession: The URLSession that will manage network requests, defaults to the shared session.
   * - Parameter callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
   */
  public init(
    remoteNodeURL: URL = defaultNodeURL,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    super.init(
      remoteNodeURL: remoteNodeURL,
      urlSession: urlSession,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )
  }

  /** Retrieve data about the chain head. */
  public func getHead(completion: @escaping ([String: Any]?, Error?) -> Void) {
    let rpc = GetChainHeadRPC(completion: completion)
    send(rpc: rpc)
  }

  /** Retrieve the balance of a given wallet. */
  public func getBalance(wallet: Wallet, completion: @escaping (Tez?, Error?) -> Void) {
    getBalance(address: wallet.address, completion: completion)
  }

  /** Retrieve the balance of a given address. */
  public func getBalance(address: String, completion: @escaping (Tez?, Error?) -> Void) {
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
   * - Parameter balance: The balance to send.
   * - Parameter recipientAddress: The address which will receive the balance.
   * - Parameter source: The address sending the balance.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter parameters: Optional parameters to include in the transaction if the call is being made to a smart
   *             contract.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   * - Parameter completion: A completion block which will be called with a string representing the
   *        transaction ID hash if the operation was successful.
   */
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: String,
    keys: Keys,
    parameters: [String: Any]? = nil,
    operationFees: OperationFees? = nil,
    completion: @escaping (String?, Error?) -> Void
  ) {
    let transactionOperation = TransactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      parameters: parameters,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInjectOperation(
      operation: transactionOperation,
      source: source,
      keys: keys,
      completion: completion
    )
  }

  /**
   * Delegate the balance of an originated account.
   *
   * Note that only KT1 accounts can delegate. TZ1 accounts are not able to delegate. This invariant
   * is not checked on an input to this methods. Thus, the source address must be a KT1 address and
   * the keys to sign the operation for the address are the keys used to manage the TZ1 address.
   *
   * - Parameter recipientAddress: The address which will receive the balance.
   * - Parameter source: The address sending the balance.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   * - Parameter completion: A completion block which will be called with a string representing the transaction ID hash
   *             if the operation was successful.
   */
  public func delegate(
    from source: String,
    to delegate: String,
    keys: Keys,
    operationFees: OperationFees? = nil,
    completion: @escaping (String?, Error?) -> Void
  ) {
    let delegationOperation = DelegationOperation(source: source, to: delegate, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(
      operation: delegationOperation,
      source: source,
      keys: keys,
      completion: completion
    )
  }

  /**
   * Clear the delegate of an originated account.
   *
   * - Parameter source: The address which is removing the delegate.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   * - Parameter completion: A completion block which will be called with a string representing the  transaction ID hash
   *             if the operation was successful.
   */
  public func undelegate(
    from source: String,
    keys: Keys,
    operationFees: OperationFees? = nil,
    completion: @escaping (String?, Error?) -> Void
  ) {
    let undelegateOperatoin = UndelegateOperation(source: source, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(
      operation: undelegateOperatoin,
      source: source,
      keys: keys,
      completion: completion
    )
  }

  /**
   * Register an address as a delegate.
   *
   * - Parameter recipientAddress: The address which will receive the balance.
   * - Parameter source: The address sending the balance.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   * - Parameter completion: A completion block which will be called with a string representing the transaction ID hash
   *             if the operation was successful.
   */
  public func registerDelegate(
    delegate: String,
    keys: Keys,
    operationFees: OperationFees? = nil,
    completion: @escaping (String?, Error?) -> Void
  ) {
    let registerDelegateOperation = RegisterDelegateOperation(delegate: delegate, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(
      operation: registerDelegateOperation,
      source: delegate,
      keys: keys,
      completion: completion
    )
  }

  /**
   * Originate a new account from the given account.
   *
   * - Parameter managerAddress: The address which will manage the new account.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter contractCode: Optional code to associate with the originated contract.
   * - Parameter operationFees: OperationFees for the transaction. If nil, default fees are used.
   * - Parameter completion: A completion block which will be called with a string representing the transaction ID hash
   *             if the operation was successful.
   */
  public func originateAccount(
    managerAddress: String,
    keys: Keys,
    contractCode: ContractCode? = nil,
    operationFees: OperationFees? = nil,
    completion: @escaping (String?, Error?) -> Void
  ) {
    let originateAccountOperation =
      OriginateAccountOperation(address: managerAddress, contractCode: contractCode, operationFees: operationFees)
    forgeSignPreapplyAndInjectOperation(
      operation: originateAccountOperation,
      source: managerAddress,
      keys: keys,
      completion: completion
    )
  }

  /**
   * Returns the code associated with the address as a NSDictionary.
   *
   * - Parameter address: The address of the contract to load.
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
   * - Parameter operation: The operation which will be used to forge the operation.
   * - Parameter source: The address performing the operation.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter completion: A completion block that will be called with the results of the operation.
   */
  public func forgeSignPreapplyAndInjectOperation(
    operation: Operation,
    source: String,
    keys: Keys,
    completion: @escaping (String?, Error?) -> Void
  ) {
    forgeSignPreapplyAndInjectOperations(
      operations: [operation],
      source: source,
      keys: keys,
      completion: completion
    )
  }

  /**
   * Forge, sign, preapply and then inject a set of operations.
   *
   * Operations are processed in the order they are placed in the operation array.
   *
   * - Parameter operation: The operation which will be used to forge the operation.
   * - Parameter source: The address performing the operation.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter completion: A completion block that will be called with the results of the operation.
   */
  public func forgeSignPreapplyAndInjectOperations(
    operations: [Operation],
    source: String,
    keys: Keys,
    completion: @escaping (String?, Error?) -> Void
  ) {
    getMetadataForOperation(address: source).done { operationMetadata in
      // Create a mutable copy of operations in case we need to add a reveal operation.
      var mutableOperations = operations

      // Determine if the address performing the operations has been revealed. If it has not been,
      // check if any of the operations to perform requires the address to be revealed. If so,
      // prepend a reveal operation to the operations to perform.
      if operationMetadata.key == nil && operations.first(where: { $0.requiresReveal }) != nil {
        let revealOperation = RevealOperation(from: source, publicKey: keys.publicKey)
        mutableOperations.insert(revealOperation, at: 0)
      }

      // Process all operations to have increasing counters and place them in the contents array.
      var contents: [[String: Any]] = []
      var counter = operationMetadata.addressCounter
      for operation in mutableOperations {
        counter += 1

        var mutableOperation = operation.dictionaryRepresentation
        mutableOperation["counter"] = String(counter)

        contents.append(mutableOperation)
      }

      var operationPayload: [String: Any] = [:]
      operationPayload["contents"] = contents
      operationPayload["branch"] = operationMetadata.headHash

      guard let jsonPayload = JSONUtils.jsonString(for: operationPayload) else {
        let error = TezosKitError(kind: .unexpectedRequestFormat, underlyingError: nil)
        completion(nil, error)
        return
      }

      let forgeRPC = ForgeOperationRPC(
        chainID: operationMetadata.chainID,
        headHash: operationMetadata.headHash,
        payload: jsonPayload
      ) { [weak self] result, error in
        guard let self = self,
              let result = result else {
          completion(nil, error)
          return
        }
        self.signPreapplyAndInjectOperation(
          operationPayload: operationPayload,
          operationMetadata: operationMetadata,
          forgeResult: result,
          source: source,
          keys: keys,
          completion: completion
        )
      }
      self.send(rpc: forgeRPC)
    }.catch { error in
      completion(nil, error)
    }
  }

  /**
   * Sign the result of a forged operation, preapply and inject it if successful.
   *
   * - Parameter operationPayload: The operation payload which was used to forge the operation.
   * - Parameter operationMetadata: Metadata related to the operation.
   * - Parameter forgeResult: The result of forging the operation payload.
   * - Parameter source: The address performing the operation.
   * - Parameter keys: The keys to use to sign the operation for the address.
   * - Parameter completion: A completion block that will be called with the results of the operation.
   */
  private func signPreapplyAndInjectOperation(
    operationPayload: [String: Any],
    operationMetadata: OperationMetadata,
    forgeResult: String,
    source _: String,
    keys: Keys,
    completion: @escaping (String?, Error?) -> Void
  ) {
    guard let operationSigningResult = TezosCrypto.signForgedOperation(
        operation: forgeResult,
        secretKey: keys.secretKey
      ),
      let jsonSignedBytes = JSONUtils.jsonString(for: operationSigningResult.sbytes) else {
      let error = TezosKitError(kind: .unknown, underlyingError: nil)
      completion(nil, error)
        return
    }

    var mutableOperationPayload = operationPayload
    mutableOperationPayload["signature"] = operationSigningResult.edsig
    mutableOperationPayload["protocol"] = operationMetadata.protocolHash

    let operationPayloadArray = [mutableOperationPayload]
    guard let signedJsonPayload = JSONUtils.jsonString(for: operationPayloadArray) else {
      let error = TezosKitError(kind: .unexpectedRequestFormat, underlyingError: nil)
      completion(nil, error)
      return
    }

    preapplyAndInjectRPC(
      payload: signedJsonPayload,
      signedBytesForInjection: jsonSignedBytes,
      operationMetadata: operationMetadata,
      completion: completion
    )
  }

  /**
   * Preapply an operation and inject the operation if successful.
   *
   * - Parameter payload: A JSON encoded string that will be preapplied.
   * - Parameter signedBytesForInjection: A JSON encoded string that contains signed bytes for the preapplied operation.
   * - Parameter operationMetadata: Metadata related to the operation.
   * - Parameter completion: A completion block that will be called with the results of the operation.
   */
  private func preapplyAndInjectRPC(
    payload: String,
    signedBytesForInjection: String,
    operationMetadata: OperationMetadata,
    completion: @escaping (String?, Error?) -> Void
  ) {
      let preapplyOperationRPC = PreapplyOperationRPC(
        chainID: operationMetadata.chainID,
        headHash: operationMetadata.headHash,
        payload: payload
    ) { [weak self] result, error in
          guard let self = self,
            result != nil else {
              completion(nil, error)
              return
          }
          self.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
      }
    send(rpc: preapplyOperationRPC)
  }

  /**
   * Send an injection RPC.
   *
   * - Parameter payload: A JSON compatible string representing the singed operation bytes.
   * - Parameter completion: A completion block that will be called with the results of the operation.
   */
  private func sendInjectionRPC(payload: String, completion: @escaping (String?, Error?) -> Void) {
    let injectRPC = InjectionRPC(payload: payload) { txHash, txError in
        completion(txHash, txError)
    }

    send(rpc: injectRPC)
  }

  /**
   * Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
   *
   * This method parallelizes fetches to get chain and address data and returns all required data
   * together as an OperationData object.
   */
  private func getMetadataForOperation(address: String) -> Promise<OperationMetadata> {
    return Promise { seal in
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
      let getAddressCounterRPC = GetAddressCounterRPC(address: address) { fetchedOperationCounter, _ in
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
        let operationMetadata = OperationMetadata(
          chainID: chainID,
          headHash: headHash,
          protocolHash: protocolHash,
          addressCounter: operationCounter,
          key: addressKey
        )
        seal.fulfill(operationMetadata)
      }
      let fetchFailedError = TezosKitError(kind: .rpcError, underlyingError: "Couldn't retrive operation metadata")
      seal.reject(fetchFailedError)
    }
  }
}
