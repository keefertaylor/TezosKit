// Copyright Keefer Taylor, 2019.

import Foundation

/// JSON keys and values used in the PreapplicationService.
private enum JSON {
  public enum Keys {
    public static let consumedGas = "consumed_gas"
    public static let contents = "contents"
    public static let metadata = "metadata"
    public static let operationResult = "operation_result"
    public static let status = "status"
    public static let storageSize = "storage_size"
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
      let contents = json[JSON.Keys.contents] as? [[ String: Any ]],
      contents.count == 1,
      let firstContent = contents.first,
      let metadata = firstContent[JSON.Keys.metadata] as? [String: Any],
      let operationResult = metadata[JSON.Keys.operationResult] as? [String: Any],
      let status = operationResult[JSON.Keys.status] as? String
      else {
        return nil
    }

    if status == JSON.Values.failed {
      return .failure
    }

    let rawConsumedGas = operationResult[JSON.Keys.consumedGas] as? String ?? "0"
    let consumedGas = Int(rawConsumedGas) ?? 0

    let rawConsumedStorage = operationResult[JSON.Keys.storageSize] as? String ?? "0"
    let consumedStorage = Int(rawConsumedStorage) ?? 0

    return .success(consumedGas: consumedGas, consumedStorage: consumedStorage)
  }
}
