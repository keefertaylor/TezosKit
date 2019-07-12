// Copyright Keefer Taylor, 2019

import Foundation
import TezosCrypto

/// TezosNodeClient is the gateway into the Tezos Network via a Tezos Node.
///
/// Configuration
/// -------------
/// The client is initialized with a node URL which points to a node who can receive JSON RPC
/// requests from this client. The default not is rpc.tezrpc.me, a public node provided by TezTech.
///
/// The client can be initialized with a custom URLSession can be provided to manage network requests. By default, the
/// shared URLSession is used.
///
/// The client can also be initialized with a custom DispatchQueue that all callbacks are called on. By default, the
/// main dispatch queue is used.
///
/// RPCs
/// -------------
/// TezosNodeClient contains support for GET and POST RPCS and will make requests based on the
/// RPCs provided to it.
///
/// All supported RPC operations are provided in the Sources/Requests folder of the project. In
/// addition, TezosNodeClient provides convenience methods for constructing and sending all supported
/// operations.
///
/// Clients who extend TezosKit functionality can send arbitrary RPCs by creating an RPC object that
/// conforms the the |RPC| protocol and calling:
///     func send<T>(RPC<T>, completion: (T, Error) -> Void)
///
/// Operations
/// -------------
/// TezosNodeClient also contains support for performing signed operations on the Tezos blockchain. These
/// operations require a multi-step process to perform (forge, sign, pre-apply, inject).
///
/// All supported signed operations are provided in the Sources/Operations folder of the project. In
/// addition, TezosNodeClient provides convenience methods for constructing and performing all supported
/// signed operations.
///
/// Operations are sent with a fee and a limit for gas and storage to use to include the transaction
/// on the blockchain. These parameters are encapsulated in an OperationFees object which is optionally passed
/// to operation objects. Operations will fall back to default fees if no custom fees are provided.
///
/// Clients who extend TezosKit functionality can send arbitrary signed operations by creating an
/// Operation object that conforms to the |Operation| protocol and calling:
///     func forgeSignPreapplyAndInjectOperation(
///       _ operation: Operation,
///       source: Address,
///       keys: Keys,
///       completion: @escaping (String?, Error?) -> Void
///     )
///
/// Clients can also send multiple signed operations at once by constructing an array of operations.
/// Operations are applied in the order they are given in the array. Clients should pass the array
/// to:
///     func forgeSignPreapplyAndInjectOperations(
///       _ operations: [Operation],
///       source: Address,
///       keys: Keys,
///       completion: @escaping (String?, Error?) -> Void
///     )
///
/// Some signed operations require an address be revealed in order to complete the operation. For
/// operations supported in TezosKit, the reveal operation will be automatically applied when needed.
/// For clients who create their own custom signed operations, TezosKit will apply the reveal
/// operation correctly as long as the |requiresReveal| bit on the custom Operation object is set
/// correctly.
public class TezosNodeClient {
  /// JSON keys and values used in the Tezos Node.
  private enum JSON {
    public enum Keys {
      public static let contents = "contents"
      public static let metadata = "metadata"
      public static let operationResult = "operation_result"
      public static let status = "status"
      public static let errors = "errors"
      public static let id = "id"
    }

    public enum Values {
      public static let failed = "failed"
    }
  }

  /// The default node URL to use.
  public static let defaultNodeURL = URL(string: "https://rpc.tezrpc.me")!

  /// A factory which produces operations.
  public let operationFactory: OperationFactory

  /// A service which forges operations.
  public let forgingService: ForgingService

  /// The network client.
  public let networkClient: NetworkClient

  /// The operation metadata provider.
  public let operationMetadataProvider: OperationMetadataProvider

  /// Initialize a new TezosNodeClient.
  ///
  /// - Parameters:
  ///   - remoteNodeURL: The path to the remote node, defaults to the default URL
  ///   - tezosProtocol: The protocol version to use, defaults to athens.
  ///   - forgingPolicy: The policy to apply when forging operations. Default is remote.
  ///   - urlSession: The URLSession that will manage network requests, defaults to the shared session.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
  public init(
    remoteNodeURL: URL = defaultNodeURL,
    tezosProtocol: TezosProtocol = .athens,
    forgingPolicy: ForgingPolicy = .remote,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    operationFactory = OperationFactory(tezosProtocol: tezosProtocol)
    networkClient = NetworkClientImpl(
      remoteNodeURL: remoteNodeURL,
      urlSession: urlSession,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )
    operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)
    forgingService = ForgingService(forgingPolicy: forgingPolicy, networkClient: networkClient)
  }

  /// Retrieve data about the chain head.
  public func getHead(completion: @escaping (Result<[String: Any], TezosKitError>) -> Void) {
    let rpc = GetChainHeadRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the balance of a given wallet.
  public func getBalance(wallet: Wallet, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    getBalance(address: wallet.address, completion: completion)
  }

  /// Retrieve the balance of a given address.
  public func getBalance(address: String, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    let rpc = GetAddressBalanceRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    getDelegate(address: wallet.address, completion: completion)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: String, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetDelegateRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetChainHeadHashRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: String, completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetAddressCounterRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(
    address: String,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    let rpc = GetAddressManagerKeyRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Transact Tezos between accounts.
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - signer: The object which will sign the operation.
  ///   - parameters: Optional parameters to include in the transaction if the call is being made to a smart contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signer: Signer,
    parameters: [String: Any]? = nil,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let transactionOperation = operationFactory.transactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      parameters: parameters,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      transactionOperation,
      source: source,
      signer: signer,
      completion: completion
    )
  }

  /// Delegate the balance of an originated account.
  ///
  /// Note that only KT1 accounts can delegate. TZ1 accounts are not able to delegate. This invariant
  /// is not checked on an input to this methods. Thus, the source address must be a KT1 address and
  /// the keys to sign the operation for the address are the keys used to manage the TZ1 address.
  ///
  /// - Parameters:
  ///   - source: The address which will delegate.
  ///   - delegate: The address which will receive the delegation.
  ///   - signer: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func delegate(
    from source: Address,
    to delegate: Address,
    signer: Signer,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let delegationOperation = operationFactory.delegateOperation(
      source: source,
      to: delegate,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      delegationOperation,
      source: source,
      signer: signer,
      completion: completion
    )
  }

  /// Clear the delegate of an originated account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signer: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func undelegate(
    from source: Address,
    signer: Signer,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let undelegateOperatoin = operationFactory.undelegateOperation(source: source, operationFees: operationFees)
    forgeSignPreapplyAndInject(
      undelegateOperatoin,
      source: source,
      signer: signer,
      completion: completion
    )
  }

  /// Register an address as a delegate.
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signer: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func registerDelegate(
    delegate: Address,
    signer: Signer,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let registerDelegateOperation = operationFactory.registerDelegateOperation(
      source: delegate,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      registerDelegateOperation,
      source: delegate,
      signer: signer,
      completion: completion
    )
  }

  /// Originate a new account from the given account.
  /// - Parameters:
  ///   - managerAddress: The address which will manage the new account.
  ///   - signer: The object which will sign the operation.
  ///   - contractCode: Optional code to associate with the originated contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func originateAccount(
    managerAddress: String,
    signer: Signer,
    contractCode: ContractCode? = nil,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let originationOperation = operationFactory.originationOperation(
      address: managerAddress,
      contractCode: contractCode,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      originationOperation,
      source: managerAddress,
      signer: signer,
      completion: completion
    )
  }

  /// Returns the code associated with the address as a NSDictionary.
  /// - Parameter address: The address of the contract to load.
  public func getAddressCode(address: String, completion: @escaping (Result<ContractCode, TezosKitError>) -> Void) {
    let rpc = GetAddressCodeRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve ballots cast so far during a voting period.
  public func getBallotsList(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetBallotsListRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the expected quorum.
  public func getExpectedQuorum(completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetExpectedQuorumRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the current period kind for voting.
  public func getCurrentPeriodKind(completion: @escaping (Result<PeriodKind, TezosKitError>) -> Void) {
    let rpc = GetCurrentPeriodKindRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the sum of ballots cast so far during a voting period.
  public func getBallots(completion: @escaping (Result<[String: Any], TezosKitError>) -> Void) {
    let rpc = GetBallotsRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve a list of proposals with number of supporters.
  public func getProposalsList(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetProposalsListRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the current proposal under evaluation.
  public func getProposalUnderEvaluation(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetProposalUnderEvaluationRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve a list of delegates with their voting weight, in number of rolls.
  public func getVotingDelegateRights(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetVotingDelegateRightsRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve metadata and runs an operation.
  /// - Parameters:
  ///   - operation: The operation to run.
  ///   - wallet: The wallet requesting the run.
  ///   - completion: A completion block to call.
  public func runOperation(
    _ operation: Operation,
    from wallet: Wallet,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    operationMetadataProvider.metadata(for: wallet.address) { [weak self] result in
      guard let self = self else {
        return
      }
      guard case let .success(operationMetadata) = result else {
        completion(
          result.map { _ in [:] }
        )
        return
      }

      let operationPayload = OperationPayload(
        operations: [operation],
        operationFactory: self.operationFactory,
        operationMetadata: operationMetadata,
        source: wallet.address,
        signer: wallet
      )
      self.forgingService.forge(
        operationPayload: operationPayload,
        operationMetadata: operationMetadata
      ) { [weak self] result in
        guard let self = self else {
          return
        }
        guard case let .success(bytes) = result else {
          completion(
            result.map { _ in [:] }
          )
          return
        }

        guard
          let signature = SigningService.sign(bytes, with: wallet),
          let signedOperationPayload = SignedOperationPayload(
            operationPayload: operationPayload,
            signature: signature
          )
        else {
          let error = TezosKitError(kind: .signingError, underlyingError: nil)
          completion(.failure(error))
          return
        }

        let rpc = RunOperationRPC(signedOperationPayload: signedOperationPayload)
        self.networkClient.send(rpc, completion: completion)
      }
    }
  }

  // MARK: - Private Methods

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// - Parameters:
  ///   - operation: The operation which will be used to forge the operation.
  ///   - source: The address performing the operation.
  ///   - signer: The object which will sign the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  public func forgeSignPreapplyAndInject(
    _ operation: Operation,
    source: Address,
    signer: Signer,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    forgeSignPreapplyAndInject(
      [operation],
      source: source,
      signer: signer,
      completion: completion
    )
  }

  /// Forge, sign, preapply and then inject a set of operations.
  ///
  /// Operations are processed in the order they are placed in the operation array.
  ///
  /// - Parameters:
  ///   - operations: The operations which will be forged.
  ///   - source: The address performing the operation.
  ///   - signer: The object which will sign the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  public func forgeSignPreapplyAndInject(
    _ operations: [Operation],
    source: Address,
    signer: Signer,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    operationMetadataProvider.metadata(for: source) { [weak self] result in
      guard let self = self else {
        return
      }
      guard case let .success(operationMetadata) = result else {
        completion(
          result.map { _ in "" }
        )
        return
      }
      let operationPayload = OperationPayload(
        operations: operations,
        operationFactory: self.operationFactory,
        operationMetadata: operationMetadata,
        source: source,
        signer: signer
      )
      self.forgingService.forge(
        operationPayload: operationPayload,
        operationMetadata: operationMetadata
      ) { [weak self] result in
        guard let self = self else {
          return
        }
        guard case let .success(forgedBytes) = result else {
          completion(
            result.map { _ in "" }
          )
          return
        }
        self.signPreapplyAndInjectOperation(
          operationPayload: operationPayload,
          operationMetadata: operationMetadata,
          forgeResult: forgedBytes,
          source: source,
          signer: signer,
          completion: completion
        )
      }
    }
  }

  /// Sign the result of a forged operation, preapply and inject it if successful.
  ///
  /// - Parameters:
  ///   - operationPayload: The operation payload which was used to forge the operation.
  ///   - operationMetadata: Metadata related to the operation.
  ///   - forgeResult: The result of forging the operation payload.
  ///   - source: The address performing the operation.
  ///   - signer: The object which will sign the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  private func signPreapplyAndInjectOperation(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata,
    forgeResult: String,
    source: Address,
    signer: Signer,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    guard
      let signature = SigningService.sign(forgeResult, with: signer),
      let signatureHex = TezosCryptoUtils.binToHex(signature),
      let signedBytesForInjection = JSONUtils.jsonString(for: forgeResult + signatureHex),
      let signedOperationPayload = SignedOperationPayload(
        operationPayload: operationPayload,
        signature: signature
      )
    else {
      let error = TezosKitError(kind: .signingError, underlyingError: "Error signing operation.")
      completion(.failure(error))
      return
    }

    let signedProtocolOperationPayload = SignedProtocolOperationPayload(
      signedOperationPayload: signedOperationPayload,
      operationMetadata: operationMetadata
    )

    preapplyAndInjectRPC(
      signedProtocolOperationPayload: signedProtocolOperationPayload,
      signedBytesForInjection: signedBytesForInjection,
      operationMetadata: operationMetadata,
      completion: completion
    )
  }

  /// Preapply an operation and inject the operation if successful.
  /// - Parameters:
  ///   - signedProtocolOperationPayload: A payload for preapplication.
  ///   - signedBytesForInjection: A JSON encoded string that contains signed bytes for the preapplied operation.
  ///   - operationMetadata: Metadata related to the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  private func preapplyAndInjectRPC(
    signedProtocolOperationPayload: SignedProtocolOperationPayload,
    signedBytesForInjection: String,
    operationMetadata: OperationMetadata,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
      let preapplyOperationRPC = PreapplyOperationRPC(
        signedProtocolOperationPayload: signedProtocolOperationPayload,
        operationMetadata: operationMetadata
    )
    networkClient.send(preapplyOperationRPC) { [weak self] result in
      guard let self = self else {
        return
      }

      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let result):
        if let preapplicationError = TezosNodeClient.preapplicationError(from: result) {
          completion(.failure(preapplicationError))
          return
        }
        self.sendInjectionRPC(payload: signedBytesForInjection, completion: completion)
      }
    }
  }

  /// Send an injection RPC.
  /// - Parameters:
  ///   - payload: A JSON compatible string representing the signed operation bytes.
  ///   - completion: A completion block that will be called with the results of the operation.
  private func sendInjectionRPC(payload: String, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let injectRPC = InjectionRPC(payload: payload)
    networkClient.send(injectRPC) { result in
      switch result {
      case .failure(let txError):
        completion(.failure(txError))
      case .success(let txHash):
        completion(.success(txHash))
      }
    }
  }

  /// Parse a preapplication RPC response and extract an error if one occurred.
  internal static func preapplicationError(from preapplicationResponse: [[String: Any]]) -> TezosKitError? {
    let contents: [[String: Any]] = preapplicationResponse.compactMap { operation in
     operation[JSON.Keys.contents] as? [[String: Any]]
    }.flatMap { $0 }

    let metadatas: [[String: Any]] = contents.compactMap { content in
      content[JSON.Keys.metadata] as? [String: Any]
    }

    let operationResults: [[String: Any]] = metadatas.compactMap { metadata in
      metadata[JSON.Keys.operationResult] as? [String: Any]
    }

    let failedOperationResults: [[String: Any]] = operationResults.filter { operationResult in
      guard let status = operationResult[JSON.Keys.status] as? String,
            status == JSON.Values.failed else {
        return false
      }
      return true
    }

    let errors: [[String: Any]] = failedOperationResults.compactMap { failedOperationResult in
      failedOperationResult[JSON.Keys.errors] as? [[String: Any]]
    }.flatMap { $0 }

    guard !errors.isEmpty else {
      return nil
    }

    let firstError: String = errors.reduce("") { prev, next in
      guard prev.isEmpty,
            let id = next[JSON.Keys.id] as? String else {
        return prev
      }
      return id
    }
    return TezosKitError(kind: .preapplicationError, underlyingError: firstError)
  }
}

/// TODONOT: Move to OperationPayload as a proper initalizer.
/// TODONOT: Test.
extension OperationPayload {
  /// Creates a operation payload from a list of operations.
  ///
  /// This initializer will automatically add reveal operations and set address counters properly.
  ///
  /// - Parameters:
  ///   - operations: A list of operations to forge.
  ///   - operationMetadata: Metadata about the operations.
  ///   - source: The address executing the operations.
  ///   - signer: The object which will provide the public key.
  fileprivate init(
    operations: [Operation],
    operationFactory: OperationFactory,
    operationMetadata: OperationMetadata,
    source: Address,
    signer: Signer
  ) {
    // Determine if the address performing the operations has been revealed. If it has not been, check if any of the
    // operations to perform requires the address to be revealed. If so, prepend a reveal operation to the operations to
    // perform.
    var mutableOperations = operations
    if operationMetadata.key == nil && operations.first(where: { $0.requiresReveal }) != nil {
      let revealOperation = operationFactory.revealOperation(from: source, publicKey: signer.publicKey)
      mutableOperations.insert(revealOperation, at: 0)
    }

    // Process all operations to have increasing counters and place them in the contents array.
    var nextCounter = operationMetadata.addressCounter + 1
    var operationsWithCounter: [OperationWithCounter] = []
    for operation in operations {
      let operationWithCounter = OperationWithCounter(operation: operation, counter: nextCounter)
      operationsWithCounter.append(operationWithCounter)
      nextCounter += 1
    }

    self.init(operations: operationsWithCounter, operationMetadata: operationMetadata)
  }
}
