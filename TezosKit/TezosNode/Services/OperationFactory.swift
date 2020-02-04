// Copyright Keefer Taylor, 2019.

import Foundation

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
    publicKey: PublicKeyProtocol,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Result<Operation, TezosKitError> {
    let operation = RevealOperation(from: address, publicKey: publicKey, operationFees: OperationFees.zeroFees)
    let feeResult = operationFees(
      from: operationFeePolicy,
      address: address,
      operation: operation,
      signatureProvider: signatureProvider,
      tezosProtocol: tezosProtocol
    )

    switch feeResult {
    case .success(let fees):
      operation.operationFees = fees
      return .success(operation)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }
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
  ) -> Result<Operation, TezosKitError> {
    let operation = DelegationOperation(source: source, delegate: source, operationFees: OperationFees.zeroFees)
    let feeResult = operationFees(
      from: operationFeePolicy,
      address: source,
      operation: operation,
      signatureProvider: signatureProvider,
      tezosProtocol: tezosProtocol
    )

    switch feeResult {
    case .success(let fees):
      operation.operationFees = fees
      return .success(operation)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }
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
  ) -> Result<Operation, TezosKitError> {
    let operation = DelegationOperation(source: source, delegate: delegate, operationFees: OperationFees.zeroFees)
    let feeResult = operationFees(
      from: operationFeePolicy,
      address: source,
      operation: operation,
      signatureProvider: signatureProvider,
      tezosProtocol: tezosProtocol
    )

    switch feeResult {
    case .success(let fees):
      operation.operationFees = fees
      return .success(operation)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }
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
  ) -> Result<Operation, TezosKitError> {
    let operation = DelegationOperation(source: source, delegate: nil, operationFees: OperationFees.zeroFees)
    let feeResult = operationFees(
      from: operationFeePolicy,
      address: source,
      operation: operation,
      signatureProvider: signatureProvider,
      tezosProtocol: tezosProtocol
    )

    switch feeResult {
    case .success(let fees):
      operation.operationFees = fees
      return .success(operation)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }
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
  ) -> Result<Operation, TezosKitError> {
    let operation = TransactionOperation(
      amount: amount,
      source: source,
      destination: destination,
      operationFees: OperationFees.zeroFees
    )

    let feeResult = operationFees(
      from: operationFeePolicy,
      address: source,
      operation: operation,
      signatureProvider: signatureProvider,
      tezosProtocol: tezosProtocol
    )

    switch feeResult {
    case .success(let fees):
      operation.operationFees = fees
      return .success(operation)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }
  }

  /// Create a new smart contract invocation operation.
  ///
  /// - Parameters:
  ///   - contract: The smart contract to invoke.
  ///   - amount: The amount of Tez to transfer with the invocation.
  ///   - entrypoint: An optional entrypoint to use for the transaction.
  ///   - parameter: An optional parameter to send to the smart contract.
  ///   - source: The address invoking the contract.
  ///   - signatureProvider: The object which will sign the operation.
  ///   - operationFeePolicy: A policy to apply when determining operation fees.
  ///   - signatureProvider: A signature provider which can sign the operation.
  public func smartContractInvocationOperation(
    amount: Tez,
    entrypoint: String?,
    parameter: MichelsonParameter?,
    source: Address,
    destination: Address,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Result<Operation, TezosKitError> {
    let operation = SmartContractInvocationOperation(
      amount: amount,
      entrypoint: entrypoint,
      parameter: parameter,
      source: source,
      destination: destination,
      operationFees: OperationFees.zeroFees
    )

    let feeResult = operationFees(
      from: operationFeePolicy,
      address: source,
      operation: operation,
      signatureProvider: signatureProvider,
      tezosProtocol: tezosProtocol
    )

    switch feeResult {
    case .success(let fees):
      operation.operationFees = fees
      return .success(operation)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }

  }

  // MARK: - Internal

  private func operationFees(
    from policy: OperationFeePolicy,
    address: Address,
    operation: Operation,
    signatureProvider: SignatureProvider,
    tezosProtocol: TezosProtocol
  ) -> Result<OperationFees, TezosKitError> {
    switch policy {
    case .default:
      return .success(defaultFeeProvider.fees(for: operation.kind, in: tezosProtocol))
    case .custom(let operationFees):
      return .success(operationFees)
    case .estimate:
      let estimationGroup = DispatchGroup()

      var fees: Result<OperationFees, TezosKitError> = .failure(TezosKitError(kind: .unknown))

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
          fees = result
        }
      }

      estimationGroup.wait()
      return fees
    }
  }
}
