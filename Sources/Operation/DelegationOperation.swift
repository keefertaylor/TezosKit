import Foundation

/**
 * An operation to set a delegate for an address.
 *
 * @warning This class is not functional... yet. 
 */
public class DelegationOperation: AbstractOperation {
	public let delegate: String

	public override var dictionaryRepresentation: [String: String] {
		// TODO: Implement.
		return super.dictionaryRepresentation
	}

	public convenience init(from wallet: Wallet, to delegate: String) {
		self.init(source: wallet.address, to: delegate)
	}

	public init(source: String, to delegate: String) {
		self.delegate = delegate
		super.init(source: source, kind: .delegation)
	}
}
