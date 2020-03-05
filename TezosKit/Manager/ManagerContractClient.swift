// Copyright Keefer Taylor, 2020

/// A wrapper for a manager.tz contract.
/// - SeeAlso: https://tezos.gitlab.io/protocols/005_babylon.html#migration-from-scriptless-kt1s-to-manager-tz
public class ManagerContractClient {
  private enum Entrypoint {
    public static let `do` = "do"
  }

  private let contractAddress: Address
  private let tezosNodeClient: TezosNodeClient

  /// Initialize a new manager contract client.
  ///
  /// - Parameters
  ///   - contractAddress: The address of the manager.tz contract.
  ///   - tezosNodeClient The client who will make requests.
  public init(contractAddress: Address, tezosNodeClient: TezosNodeClient) {
    self.contractAddress = contractAddress
    self.tezosNodeClient = tezosNodeClient
  }

  /// Delegate the balance of a manager.tz contract.
  ///
  /// - Parameters:
  ///   - delegate: The new delegate of the contract.
  ///   - signatureProvider: An opaque object that will sign the transaction.
  ///   - completion: A completion block which is called with the result of the operation.
  public func delegate(
    to delegate: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let parameter = AbstractMichelsonParameter(networkRepresentation:
      [ [ "prim": "DROP" ],
        [ "prim": "NIL", "args": [ [ "prim": "operation" ] ] ],
        [ "prim": "PUSH",
          "args":
            [ [ "prim": "key_hash" ],
              [ "string": delegate ] ] ],
        [ "prim": "SOME" ], [ "prim": "SET_DELEGATE" ],
        [ "prim": "CONS" ] ]
    )

    self.tezosNodeClient.call(
      contract: self.contractAddress,
      amount: Tez.zero,
      entrypoint: Entrypoint.do,
      parameter: parameter,
      source: signatureProvider.publicKey.publicKeyHash,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  /// Unelegate the balance of a manager.tz contract.
  ///
  /// - Parameters:
  ///   - signatureProvider: An opaque object that will sign the transaction.
  ///   - completion: A completion block which is called with the result of the operation.
  public func undelegate(
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let parameter = AbstractMichelsonParameter(networkRepresentation:
      [
        [ "prim": "DROP" ],
        [
          "prim": "NIL", "args": [
            [ "prim": "operation" ]
          ]
        ],
        [
          "prim": "NONE", "args": [
            [ "prim": "key_hash" ]
          ]
        ],
        [ "prim": "SET_DELEGATE" ],
        [ "prim": "CONS" ]
      ]
    )

    self.tezosNodeClient.call(
      contract: self.contractAddress,
      amount: Tez.zero,
      entrypoint: Entrypoint.do,
      parameter: parameter,
      source: signatureProvider.publicKey.publicKeyHash,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  /// Transfer Tez from a manager.tz contract.
  ///
  /// - Parameters:
  ///   - destination: The destination for the transfer.
  ///   - amount: The amount of Tez to transfer.
  ///   - signatureProvider: An opaque object that will sign the transaction.
  ///   - completion: A completion block which is called with the result of the operation.
  public func transfer(
    to destination: Address,
    amount: Tez,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let parameter = AbstractMichelsonParameter(networkRepresentation:
      [ [ "prim": "DROP" ],
        [ "prim": "NIL", "args": [ [ "prim": "operation" ] ] ],
        [ "prim": "PUSH",
          "args":
            [ [ "prim": "key_hash" ],
              [ "string": destination ] ] ],
        [ "prim": "IMPLICIT_ACCOUNT" ],
        [ "prim": "PUSH",
          "args": [ [ "prim": "mutez" ], [ "int": amount.rpcRepresentation ] ] ],
        [ "prim": "UNIT" ], [ "prim": "TRANSFER_TOKENS" ],
        [ "prim": "CONS" ] ]
    )

    self.tezosNodeClient.call(
      contract: self.contractAddress,
      amount: Tez.zero,
      entrypoint: Entrypoint.do,
      parameter: parameter,
      source: signatureProvider.publicKey.publicKeyHash,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }
}
