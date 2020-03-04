// Copyright Keefer Taylor, 2020

/// A wrapper for a manager.tz contract.
/// - SeeAlso: https://tezos.gitlab.io/protocols/005_babylon.html#migration-from-scriptless-kt1s-to-manager-tz
public class ManagerClient {
  private enum Entrypoint {
    public static let `do` = "do"
  }

  private let contractAddress: Address
  private let tezosNodeClient: TezosNodeClient

  /// Initialize a new manager client.
  ///
  /// - Parameters
  ///   - contractAddress: The address of the manager.tz contract.
  ///   - tezosNodeClient The client who will make requests.
  public init(contractAddress: Address, tezosNodeClient: TezosNodeClient) {
    self.contractAddress = contractAddress
    self.tezosNodeClient = tezosNodeClient
  }

  /// Delegate the balance of a manager.tz contract.
  public func delegate(
    to destination: Address,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let parameter = AbstractMichelsonParameter(networkRepresentation:
      [ [ "prim": "DROP" ],
             [ "prim": "NIL", "args": [ [ "prim": "operation" ] ] ],
             [ "prim": "PUSH",
               "args":
                 [ [ "prim": "key_hash" ],
                   [ "string": "tz1YH2LE6p7Sj16vF6irfHX92QV45XAZYHnX" ] ] ],
             [ "prim": "SOME" ], [ "prim": "SET_DELEGATE" ],
             [ "prim": "CONS" ] ]
    )

    self.tezosNodeClient.call(
      contract: self.contractAddress,
      amount: Tez.zero,
      entrypoint: Entrypoint.do,
      parameter: parameter,
      source: signatureProvider.address,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }
//
//
//  /// Undelegate
//
//  [ { "contents":
//         [ { "kind": "transaction",
//             "source": "tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW", "fee": "2857",
//             "counter": "2357", "gas_limit": "25822", "storage_limit": "0",
//             "amount": "0",
//             "destination": "KT1VPVdNiWskBEVHF3pWdxyxepj4ZaWTGKgz",
//             "parameters":
//               { "entrypoint": "do",
//                 "value":
//                   [ { "prim": "DROP" },
//                     { "prim": "NIL", "args": [ { "prim": "operation" } ] },
//                     { "prim": "NONE", "args": [ { "prim": "key_hash" } ] },
//                     { "prim": "SET_DELEGATE" }, { "prim": "CONS" } ] },
//             "metadata":
//               { "balance_updates":
//                   [ { "kind": "contract",
//                       "contract": "tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW",
//                       "change": "-2857" },
//                     { "kind": "freezer", "category": "fees",
//                       "delegate": "tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU",
//                       "cycle": 164, "change": "2857" } ],
//                 "operation_result":
//                   { "status": "applied",
//                     "storage":
//                       { "bytes": "0081faa75f741ef614b0e35fcc8c90dfa3b0b95721" },
//                     "consumed_gas": "15722", "storage_size": "232" },
//                 "internal_operation_results":
//                   [ { "kind": "delegation",
//                       "source": "KT1VPVdNiWskBEVHF3pWdxyxepj4ZaWTGKgz",
//                       "nonce": 0,
//                       "result":
//                         { "status": "applied", "consumed_gas": "10000" } } ] } } ],
//
//  /// Transfer to implicit
//  "parameters":
//  { "entrypoint": "do",
//    "value":
//      [ { "prim": "DROP" },
//        { "prim": "NIL", "args": [ { "prim": "operation" } ] },
//        { "prim": "PUSH",
//          "args":
//            [ { "prim": "key_hash" },
//              { "string": "tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3" } ] },
//        { "prim": "IMPLICIT_ACCOUNT" },
//        { "prim": "PUSH",
//          "args": [ { "prim": "mutez" }, { "int": "10" } ] },
//        { "prim": "UNIT" }, { "prim": "TRANSFER_TOKENS" },
//        { "prim": "CONS" } ] },


}
