import Foundation

/** An operation that originates a new KT1 account. */
public class OriginateAccountOperation: AbstractOperation {
  let managerPublicKeyHash: String

  public override var dictionaryRepresentation: [String: String] {
    var operation = super.dictionaryRepresentation
    operation["balance"] = "0"
    operation["managerPubkey"] = self.managerPublicKeyHash

    return operation
  }

  /** Create a new origination operation that will occur from the given wallet's address. */
  public convenience init(wallet: Wallet) {
    self.init(address: wallet.address)
  }

  /** Create a new origination operation that will occur from the given address. */
  public init(address: String) {
    self.managerPublicKeyHash = address
    super.init(source: address, kind: .origination)
  }
}
