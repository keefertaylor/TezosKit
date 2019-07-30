// Copyright Keefer Taylor, 2019.

import Foundation
import TezosCrypto

/// A factory which can produce operations.
public class OperationFactory {
  /// The provider for default fees.
  private let defaultFeeProvider: DefaultFeeProvider.Type

  /// The protocol this operation factory will produce operations for.
  private let tezosProtocol: TezosProtocol

  /// Create a new operation factory.
  ///
  /// - Parameter tezosProtocol: The protocol that this factory will provide operations for. Default is athens.
  public init(tezosProtocol: TezosProtocol = .athens) {
    defaultFeeProvider = DefaultFeeProvider.self
    self.tezosProtocol = tezosProtocol
  }

  /// Create a new reveal operation.
  ///
  /// - Parameters:
  ///   - address: The address to reveal.
  ///   - publicKey: The public key of the address to reveal.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func revealOperation(
    from address: Address,
    publicKey: PublicKey,
    operationFees: OperationFees?
  ) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .reveal, in: tezosProtocol)
    return RevealOperation(from: address, publicKey: publicKey, operationFees: operationFees)
  }

  /// Create a new origination operation.
  ///
  /// - Parameters:
  ///   - address: The address which will originate the new account.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func originationOperation(
    address: Address,
    operationFees: OperationFees?
  ) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .origination, in: tezosProtocol)
    return OriginationOperation(address: address, operationFees: operationFees)
  }

  /// Create a delegation operation which will register the given address as a delegate.
  ///
  /// - Parameters:
  ///   - source: The address that will register as a delegate.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func registerDelegateOperation(
    source: Address,
    operationFees: OperationFees?
  ) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .delegation, in: tezosProtocol)
    return DelegationOperation(source: source, delegate: source, operationFees: operationFees)
  }

  /// Create a delegation operation which will delegate to the given address.
  ///
  /// - Parameters:
  ///   - source: The address that will delegate funds.
  ///   - delegate: The address to delegate to.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func delegateOperation(
    source: Address,
    to delegate: Address,
    operationFees: OperationFees?
  ) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .delegation, in: tezosProtocol)
    return DelegationOperation(source: source, delegate: delegate, operationFees: operationFees)
  }

  /// Create a delegation operation which will clear the delegate from the given address.
  ///
  /// - Parameters:
  ///   - source: The address that will have its delegate cleared.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func undelegateOperation(source: Address, operationFees: OperationFees?) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .delegation, in: tezosProtocol)
    return DelegationOperation(source: source, delegate: nil, operationFees: operationFees)
  }

  /// Create a new transaction operation.
  ///
  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func transactionOperation(
    amount: Tez,
    source: Address,
    destination: Address,
    operationFees: OperationFees?
  ) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .transaction, in: tezosProtocol)
    return TransactionOperation(
      amount: amount,
      source: source,
      destination: destination,
      operationFees: operationFees
    )
  }

  /// Create a new smart contract invocation operation.
  ///
  /// - Parameters:
  ///   - contract: The smart contract to invoke.
  ///   - amount: The amount of Tez to transfer with the invocation.
  ///   - parameter: An optional parameter to send to the smart contract.
  ///   - source: The address invoking the contract.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public func smartContractInvocationOperation(
    amount: Tez,
    parameter: MichelsonParameter?,
    source: Address,
    destination: Address,
    operationFees: OperationFees?
  ) -> Operation {
    let operationFees = operationFees ?? defaultFeeProvider.fees(for: .transaction, in: tezosProtocol)
    return TransactionOperation(
      amount: amount,
      parameter: parameter,
      source: source,
      destination: destination,
      operationFees: operationFees
    )
  }
}
