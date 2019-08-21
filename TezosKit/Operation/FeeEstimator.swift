// Copyright Keefer Taylor, 2019.

import Foundation

private typealias NanoTez = Int

public class FeeEstimator {
  private static let kNanoTezPerTez = 10

  private enum FeeConstants {
    public static let minimalFee: NanoTez = 1_000
    public static let feePerGasUnit: NanoTez = 1
    public static let feePerStorageByte: NanoTez = 10
  }

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
    feeEstimatorQueue.async {
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

      // Start with a minimum fee equal to the minimum fee or the fee required by the gas.
      let gasFee = self.feeForGas(consumedGas: consumedGas)
      let minimumFee = self.nanoTezToTez(nanoTez: FeeConstants.minimalFee)
      let initialFee = gasFee > minimumFee ? gasFee : minimumFee

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
        gasLimit: consumedGas,
        storageLimit: consumedStorage
      )

      // Loop until the storage fee for the operation is above the required storage fee.
      while mutableOperation.operationFees.fee - gasFee < requiredStorageFee {
        // Calculate the needed delta on the storage fee and change it out on the operation.
        let feeDifference = mutableOperation.operationFees.fee - gasFee
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

      completion(mutableOperation.operationFees)
    }
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
    let simulationGroup = DispatchGroup()

    var simulationOutput: SimulationResult?

    simulationGroup.enter()
    self.simulationService.simulate(operation, from: address, signatureProvider: signatureProvider) { result in
      if case let .success(simulationResult) = result {
        simulationOutput = simulationResult
      }
      simulationGroup.leave()
    }

    simulationGroup.wait()

    return simulationOutput
  }

  private func forgeSync(address: Address, operation: Operation, signatureProvider: SignatureProvider) -> Hex? {
    guard let operationMetadata = operationMetadataSync(address: address) else {
      return nil
    }

    let forgeGroup = DispatchGroup()

    var hex: Hex?

    let operationWithCounter = OperationWithCounter(operation: operation, counter: operationMetadata.addressCounter)
    let operationPayload = OperationPayload(operations: [ operationWithCounter ], operationMetadata: operationMetadata)

    forgeGroup.enter()
    self.forgingService.forge(
      operationPayload: operationPayload,
      operationMetadata: operationMetadata
    ) { result in
      if case let .success(forgedHex) = result {
        hex = forgedHex
      }
      forgeGroup.leave()
    }

    forgeGroup.wait()
    return hex
  }

  private func operationMetadataSync(address: Address) -> OperationMetadata? {
    let operationMetadataGroup = DispatchGroup()

    operationMetadataGroup.enter()
    var operationMetadata: OperationMetadata?
    operationMetadataProvider.metadata(for: address) { result in
      if case let .success(fetchedOperationMetadata) = result {
        operationMetadata = fetchedOperationMetadata
      }
      operationMetadataGroup.leave()
    }

    operationMetadataGroup.wait()
    return operationMetadata
  }

  private func feeForGas(consumedGas: Int) -> Tez {
    let nanoTez = consumedGas * FeeConstants.feePerGasUnit
    return nanoTezToTez(nanoTez: nanoTez)
  }

  /// Assume we're dealing with UTF-8
  private func feeFromSerializedString(string: Hex) -> Tez {
    let nanoTez = string.count * FeeConstants.feePerStorageByte
    return nanoTezToTez(nanoTez: nanoTez)
  }

  /// NanoTez to Tez
  private func nanoTezToTez(nanoTez: NanoTez) -> Tez {
    let mutez = nanoTez % FeeEstimator.kNanoTezPerTez == 0 ?
      FeeEstimator.kNanoTezPerTez % 10 :
      (FeeEstimator.kNanoTezPerTez % 10) + 1
    return Tez(mutez: mutez)
  }
}

extension Tez {
  public init(mutez: Int) {
    self.init(String(mutez))!
  }
}
