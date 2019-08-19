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
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func revealOperation(
    from address: Address,
    publicKey: PublicKey,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .reveal,
      tezosProtocol: tezosProtocol
    )
    return RevealOperation(from: address, publicKey: publicKey, operationFees: fees)
  }

  /// Create a new origination operation.
  ///
  /// - Parameters:
  ///   - address: The address which will originate the new account.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func originationOperation(
    address: Address,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .origination,
      tezosProtocol: tezosProtocol
    )
    return OriginationOperation(address: address, operationFees: fees)
  }

  /// Create a delegation operation which will register the given address as a delegate.
  ///
  /// - Parameters:
  ///   - source: The address that will register as a delegate.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func registerDelegateOperation(
    source: Address,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .delegation,
      tezosProtocol: tezosProtocol
    )
    return DelegationOperation(source: source, delegate: source, operationFees: fees)
  }

  /// Create a delegation operation which will delegate to the given address.
  ///
  /// - Parameters:
  ///   - source: The address that will delegate funds.
  ///   - delegate: The address to delegate to.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func delegateOperation(
    source: Address,
    to delegate: Address,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .delegation,
      tezosProtocol: tezosProtocol
    )
    return DelegationOperation(source: source, delegate: delegate, operationFees: fees)
  }

  /// Create a delegation operation which will clear the delegate from the given address.
  ///
  /// - Parameters:
  ///   - source: The address that will have its delegate cleared.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func undelegateOperation(
    source: Address,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .delegation,
      tezosProtocol: tezosProtocol
    )
    return DelegationOperation(source: source, delegate: nil, operationFees: fees)
  }

  /// Create a new transaction operation.
  ///
  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func transactionOperation(
    amount: Tez,
    source: Address,
    destination: Address,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .transaction,
      tezosProtocol: tezosProtocol
    )
    return TransactionOperation(
      amount: amount,
      source: source,
      destination: destination,
      operationFees: fees
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
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  public func smartContractInvocationOperation(
    amount: Tez,
    parameter: MichelsonParameter?,
    source: Address,
    destination: Address,
    operationFeePolicy: OperationFeePolicy
  ) -> Operation {
    let fees = operationFees(
      from: operationFeePolicy,
      operationKind: .transaction,
      tezosProtocol: tezosProtocol
    )
    return TransactionOperation(
      amount: amount,
      parameter: parameter,
      source: source,
      destination: destination,
      operationFees: fees
    )
  }

  // MARK: - Internal

  // TODONOT: Why is fee provider not bound to a protocol?
  private func operationFees(
    from policy: OperationFeePolicy,
    operationKind: OperationKind,
    tezosProtocol: TezosProtocol
  ) -> OperationFees {
    switch policy {
    case .default:
      return defaultFeeProvider.fees(for: operationKind, in: tezosProtocol)
    case .custom(let operationFees):
      return operationFees
    }
  }
}
