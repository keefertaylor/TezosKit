// Copyright Keefer Taylor, 2019.

import Foundation

private typealias NanoTez = Int

public class FeeEstimator {
  private static let kNanoTezPerMutez = 1_000
  private static let kMaxGasPerOperation = 800_000
  private static let kMaxStoragePerOepration = 60_000

  private enum FeeConstants {
    public static let minimalFee: NanoTez = 100_000
    public static let feePerGasUnit: NanoTez = 100
    public static let feePerStorageByte: NanoTez = 1_000
  }

  public static let kSafetyMarginGas = 100
  public static let kSafetyMarginStorage = 257
  public static let kSafetyMarginFee = Tez(0.000_100)

  let forgingService: ForgingService
  let operationMetadataProvider: OperationMetadataProvider
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

  public func estimate(
    operation: Operation,
    address: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (OperationFees?) -> Void
  ) {
//    feeEstimatorQueue.async {
      // swiftlint:disable force_cast
      let mutableOperation = operation.mutableCopy() as! Operation
      // swiftlint:enable force_cast

      // Simulate the operation to determine gas and storage limits.
      guard
        let simulationResult = self.simulateOperationSync(
          operation: mutableOperation,
          address: address,
          signatureProvider: signatureProvider
        ),
        case let .success(consumedGas, consumedStorage) = simulationResult
      else {
        completion(nil)
        return
      }
      // add safety margins
      let gasLimit = consumedGas + FeeEstimator.kSafetyMarginGas
      let storageLimit = consumedStorage + FeeEstimator.kSafetyMarginStorage

      // Start with a minimum fee equal to the minimum fee or the fee required by the gas.
      let gasFee = self.feeForGas(gas: gasLimit)
      let minimumFee = self.nanoTezToTez(nanoTez: FeeConstants.minimalFee)
      let initialFee = minimumFee + gasFee

      // Calculate the amount of fees required for the operation size.
      guard var requiredStorageFee = self.feeForOperation(
        address: address,
        operation: mutableOperation,
        signatureProvider: signatureProvider
      ) else {
        completion(nil)
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
        guard let newStorageFee = self.feeForOperation(
          address: address,
          operation: mutableOperation,
          signatureProvider: signatureProvider
        ) else {
          completion(nil)
          return
        }
        requiredStorageFee = newStorageFee
      }

      print("EST FEES \(mutableOperation.operationFees.fee)")
      print("EST  GAS \(mutableOperation.operationFees.gasLimit)")
      print("EST STOR \(mutableOperation.operationFees.storageLimit)")

      completion(mutableOperation.operationFees)
//    }
  }

  // MARK: - Helpers

  private func feeForOperation(
    address: Address,
    operation: Operation,
    signatureProvider: SignatureProvider
  ) -> Tez? {
    guard let hex = self.forgeSync(address: address, operation: operation, signatureProvider: signatureProvider) else {
      return nil
    }
    return feeFromSerializedString(string: hex)
  }

  private func simulateOperationSync(
    operation: Operation,
    address: Address,
    signatureProvider: SignatureProvider
  ) -> SimulationResult? {
    // There must be a better RPC.
    let maxedFees = OperationFees(
      fee: Tez.zeroBalance,
      gasLimit: FeeEstimator.kMaxGasPerOperation,
      storageLimit: FeeEstimator.kMaxStoragePerOepration
    )
    // swiftlint:disable force_cast
    let maxedOperation = operation.mutableCopy() as! Operation
    maxedOperation.operationFees = maxedFees

    let result = simulationService.simulateSync(
      maxedOperation,
      from: address,
      signatureProvider: signatureProvider
    )
    if case let .success(simulationResult) = result {
      return simulationResult
    }
    return nil
  }

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

  private func operationMetadataSync(address: Address) -> OperationMetadata? {
    let result = operationMetadataProvider.metadataSync(for: address)
    if case let .success(metadata) = result {
      return metadata
    }
    return nil
  }

  private func feeForGas(gas: Int) -> Tez {
    let nanoTez = gas * FeeConstants.feePerGasUnit
    return nanoTezToTez(nanoTez: nanoTez)
  }

  /// Assume we're dealing with UTF-8
  private func feeFromSerializedString(string: Hex) -> Tez {
    let nanoTez = string.count * FeeConstants.feePerStorageByte
    return nanoTezToTez(nanoTez: nanoTez) + FeeEstimator.kSafetyMarginFee
  }

  /// NanoTez to Tez
  private func nanoTezToTez(nanoTez: NanoTez) -> Tez {
    let mutez = nanoTez % FeeEstimator.kNanoTezPerMutez == 0 ?
      nanoTez / FeeEstimator.kNanoTezPerMutez :
      (nanoTez / FeeEstimator.kNanoTezPerMutez) + 1
    return Tez(mutez: mutez)
  }
}

extension Tez {
  public init(mutez: Int) {
    self.init(String(mutez))!
  }
}
