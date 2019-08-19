// Copyright Keefer Taylor, 2019.

import Foundation

public class FeeEstimator {
  private enum FeeConstants {
    public static let minimalFee = 0.000_1
    public static let feePerGasUnit = 0.000_000_1
    public static let feePerStorageByte = 0.000_001
  }

  let forgingService: ForgingService
  let operationMetadataProvider: OperationMetadataProvider
  let simulationService: SimulationService

  public init(
    forgingService: ForgingService,
    operationMetadataProvider: OperationMetadataProvider,
    simulationService: SimulationService
  ) {
    self.forgingService = forgingService
    self.operationMetadataProvider = operationMetadataProvider
    self.simulationService = simulationService
  }

  public func estimateFeesForOperation(
    operation: Operation,
    from address: Address,
    signatureProvider: SignatureProvider
  ) -> OperationFees? {
    self.simulationService.simulate(operation, from: address, signatureProvider: signatureProvider) { result in
      switch result {
      case .success(let simulationResult):
        return estimateFees(with: simulationResult, for: operation)
      case .failure(let error):
        return nil
      }
    }
  }

  // MARK: - Private

  private func estimateFees(with simulationResult: SimulationResult, for operation: Operation) -> OperationFees? {
    switch simulationResult {
    case .success(let consumedStorage, let consumedGas):
      let fee =

      return nil
    case .failure:
      return nil
    }
  }

  private func setInitialFees(operation: Operation, storageLimit: Int, gasLimit: Int) {
    let operationFees = OperationFees(fee: Tez.zeroBalance, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  private func serializedStringForOperation(operation: Operation) {
    forgingService.forge(operationPayload: <#T##OperationPayload#>, operationMetadata: <#T##OperationMetadata#>, completion: <#T##(Result<String, TezosKitError>) -> Void#>)
  }

  /// Assume we're dealing with UTF-8
  private func feeFromSerializedString(string: String) -> Tez {
    return string.count * FeeConstants.minimalFee
  }
}
