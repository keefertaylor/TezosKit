// Copyright Keefer Taylor, 2019

import Base58Swift
import BigInt
import Foundation

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
  internal let operationFactory: OperationFactory

  /// A service which forges operations.
  internal let forgingService: ForgingService

  /// The network client.
  internal let networkClient: NetworkClient

  /// The operation metadata provider.
  internal let operationMetadataProvider: OperationMetadataProvider

  /// A service that preapplies operations.
  internal let preapplicationService: PreapplicationService

  /// A service which simulates operations.
  internal let simulationService: SimulationService

  /// An injection service which injects operations.
  internal let injectionService: InjectionService

  /// A callback queue that all completions will be called on.
  internal let callbackQueue: DispatchQueue

  /// Initialize a new TezosNodeClient.
  ///
  /// - Parameters:
  ///   - remoteNodeURL: The path to the remote node, defaults to the default URL
  ///   - tezosProtocol: The protocol version to use, defaults to athens.
  ///   - forgingPolicy: The policy to apply when forging operations. Default is remote.
  ///   - urlSession: The URLSession that will manage network requests, defaults to the shared session.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
  public convenience init(
    remoteNodeURL: URL = defaultNodeURL,
    tezosProtocol: TezosProtocol = .athens,
    forgingPolicy: ForgingPolicy = .remote,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    let networkClient = NetworkClientImpl(
      remoteNodeURL: remoteNodeURL,
      urlSession: urlSession,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )

    self.init(
      networkClient: networkClient,
      tezosProtocol: tezosProtocol,
      forgingPolicy: forgingPolicy,
      callbackQueue: callbackQueue
    )
  }

  /// An internal initializer which allows injection of a network client for testability.
  internal init(
    networkClient: NetworkClient,
    tezosProtocol: TezosProtocol = .athens,
    forgingPolicy: ForgingPolicy = .remote,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    self.networkClient = networkClient
    self.callbackQueue = callbackQueue

    forgingService = ForgingService(forgingPolicy: forgingPolicy, networkClient: networkClient)
    operationMetadataProvider = OperationMetadataProvider(networkClient: networkClient)

    simulationService = SimulationService(
      networkClient: networkClient,
      operationMetadataProvider: operationMetadataProvider
    )

    let feeEstimator = FeeEstimator(
      forgingService: forgingService,
      operationMetadataProvider: operationMetadataProvider,
      simulationService: simulationService
    )

    operationFactory = OperationFactory(tezosProtocol: tezosProtocol, feeEstimator: feeEstimator)

    injectionService = InjectionService(networkClient: networkClient)
    preapplicationService = PreapplicationService(networkClient: networkClient)
  }

  // MARK: - Queries

  /// Retrieve data about the chain head.
  public func getHead(completion: @escaping (Result<[String: Any], TezosKitError>) -> Void) {
    let rpc = GetChainHeadRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve the balance of a given wallet.
  public func getBalance(wallet: Wallet, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    getBalance(address: wallet.address, completion: completion)
  }

  /// Retrieve the balance of a given address.
  public func getBalance(address: Address, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    let rpc = GetAddressBalanceRPC(address: address)
    self.run(rpc, completion: completion)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    getDelegate(address: wallet.address, completion: completion)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: Address, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetDelegateRPC(address: address)
    self.run(rpc, completion: completion)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetChainHeadHashRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: Address, completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetAddressCounterRPC(address: address)
    self.run(rpc, completion: completion)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(
    address: Address,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let rpc = GetAddressManagerKeyRPC(address: address)
    self.run(rpc, completion: completion)
  }

  /// Retrieve ballots cast so far during a voting period.
  public func getBallotsList(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetBallotsListRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve the expected quorum.
  public func getExpectedQuorum(completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetExpectedQuorumRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve the current period kind for voting.
  public func getCurrentPeriodKind(completion: @escaping (Result<PeriodKind, TezosKitError>) -> Void) {
    let rpc = GetCurrentPeriodKindRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve the sum of ballots cast so far during a voting period.
  public func getBallots(completion: @escaping (Result<[String: Any], TezosKitError>) -> Void) {
    let rpc = GetBallotsRPC()
    self.run(rpc, completion: completion)  }

  /// Retrieve a list of proposals with number of supporters.
  public func getProposalsList(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetProposalsListRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve the current proposal under evaluation.
  public func getProposalUnderEvaluation(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetProposalUnderEvaluationRPC()
    self.run(rpc, completion: completion)
  }

  /// Retrieve a list of delegates with their voting weight, in number of rolls.
  public func getVotingDelegateRights(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetVotingDelegateRightsRPC()
    self.run(rpc, completion: completion)

  }

  /// Run an arbitrary RPC.
  ///
  /// - Parameters:
  ///   - rpc: The RPC to run.
  ///   - completion : A completion block which handles the results of the RPC
  public func run<T>(_ rpc: RPC<T>, completion: @escaping (Result<T, TezosKitError>) -> Void) {
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
    self.run(rpc, completion: completion)
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
    self.run(rpc, completion: completion)
  }

  /// Retrieve a value from a big map. 
  ///
  /// - Parameters:
  ///   - bigMapID: The ID of the big map.
  ///   - key: The key in the big map to look up.
  ///   - type: The michelson type of the key.
  ///   - completion: A completion block to call.  
  public func getBigMapValue(
    bigMapID: BigInt,
    key: MichelsonParameter,
    type: MichelsonComparable,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    let payload = PackDataPayload(michelsonParameter: key, michelsonComparable: type)
    let packDataRPC = PackDataRPC(payload: payload)

    self.run(packDataRPC) { [weak self] result in
      guard let self = self else {
        return
      }

      guard case let .success(expression) = result else {
        completion(
          result.map { _ in [:] }
        )
        return
      }

      let bigMapValueRPC = GetBigMapValueByIDRPC(bigMapID: bigMapID, expression: expression)
      self.run(bigMapValueRPC, completion: completion)
    }
  }

  // MARK: - Operations

  /// Transact Tezos between accounts.
  ///
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    send(
      amount: amount,
      to: recipientAddress,
      from: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: policy,
      completion: completion
    )
  }

  /// Transact Tezos between accounts.
  ///
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = operationFactory.transactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let transactionOperation):
      forgeSignPreapplyAndInject(
        transactionOperation,
        source: source,
        signatureProvider: signatureProvider,
        completion: completion
      )
    case .failure(let error):
      callbackQueue.async {
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      }
    }
  }

  /// Call a smart contract.
  ///
  /// - Parameters:
  ///   - contract: The smart contract to invoke.
  ///   - amount: The amount of Tez to transfer with the invocation. Default is 0.
  ///   - parameter: An optional parameter to send to the smart contract. Default is none.
  ///   - source: The address invoking the contract.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - completion: A completion block called with an optional transaction hash and error.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func call(
    contract: Address,
    amount: Tez = Tez.zeroBalance,
    parameter: MichelsonParameter? = nil,
    source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    call(
      contract: contract,
      amount: amount,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: policy,
      completion: completion
    )
  }

  /// Call a smart contract.
  ///
  /// - Parameters:
  ///   - contract: The smart contract to invoke.
  ///   - amount: The amount of Tez to transfer with the invocation. Default is 0.
  ///   - entrypoint: An optional entrypoint to use for the transaction. Default is nil.
  ///   - parameter: An optional parameter to send to the smart contract. Default is none.
  ///   - source: The address invoking the contract.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func call(
    contract: Address,
    amount: Tez = Tez.zeroBalance,
    entrypoint: String? = nil,
    parameter: MichelsonParameter? = nil,
    source: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = operationFactory.smartContractInvocationOperation(
      amount: amount,
      entrypoint: entrypoint,
      parameter: parameter,
      source: source,
      destination: contract,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let smartContractInvocationOperation):
      forgeSignPreapplyAndInject(
        smartContractInvocationOperation,
        source: source,
        signatureProvider: signatureProvider,
        completion: completion
      )
    case .failure(let error):
      callbackQueue.async {
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      }
    }
  }

  /// Delegate the balance of an account.
  ///
  /// - Parameters:
  ///   - source: The address which will delegate.
  ///   - delegate: The address which will receive the delegation.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func delegate(
    from source: Address,
    to delegate: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    self.delegate(
      from: source,
      to: delegate,
      signatureProvider: signatureProvider,
      operationFeePolicy: policy,
      completion: completion
    )
  }

  /// Delegate the balance of an account.
  ///
  /// - Parameters:
  ///   - source: The address which will delegate.
  ///   - delegate: The address which will receive the delegation.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func delegate(
    from source: Address,
    to delegate: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = operationFactory.delegateOperation(
      source: source,
      to: delegate,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let delegationOperation):
      forgeSignPreapplyAndInject(
        delegationOperation,
        source: source,
        signatureProvider: signatureProvider,
        completion: completion
      )
    case .failure(let error):
      callbackQueue.async {
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      }
    }
  }

  /// Clear the delegate of an account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func undelegate(
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    undelegate(from: source, signatureProvider: signatureProvider, operationFeePolicy: policy, completion: completion)
  }

  /// Clear the delegate of an account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func undelegate(
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = operationFactory.undelegateOperation(
      source: source,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let undelegateOperation):
      forgeSignPreapplyAndInject(
        undelegateOperation,
        source: source,
        signatureProvider: signatureProvider,
        completion: completion
      )
    case .failure(let error):
      callbackQueue.async {
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      }
      return
    }
  }

  /// Register an address as a delegate.
  ///
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func registerDelegate(
    delegate: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    registerDelegate(
      delegate: delegate,
      signatureProvider: signatureProvider,
      operationFeePolicy: policy,
      completion: completion
    )
  }

  /// Register an address as a delegate.
  ///
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func registerDelegate(
    delegate: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = operationFactory.registerDelegateOperation(
      source: delegate,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let registerDelegateOperation):
      forgeSignPreapplyAndInject(
        registerDelegateOperation,
        source: delegate,
        signatureProvider: signatureProvider,
        completion: completion
      )
    case .failure(let error):
      callbackQueue.async {
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      }
    }
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
    completion: @escaping (Result<SimulationResult, TezosKitError>) -> Void
  ) {
    simulationService.simulate(operation, from: wallet.address, signatureProvider: wallet, completion: completion)
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

      guard
        case let .success(operationMetadata) = result,
        let operationPayload = OperationPayloadFactory.operationPayload(
          from: operations,
          source: source,
          signatureProvider: signatureProvider,
          operationMetadata: operationMetadata
        )
      else {
        completion(
          result.map { _ in "" }
        )
        return
      }

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
      let signatureHex = CryptoUtils.binToHex(signature),
      let signedBytesForInjection = JSONUtils.jsonString(for: forgeResult + signatureHex),
      let signedOperationPayload = SignedOperationPayload(
        operationPayload: operationPayload,
        signature: signature,
        signingCurve: signatureProvider.publicKey.signingCurve
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
