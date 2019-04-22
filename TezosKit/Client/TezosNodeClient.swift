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
///       source: String,
///       keys: Keys,
///       completion: @escaping (String?, Error?) -> Void
///     )
///
/// Clients can also send multiple signed operations at once by constructing an array of operations.
/// Operations are applied in the order they are given in the array. Clients should pass the array
/// to:
///     func forgeSignPreapplyAndInjectOperations(
///       _ operations: [Operation],
///       source: String,
///       keys: Keys,
///       completion: @escaping (String?, Error?) -> Void
///     )
///
/// Some signed operations require an address be revealed in order to complete the operation. For
/// operations supported in TezosKit, the reveal operation will be automatically applied when needed.
/// For clients who create their own custom signed operations, TezosKit will apply the reveal
/// operation correctly as long as the |requiresReveal| bit on the custom Operation object is set
/// correctly.
public class TezosNodeClient: AbstractClient {
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

  /// Initialize a new TezosNodeClient.
  /// - Parameters:
  ///   - remoteNodeURL: The path to the remote node, defaults to the default URL
  ///   - urlSession: The URLSession that will manage network requests, defaults to the shared session.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.
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

  /// Retrieve data about the chain head.
  public func getHead(completion: @escaping (Result<[String: Any], TezosKitError>) -> Void) {
    let rpc = GetChainHeadRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve the balance of a given wallet.
  public func getBalance(wallet: Wallet, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    getBalance(address: wallet.address, completion: completion)
  }

  /// Retrieve the balance of a given address.
  public func getBalance(address: String, completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    let rpc = GetAddressBalanceRPC(address: address)
    send(rpc, completion: completion)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    getDelegate(address: wallet.address, completion: completion)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: String, completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetDelegateRPC(address: address)
    send(rpc, completion: completion)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetChainHeadHashRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: String, completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetAddressCounterRPC(address: address)
    send(rpc, completion: completion)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(
    address: String,
    completion: @escaping (Result<[String: Any], TezosKitError>) -> Void
  ) {
    let rpc = GetAddressManagerKeyRPC(address: address)
    send(rpc, completion: completion)
  }

  /// Transact Tezos between accounts.
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - parameters: Optional parameters to include in the transaction if the call is being made to a smart contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: String,
    keys: Keys,
    parameters: [String: Any]? = nil,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let transactionOperation = TransactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      parameters: parameters,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      transactionOperation,
      source: source,
      keys: keys,
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
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func delegate(
    from source: String,
    to delegate: String,
    keys: Keys,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let delegationOperation = DelegationOperation.delegateOperation(
      source: source,
      to: delegate,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      delegationOperation,
      source: source,
      keys: keys,
      completion: completion
    )
  }

  /// Clear the delegate of an originated account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func undelegate(
    from source: String,
    keys: Keys,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let undelegateOperatoin = DelegationOperation.undelegateOperation(source: source, operationFees: operationFees)
    forgeSignPreapplyAndInject(
      undelegateOperatoin,
      source: source,
      keys: keys,
      completion: completion
    )
  }

  /// Register an address as a delegate.
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block called with an optional transaction hash and error.
  public func registerDelegate(
    delegate: String,
    keys: Keys,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let registerDelegateOperation = DelegationOperation.registerDelegateOperation(
      source: delegate,
      operationFees: operationFees
    )
    forgeSignPreapplyAndInject(
      registerDelegateOperation,
      source: delegate,
      keys: keys,
      completion: completion
    )
  }

  /// Originate a new account from the given account.
  /// - Parameters:
  ///   - managerAddress: The address which will manage the new account.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - contractCode: Optional code to associate with the originated contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  ///   - completion: A completion block which will be called with a string representing the transaction ID hash if the
  ///                 operation was successful.
  public func originateAccount(
    managerAddress: String,
    keys: Keys,
    contractCode: ContractCode? = nil,
    operationFees: OperationFees? = nil,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let originateAccountOperation =
      OriginateAccountOperation(address: managerAddress, contractCode: contractCode, operationFees: operationFees)
    forgeSignPreapplyAndInject(
      originateAccountOperation,
      source: managerAddress,
      keys: keys,
      completion: completion
    )
  }

  /// Returns the code associated with the address as a NSDictionary.
  /// - Parameter address: The address of the contract to load.
  public func getAddressCode(address: String, completion: @escaping (Result<ContractCode, TezosKitError>) -> Void) {
    let rpc = GetAddressCodeRPC(address: address)
    send(rpc, completion: completion)
  }

  /// Retrieve ballots cast so far during a voting period.
  public func getBallotsList(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetBallotsListRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve the expected quorum.
  public func getExpectedQuorum(completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let rpc = GetExpectedQuorumRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve the current period kind for voting.
  public func getCurrentPeriodKind(completion: @escaping (Result<PeriodKind, TezosKitError>) -> Void) {
    let rpc = GetCurrentPeriodKindRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve the sum of ballots cast so far during a voting period.
  public func getBallots(completion: @escaping (Result<[String: Any], TezosKitError>) -> Void) {
    let rpc = GetBallotsRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve a list of proposals with number of supporters.
  public func getProposalsList(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetProposalsListRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve the current proposal under evaluation.
  public func getProposalUnderEvaluation(completion: @escaping (Result<String, TezosKitError>) -> Void) {
    let rpc = GetProposalUnderEvaluationRPC()
    send(rpc, completion: completion)
  }

  /// Retrieve a list of delegates with their voting weight, in number of rolls.
  public func getVotingDelegateRights(completion: @escaping (Result<[[String: Any]], TezosKitError>) -> Void) {
    let rpc = GetVotingDelegateRightsRPC()
    send(rpc, completion: completion)
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
    getMetadataForOperation(address: wallet.address) { [weak self] result in
      guard let self = self else {
        return
      }
      guard case let .success(metadata) = result else {
        completion(
          result.map { _ in [:] }
        )
        return
      }

      let operationPayload = self.createOperationPayload(operations: [operation], operationMetadata: metadata)
      self.forgeOperation(operationPayload: operationPayload, operationMetadata: metadata) { [weak self] result in
        guard let self = self else {
          return
        }
        guard case let .success(bytes) = result else {
          completion(
            result.map { _ in [:] }
          )
          return
        }

        guard let (_, signedOperationPayload) = self.sign(
            operationPayload: operationPayload,
            forgedPayload: bytes,
            keys: wallet.keys
        ) else {
          let error = TezosKitError(kind: .signingError, underlyingError: nil)
          completion(.failure(error))
          return
        }
        let rpc = RunOperationRPC(signedOperationPayload: signedOperationPayload)
        self.send(rpc, completion: completion)
      }
    }
  }

  // MARK: - Private Methods

  /// Forges an operation.
  /// - Parameters:
  ///   - operationPayload: A payload with an operation to forge to bytes.
  ///   - operationMetadata: Metadata aboute the operation to apply to the forge request.
  ///   - completion: A closure called with the string representing the forged bytes or an error.
  private func forgeOperation(
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let rpc = ForgeOperationRPC(operationPayload: operationPayload, operationMetadata: operationMetadata)
    self.send(rpc, completion: completion)
  }

  /// Creates a operation payload from operations.
  /// - Parameters:
  ///   - operations: A list of operations to forge.
  ///   - operationMetadata: Metadata about the operations.
  /// - Returns: A `OperationPayload` that represents the inputs.
  private func createOperationPayload(
    operations: [Operation],
    operationMetadata: OperationMetadata
  ) -> OperationPayload {
    // Process all operations to have increasing counters and place them in the contents array.
    var nextCounter = operationMetadata.addressCounter + 1
    var operationsWithCounter: [OperationWithCounter] = []
    for operation in operations {
      let operationWithCounter = OperationWithCounter(operation: operation, counter: nextCounter)
      operationsWithCounter.append(operationWithCounter)
      nextCounter += 1
    }
    return OperationPayload(operations: operationsWithCounter, operationMetadata: operationMetadata)
  }

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// - Parameters:
  ///   - operation: The operation which will be used to forge the operation.
  ///   - source: The address performing the operation.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - completion: A completion block that will be called with the results of the operation.
  public func forgeSignPreapplyAndInject(
    _ operation: Operation,
    source: String,
    keys: Keys,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    forgeSignPreapplyAndInject(
      [operation],
      source: source,
      keys: keys,
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
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - completion: A completion block that will be called with the results of the operation.
  public func forgeSignPreapplyAndInject(
    _ operations: [Operation],
    source: String,
    keys: Keys,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    getMetadataForOperation(address: source) { [weak self] result in
      guard let self = self else {
        return
      }
      guard case let .success(operationMetadata) = result else {
        completion(
          result.map { _ in "" }
        )
        return
      }

      // Determine if the address performing the operations has been revealed. If it has not been,
      // check if any of the operations to perform requires the address to be revealed. If so,
      // prepend a reveal operation to the operations to perform.
      var mutableOperations = operations
      if operationMetadata.key == nil && operations.first(where: { $0.requiresReveal }) != nil {
        let revealOperation = RevealOperation(from: source, publicKey: keys.publicKey)
        mutableOperations.insert(revealOperation, at: 0)
      }
      let operationPayload =
        self.createOperationPayload(operations: mutableOperations, operationMetadata: operationMetadata)

      self.forgeOperation(
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
        print(forgedBytes)
        let forged2 = "53313c4882cf49a0141ae2f06fa5988568aef35d9ed00ec3df4f83521917a94009000081faa75f741ef614b0e35fcc8c90dfa3b0b95721d0860399f10180b518e0d4030081faa75f741ef614b0e35fcc8c90dfa3b0b9572100000000ff00000a1a0200000a1505000864046800000010255f4c69715f656e7472795f766f7465046c00000012255f4c69715f656e7472795f7061796f7574000000093a5f656e7472696573050108650861036e036c000000073a766f7465727307650860036803620000000625766f746573076508600368035d0000000a25616464726573736573046b0000000925646561646c696e65000000083a73746f72616765050202000009770321051f02000000160417000000104073746f726167655f736c6173685f3104160000001240706172616d657465725f736c6173685f3204210000000a40706172616d65746572072e02000003d60458000000104063686f6963655f736c6173685f31330200000025051f020000001c0200000017051f020000000e0421000000084073746f72616765034c034c0421000000084073746f7261676502000000130317031704170000000925646561646c696e6503400319032a072c020000001807430368010000000d566f74696e6720636c6f73656403270200000002034f03200743036a0080ade204031303190337072c02000000310743036801000000264e6f7420656e6f756768206d6f6e65792c206174206c656173742035747a20746f20766f746503270200000002034f03200421000000084073746f7261676504160000000725766f7465727303480339072c0200000020034807430368010000001148617320616c726561647920766f746564034203270200000002034f03200421000000084073746f726167650200000015031704160000000d40766f7465732025766f74657304210000000640766f7465730200000032051f02000000290200000024051f020000001b0200000016051f020000000d0421000000074063686f696365034c034c034c0329072f020000003e0200000024051f020000001b0200000016051f020000000d0421000000074063686f696365034c034c07430368010000000842616420766f74650342032702000001df0200000025051f020000001c0200000017051f020000000e0421000000084073746f72616765034c034c032104160000000725766f74657273034c031703170200000031051f02000000280200000023051f020000001a0200000015051f020000000c04210000000640766f746573034c034c034c074303620001020000003b051f0200000032020000002d051f0200000024020000001f051f02000000160200000011051f02000000080421000000024078034c034c034c034c0312020000006a051f0200000061020000005c051f0200000053020000004e051f02000000450200000040051f02000000370200000032051f02000000290200000024051f020000001b0200000016051f020000000d0421000000074063686f696365034c034c034c034c034c034c034c051f02000000020346035004420000000625766f746573034c0442000000104073746f726167652025766f746572730421000000084073746f7261676503170200000017051f020000000e0421000000084073746f72616765034c04160000000725766f74657273034f0348051f02000000020346051f0200000019051f0200000012051f020000000b051f02000000040320032003500442000000104073746f726167652025766f74657273053d036d0342051f0200000006032003200320020000054304580000000b405f5f736c6173685f31390200000025051f020000001c0200000017051f020000000e0421000000084073746f72616765034c034c0421000000084073746f7261676502000000130317031704170000000925646561646c696e65034003190332072c020000001907430368010000000e566f74696e67206f6e676f696e6703270200000002034f03200421000000084073746f72616765020000000e031704160000000625766f74657307430765055f036803620707020000000000000200000015051f020000000c04210000000640766f746573034c055202000002a804580000001d405f6e616d655f6e625f77696e6e6572735f6d61785f736c6173685f34051f02000000020321034203210316041600000005406e616d65020000000b051f02000000020321034c0316041700000003406e620200000019051f0200000010020000000b051f02000000020321034c034c03170416000000084077696e6e6572730200000027051f020000001e0200000019051f0200000010020000000b051f02000000020321034c034c034c0317041700000004406d6178042100000004406d6178020000002e051f02000000250200000020051f02000000170200000012051f0200000009042100000003406e62034c034c034c03190325072c0200000089042100000004406d61780200000025051f020000001c0200000017051f020000000e0421000000084077696e6e657273034c034c020000004c051f0200000043020000003e051f02000000350200000030051f02000000270200000022051f02000000190200000014051f020000000b042100000005406e616d65034c034c034c034c034c031b03420200000101042100000004406d6178020000002e051f02000000250200000020051f02000000170200000012051f0200000009042100000003406e62034c034c034c0319032a072c020000007e0200000020051f02000000170200000012051f0200000009042100000003406e62034c034c053d0368020000004c051f0200000043020000003e051f02000000350200000030051f02000000270200000022051f02000000190200000014051f020000000b042100000005406e616d65034c034c034c034c034c031b03420200000036042100000004406d61780200000025051f020000001c0200000017051f020000000e0421000000084077696e6e657273034c034c0342051f020000000c032003200320032003200320051f0200000002032004580000000e405f77696e6e6572735f5f6d61780416000000084077696e6e6572730200000017051f020000000e0421000000084073746f72616765034c0200000017051f020000000e0421000000084077696e6e657273034c0538020000012504580000000e406e616d655f736c6173685f32360200000033051f020000002a0200000025051f020000001c0200000017051f020000000e0421000000084073746f72616765034c034c034c02000000140317031704160000000a256164647265737365730200000014051f020000000b042100000005406e616d65034c0329072f0200000004034f032702000000000458000000054064657374031e0200000033051f020000002a0200000025051f020000001c0200000017051f020000000e0421000000084077696e6e657273034c034c034c034503150322072f020000001507430368010000000a4e6f2077696e6e657273032702000000080416000000024076051f0200000009051f0200000002032004580000000740616d6f756e74034f034d051f020000000d051f020000000603200320032004580000000b406f7065726174696f6e730342051f02000000040320032000000067070702000000000707020000000907040100000000000007070200000030070401000000000100000024747a31594c744c714431665748746853564850443131366f597673643450544148556f630100000014323031392d30342d32335431333a35353a35385a"
        self.signPreapplyAndInjectOperation(
          operationPayload: operationPayload,
          operationMetadata: operationMetadata,
          forgeResult: forged2,
          source: source,
          keys: keys,
          completion: completion
        )
      }
    }
  }

  /// Sign a forged operation.
  /// - Parameters:
  ///   - operationPayload: The operation to sign
  ///   - forgedPayload: Bytes from forging the given operationPayload.
  ///   - keys: Keys to sign the operation with.
  /// - Returns: A tuple containing signed bytes and a signed payload.
  private func sign(
    operationPayload: OperationPayload,
    forgedPayload: String,
    keys: Keys
  ) -> (signedBytes: String, signedOperationPayload: SignedOperationPayload)? {
    guard let signingResult = TezosCrypto.signForgedOperation(operation: forgedPayload, secretKey: keys.secretKey),
          let jsonSignedBytes = JSONUtils.jsonString(for: signingResult.sbytes) else {
      return nil
    }

    let signedForgeablePayload = SignedOperationPayload(
      operationPayload: operationPayload,
      signature: signingResult.edsig
    )

    return (jsonSignedBytes, signedForgeablePayload)
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
    operationPayload: OperationPayload,
    operationMetadata: OperationMetadata,
    forgeResult: String,
    source _: String,
    keys: Keys,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    guard let (signedBytes, signedOperationPayload) = sign(
      operationPayload: operationPayload,
      forgedPayload: forgeResult,
      keys: keys
    ) else {
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
      signedBytesForInjection: signedBytes,
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
    send(preapplyOperationRPC) { [weak self] result in
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
    send(injectRPC) { result in
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

  /// Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
  ///
  /// This method parallelizes fetches to get chain and address data and returns all required data together as an
  /// OperationData object.
  private func getMetadataForOperation(
    address: String,
    completion: @escaping (Result<OperationMetadata, TezosKitError>) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      let fetchersGroup = DispatchGroup()

      // Fetch data about the chain being operated on.
      var chainID: String?
      var headHash: String?
      var protocolHash: String?
      let chainHeadRequestRPC = GetChainHeadRPC()

      // Fetch data about the address being operated on.
      var operationCounter: Int?
      let getAddressCounterRPC = GetAddressCounterRPC(address: address)

      // Fetch data about the key.
      var addressKey: String?
      let getAddressManagerKeyRPC = GetAddressManagerKeyRPC(address: address)

      // Send RPCs and wait for results
      fetchersGroup.enter()
      self.send(chainHeadRequestRPC) { result in
        switch result {
        case .failure:
          break
        case .success(let json):
          if let fetchedChainID = json["chain_id"] as? String,
             let fetchedHeadHash = json["hash"] as? String,
             let fetchedProtocolHash = json["protocol"] as? String {
            chainID = fetchedChainID
            headHash = fetchedHeadHash
            protocolHash = fetchedProtocolHash
          }
        }
        fetchersGroup.leave()
      }

      fetchersGroup.enter()
      self.send(getAddressCounterRPC) { result in
        switch result {
        case .failure:
          break
        case .success(let fetchedOperationCounter):
          operationCounter = fetchedOperationCounter
        }
        fetchersGroup.leave()
      }

      fetchersGroup.enter()
      self.send(getAddressManagerKeyRPC) { result in
        switch result {
        case .failure:
          break
        case .success(let fetchedManagerAndKey):
          if let fetchedKey = fetchedManagerAndKey["key"] as? String {
            addressKey = fetchedKey
          }
        }
        fetchersGroup.leave()
      }

      fetchersGroup.wait()

      // Return fetched data as an OperationData if all data was successfully retrieved.
      if let operationCounter = operationCounter,
         let headHash = headHash,
         let chainID = chainID,
         let protocolHash = protocolHash {
        let metadata = OperationMetadata(
          chainID: chainID,
          branch: headHash,
          protocol: protocolHash,
          addressCounter: operationCounter,
          key: addressKey
        )
        completion(.success(metadata))
        return
      }
      completion(.failure(TezosKitError(kind: .unknown, underlyingError: "Couldn't fetch metadata")))
    }
  }
}
