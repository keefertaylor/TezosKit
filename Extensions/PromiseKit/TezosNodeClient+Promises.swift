// Copyright Keefer Taylor, 2019.

import Foundation
import PromiseKit

/// Extension to TezosNodeClient which provides PromiseKit functionality.
extension TezosNodeClient {
  /// Retrieve data about the chain head.
  public func getHead() -> Promise<[String: Any]> {
    let rpc = GetChainHeadRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the balance of a given wallet.
  public func getBalance(wallet: Wallet) -> Promise<Tez> {
    return getBalance(address: wallet.address)
  }

  /// Retrieve the balance of a given address.
  public func getBalance(address: Address) -> Promise<Tez> {
    let rpc = GetAddressBalanceRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet) -> Promise<String> {
    return getDelegate(address: wallet.address)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: Address) -> Promise<String> {
    let rpc = GetDelegateRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash() -> Promise<String> {
    let rpc = GetChainHeadHashRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: Address) -> Promise<Int> {
    let rpc = GetAddressCounterRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(address: Address) -> Promise<[String: Any]> {
    let rpc = GetAddressManagerKeyRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Transact Tezos between accounts.
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let transactionOperation = operationFactory.transactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: transactionOperation,
      source: source,
      signatureProvider: signatureProvider
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
  public func call(
    contract: Address,
    amount: Tez = Tez.zeroBalance,
    parameter: MichelsonParameter? = nil,
    source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let smartContractInvocationOperation = operationFactory.smartContractInvocationOperation(
      amount: amount,
      parameter: parameter,
      source: source,
      destination: contract,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: smartContractInvocationOperation,
      source: source,
      signatureProvider: signatureProvider
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
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func delegate(
    from source: Address,
    to delegate: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let delegationOperation = operationFactory.delegateOperation(
      source: source,
      to: delegate,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: delegationOperation,
      source: source,
      signatureProvider: signatureProvider
    )
  }

  /// Clear the delegate of an originated account.
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func undelegate(
    from source: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let undelegateOperatoin = operationFactory.undelegateOperation(
      source: source,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: undelegateOperatoin,
      source: source,
      signatureProvider: signatureProvider
    )
  }

  /// Register an address as a delegate.
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func registerDelegate(
    delegate: Address,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let registerDelegateOperation = operationFactory.registerDelegateOperation(
      source: delegate,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: registerDelegateOperation,
      source: delegate,
      signatureProvider: signatureProvider
    )
  }

  /// Originate a new account from the given account.
  /// - Parameters:
  ///   - managerAddress: The address which will manage the new account.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func originateAccount(
    managerAddress: String,
    signatureProvider: SignatureProvider,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let originationOperation = operationFactory.originationOperation(
      address: managerAddress,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: originationOperation,
      source: managerAddress,
      signatureProvider: signatureProvider
    )
  }

  /// Retrieve ballots cast so far during a voting period.
  public func getBallotsList() -> Promise<[[String: Any]]> {
    let rpc = GetBallotsListRPC()
    return networkClient.send(rpc)
  }

  ///Retrieve the expected quorum.
  public func getExpectedQuorum() -> Promise<Int> {
    let rpc = GetExpectedQuorumRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the current period kind for voting.
  public func getCurrentPeriodKind() -> Promise<PeriodKind> {
    let rpc = GetCurrentPeriodKindRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the sum of ballots cast so far during a voting period.
  public func getBallots() -> Promise<[String: Any]> {
    let rpc = GetBallotsRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve a list of proposals with number of supporters.
  public func getProposalsList() -> Promise<[[String: Any]]> {
    let rpc = GetProposalsListRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the current proposal under evaluation.
  public func getProposalUnderEvaluation() -> Promise<String> {
    let rpc = GetProposalUnderEvaluationRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve a list of delegates with their voting weight, in number of rolls.
  public func getVotingDelegateRights() -> Promise<[[String: Any]]> {
    let rpc = GetVotingDelegateRightsRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the storage of a smart contract.
  ///
  /// - Parameter address: The address of the smart contract to inspect.
  /// - Returns: A promise that resolves with the storage of the contract.
  public func getContractStorage(
    address: Address
  ) -> Promise<[String: Any]> {
    let rpc = GetContractStorageRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Forge, sign, preapply and then inject a single operation.
  /// - Parameters:
  ///   - operation: The operation which will be forged.
  ///   - source: The address performing the operation.
  ///   - signatureProvider: The object which will sign the operation.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operation: Operation,
    source: Address,
    signatureProvider: SignatureProvider
  ) -> Promise<String> {
    return forgeSignPreapplyAndInject(
      operations: [operation],
      source: source,
      signatureProvider: signatureProvider
    )
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
    return networkClient.send(rpc)
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
  public func runOperation(_ operation: Operation, from wallet: Wallet) -> Promise<[String: Any]> {
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
