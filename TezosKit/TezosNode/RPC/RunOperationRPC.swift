// Copyright Keefer Taylor, 2019.

import Foundation

/// An RPC that will run an operation.
public class RunOperationRPC: RPC<SimulationResult> {
  /// - Parameter runOperationPayload: A payload containing an operation to run.
  public init(runOperationPayload: RunOperationPayload) {
    let endpoint = "/chains/main/blocks/head/helpers/scripts/run_operation"
    let jsonPayload = JSONUtils.jsonString(for: runOperationPayload.dictionaryRepresentation)
    super.init(
      endpoint: endpoint,
      headers: [Header.contentTypeApplicationJSON],
      responseAdapterClass: SimulationResultResponseAdapter.self,
      payload: jsonPayload
    )
  }
}
