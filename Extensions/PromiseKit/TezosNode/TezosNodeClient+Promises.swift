// Copyright Keefer Taylor, 2019.

import Foundation
import PromiseKit

/// Extension to TezosNodeClient which provides PromiseKit functionality.
extension TezosNodeClient {

  // MARK: - Queries

  /// Retrieve data about the chain head.
  public func getHead() -> Promise<[String: Any]> {
    let rpc = GetChainHeadRPC()
    return self.run(rpc)
  }

  /// Retrieve the balance of a given wallet.
  public func getBalance(wallet: Wallet) -> Promise<Tez> {
    return getBalance(address: wallet.address)
  }

  /// Retrieve the balance of a given address.
  public func getBalance(address: Address) -> Promise<Tez> {
    let rpc = GetAddressBalanceRPC(address: address)
    return self.run(rpc)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet) -> Promise<String> {
    return getDelegate(address: wallet.address)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: Address) -> Promise<String> {
    let rpc = GetDelegateRPC(address: address)
    return self.run(rpc)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash() -> Promise<String> {
    let rpc = GetChainHeadHashRPC()
    return self.run(rpc)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: Address) -> Promise<Int> {
    let rpc = GetAddressCounterRPC(address: address)
    return self.run(rpc)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(address: Address) -> Promise<String> {
    let rpc = GetAddressManagerKeyRPC(address: address)
    return self.run(rpc)
  }

  /// Retrieve ballots cast so far during a voting period.
  public func getBallotsList() -> Promise<[[String: Any]]> {
    let rpc = GetBallotsListRPC()
    return self.run(rpc)
  }

  ///Retrieve the expected quorum.
  public func getExpectedQuorum() -> Promise<Int> {
    let rpc = GetExpectedQuorumRPC()
    return self.run(rpc)
  }

  /// Retrieve the current period kind for voting.
  public func getCurrentPeriodKind() -> Promise<PeriodKind> {
    let rpc = GetCurrentPeriodKindRPC()
    return self.run(rpc)
  }

  /// Retrieve the sum of ballots cast so far during a voting period.
  public func getBallots() -> Promise<[String: Any]> {
    let rpc = GetBallotsRPC()
    return self.run(rpc)
  }

  /// Retrieve a list of proposals with number of supporters.
  public func getProposalsList() -> Promise<[[String: Any]]> {
    let rpc = GetProposalsListRPC()
    return self.run(rpc)
  }

  /// Retrieve the current proposal under evaluation.
  public func getProposalUnderEvaluation() -> Promise<String> {
    let rpc = GetProposalUnderEvaluationRPC()
    return self.run(rpc)
  }

  /// Retrieve a list of delegates with their voting weight, in number of rolls.
  public func getVotingDelegateRights() -> Promise<[[String: Any]]> {
    let rpc = GetVotingDelegateRightsRPC()
    return self.run(rpc)
  }

  /// Retrieve the storage of a smart contract.
  ///
  /// - Parameter address: The address of the smart contract to inspect.
  /// - Returns: A promise that resolves with the storage of the contract.
  public func getContractStorage(
    address: Address
    ) -> Promise<[String: Any]> {
    let rpc = GetContractStorageRPC(address: address)
    return self.run(rpc)
  }

  /// Inspect the value of a big map in a smart contract.
  ///
  /// - Parameters:
  ///   - address: The address of a smart contract with a big map.
  ///   - key: The key in the big map to look up.
  ///   - type: The michelson type of the key.
  public func getBigMapValue(
    address: Address,
    key: MichelsonParameter,
    type: MichelsonComparable
    ) -> Promise<[String: Any]> {
    let rpc = GetBigMapValueRPC(address: address, key: key, type: type)
    return self.run(rpc)
  }

  /// Run an arbitrary RPC.
  ///
  /// - Parameters:
  ///   - rpc: The RPC to run.
  public func run<T>(_ rpc: RPC<T>) -> Promise<T> {
    return networkClient.send(rpc)
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
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    return send(
      amount: amount,
      to: recipientAddress,
      from: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: policy
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
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func call(
    contract: Address,
    amount: Tez = Tez.zeroBalance,
    parameter: MichelsonParameter? = nil,
    source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    return call(
      contract: contract,
      amount: amount,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: policy
    )
  }

  /// Delegate the balance of an account.
  ///
  /// - Parameters:
  ///   - source: The address which will delegate.
  ///   - delegate: The address which will receive the delegation.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func delegate(
    from source: Address,
    to delegate: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    return self.delegate(from: source, to: delegate, signatureProvider: signatureProvider, operationFeePolicy: policy)
  }

  /// Clear the delegate of an account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func undelegate(
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    return undelegate(from: source, signatureProvider: signatureProvider, operationFeePolicy: policy)
  }

  /// Register an address as a delegate.
  ///
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  @available(*, deprecated, message: "Please use an OperationFeePolicy API instead.")
  public func registerDelegate(
    delegate: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    var policy = OperationFeePolicy.default
    if let operationFees = operationFees {
      policy = .custom(operationFees)
    }

    return registerDelegate(delegate: delegate, signatureProvider: signatureProvider, operationFeePolicy: policy)
  }

  /// Transact Tezos between accounts.
  ///
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default
  ) -> Promise<String> {
    let result = operationFactory.transactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let transactionOperation):
      return forgeSignPreapplyAndInject(
        operation: transactionOperation,
        source: source,
        signatureProvider: signatureProvider
      )
    case .failure(let error):
      return Promise { seal in
        seal.reject(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
      }
    }
  }

  /// Call a smart contract.
  ///
  /// - Parameters:
  ///   - contract: The smart contract to invoke.
  ///   - amount: The amount of Tez to transfer with the invocation. Default is 0.
  ///   - entrypoint: An optional entrypoint to use for the transaction. Default is nil.
  ///   - parameter: An optional parameter to send to the smart contract. Default is nil.
  ///   - source: The address invoking the contract.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func call(
    contract: Address,
    amount: Tez = Tez.zeroBalance,
    entrypoint: String? = nil,
    parameter: MichelsonParameter? = nil,
    source: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default
  ) -> Promise<String> {
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
      return forgeSignPreapplyAndInject(
        operation: smartContractInvocationOperation,
        source: source,
        signatureProvider: signatureProvider
      )
    case .failure(let error):
      return Promise { seal in
        seal.reject(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
      }
    }
  }

  /// Delegate the balance of an account.
  ///
  /// - Parameters:
  ///   - source: The address which will delegate.
  ///   - delegate: The address which will receive the delegation.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func delegate(
    from source: Address,
    to delegate: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default
  ) -> Promise<String> {
    let result = operationFactory.delegateOperation(
      source: source,
      to: delegate,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let delegationOperation):
      return forgeSignPreapplyAndInject(
        operation: delegationOperation,
        source: source,
        signatureProvider: signatureProvider
      )
    case .failure(let error):
      return Promise { seal in
        seal.reject(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
      }
    }
  }

  /// Clear the delegate of an account.
  ///
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func undelegate(
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default
  ) -> Promise<String> {
    let result = operationFactory.undelegateOperation(
      source: source,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )
    switch result {
    case .success(let undelegateOperation):
      return forgeSignPreapplyAndInject(
        operation: undelegateOperation,
        source: source,
        signatureProvider: signatureProvider
      )
    case .failure(let error):
      return Promise { seal in
        seal.reject(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
      }
    }
  }

  /// Register an address as a delegate.
  ///
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees. Default is default fees.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func registerDelegate(
    delegate: Address,
    signatureProvider: SignatureProvider,
    operationFeePolicy: OperationFeePolicy = .default
  ) -> Promise<String> {
    let result = operationFactory.registerDelegateOperation(
      source: delegate,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let registerDelegateOperation):
      return forgeSignPreapplyAndInject(
        operation: registerDelegateOperation,
        source: delegate,
        signatureProvider: signatureProvider
      )
    case .failure(let error):
      return Promise { seal in
        seal.reject(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
      }
    }
  }

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// Operations are processed in the order they are placed in the operation array.
  ///
  /// - Parameters:
  ///   - operation: An operation that will be forged.
  ///   - source: The address performing the operation.
  ///   - signatureProvider: The object which will sign the operation.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operation: Operation,
    source: Address,
    signatureProvider: SignatureProvider
  ) -> Promise<String> {
    return Promise { seal in
      forgeSignPreapplyAndInject([operation], source: source, signatureProvider: signatureProvider) { result in
        switch result {
        case .success(let data):
          seal.fulfill(data)
        case .failure(let error):
          seal.reject(error)
        }
      }
    }
  }

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// Operations are processed in the order they are placed in the operation array.
  ///
  /// - Parameters:
  ///   - operations: An array of operations that will be forged.
  ///   - source: The address performing the operation.
  ///   - signatureProvider: The object which will sign the operation.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operations: [Operation],
    source: Address,
    signatureProvider: SignatureProvider
  ) -> Promise<String> {
    return Promise { seal in
      forgeSignPreapplyAndInject(operations, source: source, signatureProvider: signatureProvider) { result in
        switch result {
        case .success(let data):
          seal.fulfill(data)
        case .failure(let error):
          seal.reject(error)
        }
      }
    }
  }

  /// Runs an operation.
  /// - Parameters:
  ///   - operation: The operation to run.
  ///   - wallet: The wallet requesting the run.
  /// - Returns: A promise which resolves to the result of running the operation.
  public func runOperation(_ operation: Operation, from wallet: Wallet) -> Promise<SimulationResult> {
    return Promise { seal in
      runOperation(operation, from: wallet) { result in
        switch result {
        case .success(let data):
            seal.fulfill(data)
        case .failure(let error):
            seal.reject(error)
        }
      }
    }
  }
}
