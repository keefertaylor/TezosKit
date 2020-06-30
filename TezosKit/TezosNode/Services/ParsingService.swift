//
//  ParsingService.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 30/06/2020.
//

import Foundation

/// A service which manages parsing and comparsion of remote forge hash's.
public class ParsingService {

  /// A network client that can send requests.
  private let networkClient: NetworkClient

  /// Identifier for the internal dispatch queue.
  private static let queueIdentifier = "com.keefertaylor.TezosKit.ParsingService"

  /// Internal Queue to use in order to perform asynchronous work.
  private let parsingServiceQueue: DispatchQueue

  /// - Parameters:
  ///   - forgingPolicy: The forging policy to apply to all operations.
  ///   - networkClient: A network client that can communicate with a Tezos Node.
  public init(networkClient: NetworkClient) {
    self.networkClient = networkClient
    parsingServiceQueue = DispatchQueue(label: ParsingService.queueIdentifier)
  }

  public func parse(hashToParse: String, operationsToMatch: [Operation], operationMetadata: OperationMetadata, completion: @escaping ((Result<Bool, TezosKitError> ) -> Void)) {

    let rpc = ParseOperationRPC(hashToParse: hashToParse, operationMetadata: operationMetadata)
    networkClient.send(rpc) { [weak self] (result) in

      switch result {
        case .success(let jsonArray):
          if let comparisonResult = self?.compare(jsonArray: jsonArray, toOperations: operationsToMatch), comparisonResult {
            completion(Result.success(true))

          } else {
            completion(Result.failure(TezosKitError.transactionFormationFailure(underlyingError: TezosKitError.unexpectedResponse(description: "Unable to parse response"))))
          }

        case .failure(let error):
          completion(Result.failure(error))
      }
    }
  }

  private func compare(jsonArray: [[String: Any]], toOperations operations: [Operation]) -> Bool {
    guard let contents = jsonArray.first?["contents"] as? [[String: Any]] else {
      return false
    }

    if contents.count != operations.count {
      return false
    }

    var validMatches = 0

    // cycle through each json object returned, and compare to the dictionary representation of the operations
    outerloop: for dict in contents {
      for op in operations {
        
        // Operation objects won't have a counter, so remove it from the network JSON before comparing
        var sanitizedDict = dict
        sanitizedDict.removeValue(forKey: "counter")
        
        if (sanitizedDict as NSDictionary).isEqual(op.dictionaryRepresentation) {
          validMatches += 1
          continue outerloop
        }
      }
    }

    return validMatches == operations.count
  }
}
