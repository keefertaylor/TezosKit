// Copyright Keefer Taylor, 2018

import Foundation

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

  public override var defaultFees: OperationFees {
    let fee = Tez(0.001_269)
    let storageLimit = Tez.zeroBalance
    let gasLimit = Tez(0.010_000)
    return OperationFees(fee: fee, gasLimit: gasLimit, storageLimit: storageLimit)
  }

  /// Initialize a new reveal operation for the given wallet.
  ///
  /// - Parameters:
  ///   - wallet: The wallet that will be revealed.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public convenience init(from wallet: Wallet, operationFees: OperationFees? = nil) {
    self.init(
      from: wallet.address,
      publicKey: wallet.keys.publicKey,
      operationFees: operationFees
    )
  }

  /// Initialize a new reveal operation.
  ///
  /// - Parameters:
  ///   - address: The address to reveal.
  ///   - publicKey: The public key of the address to reveal.
  ///   - operationFees: OperationFees for the transaction. If nil, default fees are used.
  public init(from address: String, publicKey: PublicKey, operationFees: OperationFees? = nil) {
    self.publicKey = publicKey.base58CheckRepresentation
    super.init(source: address, kind: .reveal, operationFees: operationFees)
  }
}
