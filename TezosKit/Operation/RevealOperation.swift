// Copyright Keefer Taylor, 2018

import Foundation
import TezosCrypto

/// An operation to reveal an address.
///
/// - Note: TezosKit will automatically inject this operation when required for supported operations.
public class RevealOperation: AbstractOperation {
  /// The public key for the address being revealed.
  private let publicKey: String

  public override var dictionaryRepresentation: [String: Any] {
    var operation = super.dictionaryRepresentation
    operation["public_key"] = publicKey
    return operation
  }

  /// Initialize a new reveal operation.
  ///
  /// - Parameters:
  ///   - address: The address to reveal.
  ///   - publicKey: The public key of the address to reveal.
  ///   - operationFees: OperationFees for the transaction.
  public init(from address: Address, publicKey: PublicKey, operationFees: OperationFees) {
    self.publicKey = publicKey.base58CheckRepresentation
    super.init(source: address, kind: .reveal, operationFees: operationFees)
  }
}
