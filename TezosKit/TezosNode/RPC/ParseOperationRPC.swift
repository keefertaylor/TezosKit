//
//  ParseOperationRPC.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 30/06/2020.
//

import Foundation

/// An RPC which will parse an operation.
public class ParseOperationRPC: RPC<[[String: Any]]> {

  /// - Parameters:
  ///   - operationPayload: A payload to forge.
  ///   - operationMetadata: Metadata about the operation.
  public init(hashToParse: String, operationMetadata: OperationMetadata) {
    let endpoint = "/chains/main/blocks/" + operationMetadata.branch + "/helpers/parse/operations"
    let jsonDictionary = ["operations": [ ["data": hashToParse, "branch": operationMetadata.branch] ]]
    let payload = JSONUtils.jsonString(for: jsonDictionary)

    super.init(endpoint: endpoint, headers: [Header.contentTypeApplicationJSON], responseAdapterClass: JSONArrayResponseAdapter.self, payload: payload)
  }
}
