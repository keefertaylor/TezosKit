// Copyright Keefer Taylor, 2019

import Base58Swift
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

  /// A service that preapplies operations.
  public let preapplicationService: PreapplicationService

  /// A service which simulates operations.
  public let simulationService: SimulationService

  /// An injection service which injects operations.
  public let injectionService: InjectionService

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
    preapplicationService = PreapplicationService(networkClient: networkClient)
    simulationService = SimulationService(
      networkClient: networkClient,
      operationFactory: operationFactory,
      operationMetadataProvider: operationMetadataProvider
    )
    injectionService = InjectionService(networkClient: networkClient)
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
  public func getBalance(address: Address, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    let rpc = GetAddressBalanceRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    getDelegate(address: wallet.address, completion: completion)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: Address, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetDelegateRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetChainHeadHashRPC()
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: Address, completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetAddressCounterRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(
    address: Address,
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
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let transactionOperation = operationFactory.transactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      transactionOperation,
      source: source,
      signatureProvider: signatureProvider,
      completion: completion
    )
  }

  /// Call a smart contract.
  ///
  /// - Parameters:
  ///   - contract: The smart contract to invoke.
  ///   - amount: The amount of Tez to transfer with the invocation. Default is 0.
  ///   - parameter: An optional parameter to send to the smart contract. Default is none.
  ///   - source: The address invoking the contract.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func call(
    contract: Address,
    amount: Tez = Tez.zeroBalance,
    parameter: MichelsonParameter? = nil,
    source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let smartContractInvocationOperation = operationFactory.smartContractInvocationOperation(
      amount: amount,
      parameter: parameter,
      source: source,
      destination: contract,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      smartContractInvocationOperation,
      source: source,
      signatureProvider: signatureProvider,
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
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func delegate(
    from source: Address,
    to delegate: Address,
    signatureProvider: SignatureProvider,
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
      signatureProvider: signatureProvider,
      completion: completion
    )
  }

  /// Clear the delegate of an originated account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func undelegate(
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let undelegateOperatoin = operationFactory.undelegateOperation(source: source, operationFees: operationFees)
    forgeSignPreapplyAndInject(
      undelegateOperatoin,
      source: source,
      signatureProvider: signatureProvider,
      completion: completion
    )
  }

  /// Register an address as a delegate.
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func registerDelegate(
    delegate: Address,
    signatureProvider: SignatureProvider,
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
      signatureProvider: signatureProvider,
      completion: completion
    )
  }

  /// Originate a new account from the given account.
  /// - Parameters:
  ///   - managerAddress: The address which will manage the new account.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func originateAccount(
    managerAddress: String,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let originationOperation = operationFactory.originationOperation(
      address: managerAddress,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      originationOperation,
      source: managerAddress,
      signatureProvider: signatureProvider,
      completion: completion
    )
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

  /// Inspect the value of a big map in a smart contract.
  ///
  /// - Parameters:
  ///   - address: The address of a smart contract with a big map.
  ///   - key: The key in the big map to look up.
  ///   - type: The michelson type of the key.
  ///   - completion: A completion block to call.
  public func getBigMapValue(
    address: Address,
    key: MichelsonParameter,
    type: MichelsonComparable,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    let rpc = GetBigMapValueRPC(address: address, key: key, type: type)
    networkClient.send(rpc, completion: completion)
  }

  /// Retrieve metadata and runs an operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to run.
  ///   - wallet: The wallet requesting the run.
  ///   - completion: A completion block to call.
  public func runOperation(
    _ operation: Operation,
    from wallet: Wallet,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    simulationService.simulate(operation, from: wallet.address, signatureProvider: wallet, completion: completion)
  }

  /// Retrieve the storage of a smart contract.
  ///
  /// - Parameters:
  ///   - address: The address of the smart contract to inspect.
  ///   - completion: A completion block which will be called with the storage.
  public func getContractStorage(
    address: Address,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    let rpc = GetContractStorageRPC(address: address)
    networkClient.send(rpc, completion: completion)
  }

  // MARK: - Private Methods

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// - Parameters:
  ///   - operation: The operation which will be used to forge the operation.
  ///   - source: The address performing the operation.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  public func forgeSignPreapplyAndInject(
    _ operation: Operation,
    source: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    forgeSignPreapplyAndInject(
      [operation],
      source: source,
      signatureProvider: signatureProvider,
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
  ///   - signatureProvider: The object which will sign the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  public func forgeSignPreapplyAndInject(
    _ operations: [Operation],
    source: Address,
    signatureProvider: SignatureProvider,
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
        signatureProvider: signatureProvider
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
          signatureProvider: signatureProvider,
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
  ///   - signatureProvider: The object which will sign the operation.
  ///   - completion: A completion block that will be called with the results of the operation.
  private func signPreapplyAndInjectOperation(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata,
    forgeResult: String,
    source: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    guard
      let signature = SigningService.sign(forgeResult, with: signatureProvider),
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

    preapplicationService.preapply(
      signedProtocolOperationPayload: signedProtocolOperationPayload,
      signedBytesForInjection: signedBytesForInjection,
      operationMetadata: operationMetadata
    ) { result in
      if let error = result {
        completion(.failure(error))
        return
      }
      self.injectionService.inject(payload: signedBytesForInjection, completion: completion)
    }
  }
}
