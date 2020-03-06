// Copyright Keefer Taylor, 2019.

import Foundation

/// NanoTez units.
private typealias NanoTez = Int

/// A class which can estimate fee, gas and storage limits for an operation.
public class FeeEstimator {
  /// The number of nanotez in a single mutez.
  private static let kNanoTezPerMutez = 1_000

  /// Maximum values for limits in OperationFees.
  private enum Maximums {
    public static let gas = 800_000
    public static let storage = 60_000
  }

  /// Constants that are used in fee calculations.
  private enum FeeConstants {
    public static let minimalFee: NanoTez = 100_000
    public static let feePerGasUnit: NanoTez = 100
    public static let feePerStorageByte: NanoTez = 1_000
  }

  /// Safety margins that will be added.
  private enum SafetyMargin {
    public static let gas = 100
    public static let storage = 257
    public static let fee = Tez(0.000_100)
  }

  /// A service which can forge operations.
  let forgingService: ForgingService

  /// A service which can provide metadata for operations.
  let operationMetadataProvider: OperationMetadataProvider

  /// A service which can simulate operations.
  let simulationService: SimulationService

  /// Identifier for the internal dispatch queue.
  private static let queueIdentifier = "com.keefertaylor.TezosKit.FeeEstimator"

  /// Internal Queue to use in order to perform asynchronous work.
  private let feeEstimatorQueue: DispatchQueue

  public init(
    forgingService: ForgingService,
    operationMetadataProvider: OperationMetadataProvider,
    simulationService: SimulationService
  ) {
    self.forgingService = forgingService
    self.operationMetadataProvider = operationMetadataProvider
    self.simulationService = simulationService
    feeEstimatorQueue = DispatchQueue(label: FeeEstimator.queueIdentifier)
  }

  /// Estimate OperationFees for the given inputs.
  ///
  /// - Parameters:
  ///   - operation: The operation to estimate fees for.
  ///   - address: The address performing the operation.
  ///   - signatureProvider: An opaque object which can sign the operation.
  ///   - completion: A completion block that will be called with the estimated fees if they could be determined.
  public func estimate(
    operation: Operation,
    address: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<OperationFees, TezosKitError>) -> Void
  ) {
    DispatchQueue.global(qos: .background).async {
      // swiftlint:disable force_cast
      let mutableOperation = operation.mutableCopy() as! Operation
      // swiftlint:enable force_cast

      // Simulate the operation to determine gas and storage limits.
      let simulationResult = self.simulateOperationSync(
        operation: mutableOperation,
        address: address,
        signatureProvider: signatureProvider
      )
      switch simulationResult {
      case .failure(let error):
        completion(.failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError)))
      case .success(let consumedResources):
        // Add safety margins for gas and storage limits.
        let gasLimit = consumedResources.consumedGas + SafetyMargin.gas
        let storageLimit = consumedResources.consumedStorage + SafetyMargin.storage

        // Start with a minimum fee equal to the minimum fee or the fee required by the gas.
        let gasFee = self.feeForGas(gas: gasLimit)
        let minimumFee = self.nanoTezToTez(nanoTez: FeeConstants.minimalFee)
        let initialFee = minimumFee + gasFee

        // Calculate the amount of fees required for the operation size.
        guard var requiredStorageFee = self.sizeFeeForOperation(
          address: address,
          operation: mutableOperation,
          signatureProvider: signatureProvider
        ) else {
          let error = TezosKitError(
            kind: .transactionFormationFailure,
            underlyingError: "Could not calculate a fee for the size of the operation"
          )
          completion(.failure(error))
          return
        }

        // Modify the operation for these fees.
        mutableOperation.operationFees = OperationFees(
          fee: initialFee,
          gasLimit: gasLimit,
          storageLimit: storageLimit
        )

        // Loop until the storage fee for the operation is above the required storage fee.
        while mutableOperation.operationFees.fee - initialFee < requiredStorageFee {
          // Calculate the needed delta on the storage fee and change it out on the operation.
          let storageFee = mutableOperation.operationFees.fee - initialFee
          let feeDifference = requiredStorageFee - storageFee
          let newFee = mutableOperation.operationFees.fee + feeDifference
          mutableOperation.operationFees = OperationFees(
            fee: newFee,
            gasLimit: mutableOperation.operationFees.gasLimit,
            storageLimit: mutableOperation.operationFees.storageLimit
          )

          // Calculate a new required storage fee, based on the updated fees.
          guard let newStorageFee = self.sizeFeeForOperation(
            address: address,
            operation: mutableOperation,
            signatureProvider: signatureProvider
          ) else {
            let error = TezosKitError(
              kind: .transactionFormationFailure,
              underlyingError: "Could not calculate a fee for the size of the operation"
            )
            completion(.failure(error))
            return
          }
          requiredStorageFee = newStorageFee
        }

        let calculatedFee = mutableOperation.operationFees.fee + SafetyMargin.fee
        let calculatedOperationFees = OperationFees(
          fee: calculatedFee,
          gasLimit: mutableOperation.operationFees.gasLimit,
          storageLimit: mutableOperation.operationFees.storageLimit
        )
        completion(.success(calculatedOperationFees))
      }
    }
  }

  // MARK: - Helpers

  /// Retrieve the given fee required for the serialized size of the operation.
  ///
  /// - Note: This method blocks the calling thread.
  ///
  /// - Parameters:
  ///   - address: The address which is performing the operation.
  ///   - operation: The operation to simulate.
  ///   - signatureProvider: An opaque object which can provide a public key.
  /// - Returns: A required fee for the operations serialized representation, if it could be determined, otherwise nil.
  private func sizeFeeForOperation(
    address: Address,
    operation: Operation,
    signatureProvider: SignatureProvider
  ) -> Tez? {
    guard let hex = self.forgeSync(address: address, operation: operation, signatureProvider: signatureProvider) else {
      return nil
    }
    return feeFromSerializedOperation(operationHex: hex)
  }

  /// Synchronously simulate the given operation.
  ///
  /// - Note: This method blocks the calling thread.
  ///
  /// - Parameters:
  ///   - operation: The operation to simulate.
  ///   - address: The address which is performing the operation.
  ///   - signatureProvider: An opaque object which can provide a public key.
  /// - Returns: A simulation result if simulation could be performed, otherwise nil.
  private func simulateOperationSync(
    operation: Operation,
    address: Address,
    signatureProvider: SignatureProvider
  ) -> Result<SimulationResult, TezosKitError> {
    // swiftlint:disable force_cast
    let maxedOperation = operation.mutableCopy() as! Operation
    // swiftlint:enable force_cast

    // Simulation will tell us the actual limits of the operation performed. Set initial gas / storage limits to the
    // maximum possible.
    let maxedFees = OperationFees(
      fee: Tez.zeroBalance,
      gasLimit: Maximums.gas,
      storageLimit: Maximums.storage
    )
    maxedOperation.operationFees = maxedFees

    let result = simulationService.simulateSync(
      maxedOperation,
      from: address,
      signatureProvider: signatureProvider
    )

    switch result {
    case .success(let simulationResult):
      return .success(simulationResult)
    case .failure(let error):
      return .failure(TezosKitError(kind: .transactionFormationFailure, underlyingError: error.underlyingError))
    }
  }

  /// Synchronously forge the given inputs.
  ///
  /// - Note: This method blocks the calling thread.
  ///
  /// - Parameters:
  ///   - address: The source address.
  ///   - operation: The operation to forge.
  ///   - signatureProvider: An opaque object which can sign the operation.
  /// - Returns: Forged hex if successful, otherwise nil.
  private func forgeSync(address: Address, operation: Operation, signatureProvider: SignatureProvider) -> Hex? {
    guard let operationMetadata = operationMetadataSync(address: address) else {
      return nil
    }

    let operationWithCounter = OperationWithCounter(operation: operation, counter: operationMetadata.addressCounter)
    let operationPayload = OperationPayload(operations: [ operationWithCounter ], operationMetadata: operationMetadata)
    let result = forgingService.forgeSync(operationPayload: operationPayload, operationMetadata: operationMetadata)
    if case let .success(hex) = result {
      return hex
    }
    return nil
  }

  /// Synchronously retrieve operation metadata.
  ///
  /// - Note: This method blocks the calling thread.
  ///
  /// - Parameter address: The address to get metadata for.
  /// - Returns: The metadata or nil if unsuccessful.
  private func operationMetadataSync(address: Address) -> OperationMetadata? {
    let result = operationMetadataProvider.metadataSync(for: address)
    if case let .success(metadata) = result {
      return metadata
    }
    return nil
  }

  /// Calcluate the fee required to fulfill the given gas limit.
  private func feeForGas(gas: Int) -> Tez {
    let nanoTez = gas * FeeConstants.feePerGasUnit
    return nanoTezToTez(nanoTez: nanoTez)
  }

  /// Get the fee required for the given serialized operation.
  ///
  /// - Note: This method assumes the given string is UTF-8
  private func feeFromSerializedOperation(operationHex: Hex) -> Tez {
    let nanoTez = operationHex.count * FeeConstants.feePerStorageByte
    return nanoTezToTez(nanoTez: nanoTez)
  }

  /// Convert the given amount of NanoTez to a Tez object.
  private func nanoTezToTez(nanoTez: NanoTez) -> Tez {
    let mutez = nanoTez % FeeEstimator.kNanoTezPerMutez == 0 ?
      nanoTez / FeeEstimator.kNanoTezPerMutez :
      (nanoTez / FeeEstimator.kNanoTezPerMutez) + 1
    return Tez(mutez: mutez)
  }
}
