// Copyright Keefer Taylor, 2019.

import Foundation

/// JSON keys and values used in the PreapplicationService.
private enum JSON {
  public enum Keys {
    public static let consumedGas = "consumed_gas"
    public static let contents = "contents"
    public static let internalOperationResult = "internal_operation_results"
    public static let metadata = "metadata"
    public static let operationResult = "operation_result"
    public static let result = "result"
    public static let status = "status"
    public static let storageSize = "storage_size"
	public static let allocatedDestinationContract = "allocated_destination_contract"
	public static let paidStorageSizeDiff = "paid_storage_size_diff"
  }

  public enum Values {
    public static let failed = "failed"
  }
}

/// Parse the resulting JSON from a simulation operation to a SimulationResult enum
public class SimulationResultResponseAdapter: AbstractResponseAdapter<SimulationResult> {
  public override class func parse(input: Data) -> SimulationResult? {
    guard
      let json = JSONDictionaryResponseAdapter.parse(input: input)
    else {
        return nil
    }

    guard
      let contents = json[JSON.Keys.contents] as? [[ String: Any ]]
    else {
      return nil
    }

    var consumedGas = 0
    var consumedStorage = 0
	var burnFee = Tez.zeroBalance

    for content in contents {
      guard
        let metadata = content[JSON.Keys.metadata] as? [String: Any],
        let operationResult = metadata[JSON.Keys.operationResult] as? [String: Any],
        let status = operationResult[JSON.Keys.status] as? String
      else {
        continue
      }

      if status == JSON.Values.failed {
        return nil
      }

      let rawConsumedGas = operationResult[JSON.Keys.consumedGas] as? String ?? "0"
      consumedGas += Int(rawConsumedGas) ?? 0

      let rawConsumedStorage = operationResult[JSON.Keys.paidStorageSizeDiff] as? String ?? "0"
      consumedStorage += Int(rawConsumedStorage) ?? 0

      if let internalOperationResults = metadata[JSON.Keys.internalOperationResult] as? [[String: Any]] {
        for internalOperation in internalOperationResults {
          guard let intenalOperationResult = internalOperation[JSON.Keys.result] as? [String: Any] else {
            continue
          }

          let rawInternalConsumedGas = intenalOperationResult[JSON.Keys.consumedGas] as? String ?? "0"
          let internalConsumedGas = Int(rawInternalConsumedGas) ?? 0
          consumedGas += internalConsumedGas

          let rawInternalConsumedStorage = intenalOperationResult[JSON.Keys.paidStorageSizeDiff] as? String ?? "0"
          let internalConsumedStorage = Int(rawInternalConsumedStorage) ?? 0
          consumedStorage += internalConsumedStorage
        }
      }

	  // Check for burn fee(s)
	  let allocatedDestinationContract = operationResult[JSON.Keys.allocatedDestinationContract] as? Bool ?? false
	  if allocatedDestinationContract {
		burnFee += Tez(0.257) // TODO: temporary, needs to be calculated
	  }
    }

	return SimulationResult(consumedGas: consumedGas, consumedStorage: consumedStorage, burnFee: burnFee)
  }
}
