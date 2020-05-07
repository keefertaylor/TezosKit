//
//  OperationResponse.swift
//  SecureEnclaveExample
//
//  Created by Simon Mcloughlin on 17/03/2020.
//

import Foundation

/// Codable version of the response object that is returned by the Tezos RPC
struct OperationResponse: Codable {
  let contents: [OperationResponseContent]

  /// Check if the operation(s) has been backtracked or reversed due to a failure
  func isBacktracked() -> Bool {
    for content in contents {
      if content.metadata.operationResult.status == "backtracked" {
        return true
      }
    }

    return false
  }

  /// Return the last error object from each internal result. The last error object is the one that contains the location of the error in the smart contract and the `with` string, giving the most debugable information
  func errors() -> [OperationResponseInternalResultError] {
    var errors: [OperationResponseInternalResultError] = []

    for content in contents {
      for internalResult in content.metadata.internalOperationResults {
        if let error = internalResult.result.errors?.last {
          errors.append(error)
        }
      }
    }

    return errors
  }
}

struct OperationResponseContent: Codable {
  let kind: String
  let source: String
  let metadata: OperationResponseMetadata
}

struct OperationResponseMetadata: Codable {
  let operationResult: OperationResponseResult
  let internalOperationResults: [OperationResponseInternalOperation]

  private enum CodingKeys: String, CodingKey {
    case operationResult = "operation_result"
    case internalOperationResults = "internal_operation_results"
  }
}

struct OperationResponseResult: Codable {
  let status: String
  let consumedGas: String
  let storageSize: String

  private enum CodingKeys: String, CodingKey {
    case status
    case consumedGas = "consumed_gas"
    case storageSize = "storage_size"
  }
}

struct OperationResponseInternalOperation: Codable {
  let kind: String
  let source: String
  let result: OperationResponseInternalResult
}

struct OperationResponseInternalResult: Codable {
  let status: String
  let errors: [OperationResponseInternalResultError]?

  func isFailed() -> Bool {
    return status == "failed"
  }
}

public struct OperationResponseInternalResultError: Codable {
  public let kind: String
  public let id: String
  public let location: Int?
  public let with: OperationResponseInternalResultErrorWith?
}

public struct OperationResponseInternalResultErrorWith: Codable {
  public let string: String
}
