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
  public func getBalance(address: String) -> Promise<Tez> {
    let rpc = GetAddressBalanceRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Retrieve the delegate of a given wallet.
  public func getDelegate(wallet: Wallet) -> Promise<String> {
    return getDelegate(address: wallet.address)
  }

  /// Retrieve the delegate of a given address.
  public func getDelegate(address: String) -> Promise<String> {
    let rpc = GetDelegateRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Retrieve the hash of the block at the head of the chain.
  public func getHeadHash() -> Promise<String> {
    let rpc = GetChainHeadHashRPC()
    return networkClient.send(rpc)
  }

  /// Retrieve the address counter for the given address.
  public func getAddressCounter(address: String) -> Promise<Int> {
    let rpc = GetAddressCounterRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Retrieve the address manager key for the given address.
  public func getAddressManagerKey(address: String) -> Promise<[String: Any]> {
    let rpc = GetAddressManagerKeyRPC(address: address)
    return networkClient.send(rpc)
  }

  /// Transact Tezos between accounts.
  /// - Parameters:
  ///   - amount: The amount of Tez to send.
  ///   - recipientAddress: The address which will receive the Tez.
  ///   - source: The address sending the balance.
  ///   - signer: The object which will sign the operation.
  ///   - parameters: Optional parameters to include in the transaction if the call is being made to a smart contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func send(
    amount: Tez,
    to recipientAddress: String,
    from source: String,
    signer: Signer,
    parameters: [String: Any]? = nil,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let transactionOperation = operationFactory.transactionOperation(
      amount: amount,
      source: source,
      destination: recipientAddress,
      parameters: parameters,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: transactionOperation,
      source: source,
      signer: signer
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
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func delegate(
    from source: String,
    to delegate: String,
    signer: Signer,
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
      signer: signer
    )
  }

  /// Clear the delegate of an originated account.
  /// - Parameters:
  ///   - source: The address which is removing the delegate.
  ///   - signer: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func undelegate(
    from source: String,
    signer: Signer,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let undelegateOperatoin = operationFactory.undelegateOperation(
      source: source,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: undelegateOperatoin,
      source: source,
      signer: signer
    )
  }

  /// Register an address as a delegate.
  /// - Parameters:
  ///   - delegate: The address registering as a delegate.
  ///   - signer: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func registerDelegate(
    delegate: String,
    signer: Signer,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let registerDelegateOperation = operationFactory.registerDelegateOperation(
      source: delegate,
      operationFees: operationFees
    )
    return forgeSignPreapplyAndInject(
      operation: registerDelegateOperation,
      source: delegate,
      signer: signer
    )
  }

  /// Originate a new account from the given account.
  /// - Parameters:
  ///   - managerAddress: The address which will manage the new account.
  ///   - signer: The object which will sign the operation.
  ///   - contractCode: Optional code to associate with the originated contract.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func originateAccount(
    managerAddress: String,
    signer: Signer,
    contractCode: ContractCode? = nil,
    operationFees: OperationFees? = nil
  ) -> Promise<String> {
    let originateAccountOperation =
      operationFactory.originateOperation(address: managerAddress, contractCode: contractCode, operationFees: operationFees)
    return forgeSignPreapplyAndInject(
      operation: originateAccountOperation,
      source: managerAddress,
      signer: signer
    )
  }

  /// Returns the code associated with the address as a NSDictionary.
  /// - Parameter address: The address of the contract to load.
  public func getAddressCode(address: String) -> Promise<ContractCode> {
    let rpc = GetAddressCodeRPC(address: address)
    return networkClient.send(rpc)
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

  /// Forge, sign, preapply and then inject a single operation.
  /// - Parameters:
  ///   - operation: The operation which will be forged.
  ///   - source: The address performing the operation.
  ///   - signer: The object which will sign the operation.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operation: Operation,
    source: String,
    signer: Signer
  ) -> Promise<String> {
    return forgeSignPreapplyAndInject(
      operations: [operation],
      source: source,
      signer: signer
    )
  }

  /// Forge, sign, preapply and then inject a single operation.
  ///
  /// Operations are processed in the order they are placed in the operation array.
  ///
  /// - Parameters:
  ///   - operations: An array of operations that will be forged.
  ///   - source: The address performing the operation.
  ///   - signer: The object which will sign the operation.
  /// - Returns: A promise which resolves to a string representing the transaction hash.
  public func forgeSignPreapplyAndInject(
    operations: [Operation],
    source: String,
    signer: Signer
  ) -> Promise<String> {
    return Promise { seal in
      forgeSignPreapplyAndInject(operations, source: source, signer: signer) { result in
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
