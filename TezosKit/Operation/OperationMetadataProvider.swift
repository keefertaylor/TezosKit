// Copyright Keefer Taylor, 2019.

import Foundation

public class OperationMetadataProvider {
  /// Network client to communicate with the node.
  private let networkClient: NetworkClient

  public init(networkClient: NetworkClient) {
    self.networkClient = networkClient
  }

  /// Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
  ///
  /// This method parallelizes fetches to get chain and address data and returns all required data together as an
  /// OperationData object.
  public func metadata(
    for address: String,
    completion: @escaping (Result<OperationMetadata, TezosKitError>) -> Void
  ) {
    // Dispatch group acts as a barrier for all metadata fetches.
    let metadataFetchGroup = DispatchGroup()

    /// TODO: Better threading - use a specialized thread.
    DispatchQueue.global(qos: .userInitiated).async {
      metadataFetchGroup.enter()
      var addressKey: String?
      self.managerKey(for: address) { fetchedAddressKey in
        addressKey = fetchedAddressKey
      }

      metadataFetchGroup.enter()
      var operationCounter: Int?
      self.operationCounter(for: address) { fetchedCounter in
        operationCounter = fetchedCounter
      }

      metadataFetchGroup.enter()
      var chainID: String?
      var headHash: String?
      var protocolHash: String?
      self.chainInfo(for: address) { addressInfo in
        chainID = addressInfo?.chainID
        headHash = addressInfo?.headHash
        protocolHash = addressInfo?.protocolHash
      }

      metadataFetchGroup.wait()

      // Return fetched data as an OperationData if all data was successfully retrieved.
      if let operationCounter = operationCounter,
        let headHash = headHash,
        let chainID = chainID,
        let protocolHash = protocolHash {
        let metadata = OperationMetadata(
          chainID: chainID,
          branch: headHash,
          protocol: protocolHash,
          addressCounter: operationCounter,
          key: addressKey
        )
        completion(.success(metadata))
        return
      }
      completion(.failure(TezosKitError(kind: .unknown, underlyingError: "Couldn't fetch metadata")))
    }
  }

  /// Retrieve chain info counter for the given address.
  ///
  /// - Warning: This method is not thread safe.
  /// TODO: Can we just use constants here?
  /// TODO: Can we be more scucinct with specific RPCs.
  private func chainInfo(
    for address: String,
    completion: @escaping (((chainID: String, headHash: String, protocolHash: String))?) -> Void
  ) {
    let chainHeadRequestRPC = GetChainHeadRPC()
    networkClient.send(chainHeadRequestRPC) { result in
      switch result {
      case .failure:
        break
      case .success(let json):
        guard
          let chainID = json["chain_id"] as? String,
          let headHash = json["hash"] as? String,
          let protocolHash = json["protocol"] as? String
        else {
          break
        }
        completion((chainID: chainID, headHash: headHash, protocolHash: protocolHash))
        return
      }
      completion(nil)
    }
  }


  /// Retrieve the address counter for the given address.
  ///
  /// - Warning: This method is not thread safe.
  private func operationCounter(for address: String, completion: @escaping (Int?) -> Void) {
    let getAddressCounterRPC = GetAddressCounterRPC(address: address)
    self.networkClient.send(getAddressCounterRPC) { result in
      switch result {
        case .failure:
          completion(nil)
        case .success(let fetchedOperationCounter):
          completion(fetchedOperationCounter)
      }
    }
  }

  /// Retrieve the publicKey for the given address.
  ///
  /// - Warning: This method is not thread safe.
  /// TODO: This can be factored out, entirely.
  private func managerKey(for address: String, completion: @escaping (String?) -> Void) {
    let getAddressManagerKeyRPC = GetAddressManagerKeyRPC(address: address)
    networkClient.send(getAddressManagerKeyRPC) { result in
      switch result {
      case .failure:
        break
      case .success(let fetchedManagerAndKey):
        // TODO: Use enum constants
        guard let fetchedKey = fetchedManagerAndKey["key"] as? String else {
          break
        }
        completion(fetchedKey)
        return
      }
      completion(nil)
    }
  }
}
