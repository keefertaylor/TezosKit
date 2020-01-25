// Copyright Keefer Taylor, 2019.

import Foundation

public class OperationMetadataProvider {
  /// JSON keys and values used in fetching metadata.
  internal enum JSON {
    public enum Keys {
      public static let chainID = "chain_id"
      public static let hash = "hash"
      public static let `protocol` = "protocol"
    }
  }

  /// Identifier for the internal dispatch queue.
  private static let queueIdentifier = "com.keefertaylor.TezosKit.OperationMetadataProvider"

  /// Network client to communicate with the node.
  private let networkClient: NetworkClient

  /// Internal Queue to use in order to perform asynchronous work.
  private let metadataProviderQueue: DispatchQueue

  public init(networkClient: NetworkClient) {
    self.networkClient = networkClient
    metadataProviderQueue = DispatchQueue(label: OperationMetadataProvider.queueIdentifier)
  }

  /// Retrieve metadata needed to forge / pre-apply / sign / inject an operation in a synchronous manner.
  ///
  /// - Note: This method blocks the calling thread.
  ///
  /// This method parallelizes fetches to get chain and address data and returns all required data together as an
  /// OperationData object.
  public func metadataSync(
    for address: Address
    ) -> Result<OperationMetadata, TezosKitError> {
    let metadataGroup = DispatchGroup()

    var result: Result<OperationMetadata, TezosKitError> = .failure(TezosKitError(kind: .unknown))
    metadataGroup.enter()
    metadata(for: address) { metadatResult in
      result = metadatResult
      metadataGroup.leave()
    }

    metadataGroup.wait()
    return result
  }

  /// Retrieve metadata needed to forge / pre-apply / sign / inject an operation.
  ///
  /// This method parallelizes fetches to get chain and address data and returns all required data together as an
  /// OperationData object.
  public func metadata(
    for address: Address,
    completion: @escaping (Result<OperationMetadata, TezosKitError>) -> Void
    ) {
    // Dispatch group acts as a barrier for all metadata fetches.
    let metadataFetchGroup = DispatchGroup()

    metadataFetchGroup.enter()
    metadataFetchGroup.enter()
    metadataFetchGroup.enter()

    var addressKey: String?
    metadataProviderQueue.async {
      self.managerKey(for: address) { fetchedAddressKey in
        addressKey = fetchedAddressKey
        metadataFetchGroup.leave()
      }
    }

    var operationCounter: Int?
    metadataProviderQueue.async {
      self.operationCounter(for: address) { fetchedCounter in
        operationCounter = fetchedCounter
        metadataFetchGroup.leave()
      }
    }

    var headHash: String?
    var protocolHash: String?
    var chainID: String?
    metadataProviderQueue.async {
      self.chainInfo(for: address) { addressInfo in
        headHash = addressInfo?.headHash
        protocolHash = addressInfo?.protocol
        chainID = addressInfo?.chainID
        metadataFetchGroup.leave()
      }
    }

    // Wait for all required data to be fetched.
    metadataFetchGroup.wait()

    // Return fetched data as an OperationData if all data was successfully retrieved.
    if let operationCounter = operationCounter,
      let headHash = headHash,
      let protocolHash = protocolHash,
      let chainID = chainID {
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

  /// Retrieve chain info counter for the given address.
  ///
  /// - Warning: This method is not thread safe.
  private func chainInfo(
    for address: Address,
    completion: @escaping (((headHash: String, protocol: String, chainID: String))?) -> Void
    ) {
    let chainHeadRequestRPC = GetChainHeadRPC()
    networkClient.send(chainHeadRequestRPC, callbackQueue: metadataProviderQueue) { result in
      switch result {
      case .failure:
        break
      case .success(let json):
        guard
          let headHash = json[OperationMetadataProvider.JSON.Keys.hash] as? String,
          let `protocol` = json[OperationMetadataProvider.JSON.Keys.protocol] as? String,
          let chainID = json[OperationMetadataProvider.JSON.Keys.chainID] as? String
        else {
            break
        }
        completion((headHash: headHash, protocol: `protocol`, chainID: chainID))
        return
      }
      completion(nil)
    }
  }

  /// Retrieve the address counter for the given address.
  ///
  /// - Warning: This method is not thread safe.
  private func operationCounter(for address: Address, completion: @escaping (Int?) -> Void) {
    let getAddressCounterRPC = GetAddressCounterRPC(address: address)
    self.networkClient.send(getAddressCounterRPC, callbackQueue: metadataProviderQueue) { result in
      switch result {
      case .failure:
        completion(nil)
      case .success(let fetchedOperationCounter):
        completion(fetchedOperationCounter)
      }
    }
  }

  /// Retrieve the base58check encoded public key for the given address.
  ///
  /// - Warning: This method is not thread safe.
  private func managerKey(for address: Address, completion: @escaping (String?) -> Void) {
    let getAddressManagerKeyRPC = GetAddressManagerKeyRPC(address: address)
    networkClient.send(getAddressManagerKeyRPC, callbackQueue: metadataProviderQueue) { result in
      switch result {
      case .failure:
        break
      case .success(let fetchedKey):
        completion(fetchedKey)
        return
      }
      completion(nil)
    }
  }
}
