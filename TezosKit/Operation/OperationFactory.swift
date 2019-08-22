// Copyright Keefer Taylor, 2019.

import Foundation
import TezosCrypto

/// A factory which can produce operations.
public class OperationFactory {
  /// The provider for default fees.
  private let defaultFeeProvider: DefaultFeeProvider.Type

  /// The protocol this operation factory will produce operations for.
  private let tezosProtocol: TezosProtocol

  /// An object that can estimate fees for operations.
  private let feeEstimator: FeeEstimator

  /// Identifier for the internal dispatch queue.
  private static let queueIdentifier = "com.keefertaylor.TezosKit.OperationFactory"

  /// Internal Queue to use in order to perform asynchronous work.
  private let operationFactoryQueue: DispatchQueue

  /// Create a new operation factory.
  ///
  /// - Parameters:
  ///   - tezosProtocol: The protocol that this factory will provide operations for. Default is athens.
  ///   - feeEstimator: An object that can estimate fees for operations.
  public init(tezosProtocol: TezosProtocol = .athens, feeEstimator: FeeEstimator) {
    defaultFeeProvider = DefaultFeeProvider.self
    self.tezosProtocol = tezosProtocol
    self.feeEstimator = feeEstimator
    operationFactoryQueue = DispatchQueue(label: OperationFactory.queueIdentifier)
  }

  /// Create a new reveal operation.
  ///
  /// - Parameters:
  ///   - address: The address to reveal.
  ///   - publicKey: The public key of the address to reveal.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func revealOperation(
    from address: Address,
    publicKey: PublicKey,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = RevealOperation(from: address, publicKey: publicKey, operationFees: OperationFees.zeroFees)
    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: address,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }
    operation.operationFees = fees
    return operation
  }

  /// Create a new origination operation.
  ///
  /// - Parameters:
  ///   - address: The address which will originate the new account.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func originationOperation(
    address: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = OriginationOperation(address: address, operationFees: OperationFees.zeroFees)

    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: address,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }

    operation.operationFees = fees
    return operation
  }

  /// Create a delegation operation which will register the given address as a delegate.
  ///
  /// - Parameters:
  ///   - source: The address that will register as a delegate.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func registerDelegateOperation(
    source: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = DelegationOperation(source: source, delegate: source, operationFees: OperationFees.zeroFees)

    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: source,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }

    operation.operationFees = fees
    return operation
  }

  /// Create a delegation operation which will delegate to the given address.
  ///
  /// - Parameters:
  ///   - source: The address that will delegate funds.
  ///   - delegate: The address to delegate to.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func delegateOperation(
    source: Address,
    to delegate: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = DelegationOperation(source: source, delegate: delegate, operationFees: OperationFees.zeroFees)

    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: source,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }

    operation.operationFees = fees
    return operation
  }

  /// Create a delegation operation which will clear the delegate from the given address.
  ///
  /// - Parameters:
  ///   - source: The address that will have its delegate cleared.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func undelegateOperation(
    source: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = DelegationOperation(source: source, delegate: nil, operationFees: OperationFees.zeroFees)
    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: source,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }

    operation.operationFees = fees
    return operation
  }

  /// Create a new transaction operation.
  ///
  /// - Parameters:
  ///   - amount: The amount of XTZ to transact.
  ///   - from: The address that is sending the XTZ.
  ///   - to: The address that is receiving the XTZ.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func transactionOperation(
    amount: Tez,
    source: Address,
    destination: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = TransactionOperation(
      amount: amount,
      source: source,
      destination: destination,
      operationFees: OperationFees.zeroFees
    )

    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: source,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }

    operation.operationFees = fees
    return operation
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
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func smartContractInvocationOperation(
    amount: Tez,
    parameter: MichelsonParameter?,
    source: Address,
    destination: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Operation? {
    let operation = TransactionOperation(
      amount: amount,
      parameter: parameter,
      source: source,
      destination: destination,
      operationFees: OperationFees.zeroFees
    )

    guard
      let fees = operationFees(
        from: operationFeePolicy,
        address: source,
        operation: operation,
        signatureProvider: signatureProvider,
        tezosProtocol: tezosProtocol
      )
    else {
      return nil
    }

    operation.operationFees = fees
    return operation
  }

  // MARK: - Internal

  private func operationFees(
    from policy: OperationFeePolicy,
    address: Address,
    operation: Operation,
    signatureProvider: SignatureProvider,
    tezosProtocol: TezosProtocol
  ) -> OperationFees? {
    switch policy {
    case .default:
      return defaultFeeProvider.fees(for: operation.kind, in: tezosProtocol)
    case .custom(let operationFees):
      return operationFees
    case .estimate:
      let estimationGroup = DispatchGroup()

      var fees: OperationFees?

      estimationGroup.enter()

      operationFactoryQueue.async {
        self.feeEstimator.estimate(
          operation: operation,
          address: address,
          signatureProvider: signatureProvider
        ) { result in
          defer {
            estimationGroup.leave()
          }

          guard let estimatedFees = result else {
            return
          }
          fees = estimatedFees
        }
      }

      estimationGroup.wait()
      return fees
    }
  }
}
