// Copyright Keefer Taylor, 2019.

import Foundation
import PromiseKit

/// TODO: Add promise support for analog methods.
/// Extension to TezosNodeClient which provides PromiseKit functionality.
extension TezosNodeClient {
  /// Retrieve data about the chain head.
  public func getHead() -> Promise<[String: Any]> {
    let rpc = GetChainHeadRPC()
    return send(rpc)
  }

  /// Retrieve the balance of a given wallet.
  public func getBalance(wallet: Wallet) -> Promise<Tez> {
    return getBalance(address: wallet.address)
  }

  /// Retrieve the balance of a given address.
  public func getBalance(address: String) -> Promise<Tez> {
    let rpc = GetAddressBalanceRPC(address: address)
    return send(rpc)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet) -> Promise<String> {
    return getDelegate(address: wallet.address)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: String) -> Promise<String> {
    let rpc = GetDelegateRPC(address: address)
    return send(rpc)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash() -> Promise<String> {
    let rpc = GetChainHeadHashRPC()
    return send(rpc)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: String) -> Promise<Int> {
    let rpc = GetAddressCounterRPC(address: address)
    return send(rpc)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(address: String) -> Promise<[String: Any]> {
    let rpc = GetAddressManagerKeyRPC(address: address)
    return send(rpc)
  }

  /// Transact Tezos between accounts.
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - parameters: Optional parameters to include in the transaction if the call is being made to a smart contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: String,
    keys: Keys,
    parameters: [String: Any]? = nil,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let transactionOperation = TransactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      parameters: parameters,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: transactionOperation,
      source: source,
      keys: keys
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
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func delegate(
    from source: String,
    to delegate: String,
    keys: Keys,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let delegationOperation = DelegationOperation(source: source, to: delegate, operationFees: operationFees)
    return forgeSignPreapplyAndInject(
      operation: delegationOperation,
      source: source,
      keys: keys
    )
  }

  /// Clear the delegate of an originated account.
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func undelegate(
    from source: String,
    keys: Keys,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let undelegateOperatoin = UndelegateOperation(source: source, operationFees: operationFees)
    return forgeSignPreapplyAndInject(
      operation: undelegateOperatoin,
      source: source,
      keys: keys
    )
  }

  /// Register an address as a delegate.
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func registerDelegate(
    delegate: String,
    keys: Keys,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let registerDelegateOperation = RegisterDelegateOperation(delegate: delegate, operationFees: operationFees)
    return forgeSignPreapplyAndInject(
      operation: registerDelegateOperation,
      source: delegate,
      keys: keys
    )
  }

  /// Originate a new account from the given account.
  /// - Parameters:
  ///   - managerAddress: The address which will manage the new account.
  ///   - keys: The keys to use to sign the operation for the address.
  ///   - contractCode: Optional code to associate with the originated contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func originateAccount(
    managerAddress: String,
    keys: Keys,
    contractCode: ContractCode? = nil,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let originateAccountOperation =
      OriginateAccountOperation(address: managerAddress, contractCode: contractCode, operationFees: operationFees)
    return forgeSignPreapplyAndInject(
      operation: originateAccountOperation,
      source: managerAddress,
      keys: keys
    )
  }

  /// Returns the code associated with the address as a NSDictionary.
  /// - Parameter address: The address of the contract to load.
  public func getAddressCode(address: String) -> Promise<ContractCode> {
    let rpc = GetAddressCodeRPC(address: address)
    return send(rpc)
  }

  /// Retrieve ballots cast so far during a voting period.
  public func getBallotsList() -> Promise<[[String: Any]]> {
    let rpc = GetBallotsListRPC()
    return send(rpc)
  }

  ///Retrieve the expected quorum.
  public func getExpectedQuorum() -> Promise<Int> {
    let rpc = GetExpectedQuorumRPC()
    return send(rpc)
  }

  /// Retrieve the current period kind for voting.
  public func getCurrentPeriodKind() -> Promise<PeriodKind> {
    let rpc = GetCurrentPeriodKindRPC()
    return send(rpc)
  }

  /// Retrieve the sum of ballots cast so far during a voting period.
  public func getBallots() -> Promise<[String: Any]> {
    let rpc = GetBallotsRPC()
    return send(rpc)
  }

  /// Retrieve a list of proposals with number of supporters.
  public func getProposalsList() -> Promise<[[String: Any]]> {
    let rpc = GetProposalsListRPC()
    return send(rpc)
  }

  /// Retrieve the current proposal under evaluation.
  public func getProposalUnderEvaluation() -> Promise<String> {
    let rpc = GetProposalUnderEvaluationRPC()
    return send(rpc)
  }

  /// Retrieve a list of delegates with their voting weight, in number of rolls.
  public func getVotingDelegateRights() -> Promise<[[String: Any]]> {
    let rpc = GetVotingDelegateRightsRPC()
    return send(rpc)
  }

  /// Forge, sign, preapply and then inject a single operation.
  /// - Parameters:
  ///   - operation: The operation which will be forged.
  ///   - source: The address performing the operation.
  ///   - keys: The keys to use to sign the operation for the address.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operation: Operation,
    source: String,
    keys: Keys
  ) -> Promise<String> {
    return forgeSignPreapplyAndInject(
      operations: [operation],
      source: source,
      keys: keys
    )
  }

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// Operations are processed in the order they are placed in the operation array.
  ///
  /// - Parameters:
  ///   - operations: An array of operations that will be forged.
  ///   - source: The address performing the operation.
  ///   - keys: The keys to use to sign the operation for the address.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operations: [Operation],
    source: String,
    keys: Keys
  ) -> Promise<String> {
    return Promise { seal in
      forgeSignPreapplyAndInject(operations, source: source, keys: keys) { result, error in
        seal.resolve(result, error)
      }
    }
  }

  /// Runs an operation.
  /// - Parameters
  ///   - operation: The operation to run.
  ///   - wallet: The wallet requesting the run.
  ///   - completion: A completion block to call.
  public func runOperation(_ operation: Operation, from wallet: Wallet) -> Promise<[String: Any]> {
    return Promise { seal in
      runOperation(operation, from: wallet, completion: { result, error in
        seal.resolve(result, error)
      })
    }
  }
}
