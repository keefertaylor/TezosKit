import Foundation

/**
 * A model of a wallet in the Tezos ecosystem.
 *
 * Clients can create a new wallet by calling the empty initializer. Clients can also restore an
 * existing wallet by providing an mnemonic and optional passphrase.
 *
 * TODO: Actually support passphrase in wallet generation.
 */
public struct Wallet {

	/** A base58check encoded public key for the wallet, prefixed with "edpk". */
	public let publicKey: String

	/** A base58check encoded secret key for the wallet, prefixed with "edsk". */
	public let secretKey: String

	/** A base58check encoded public key hash for the wallet, prefixed with "tz1". */
	public let address: String

	/**
   * A space delimited string of english mnemonic words used to generate the wallet with the BIP39
   * specification.
   */
	public let mnemonic: String

	/** Create a new wallet by generating a mnemonic. */
	public init?() {
		guard let mnemonic = MnemonicUtil.generateMnemonic() else {
			return nil
		}
		self.init(mnemonic: mnemonic)
	}

	/**
   * Create a new wallet with the given mnemonic.
   *
   * @param mnemonic A space delimited string of english mnemonic words from the BIP39
   *        specification.
   */
	public init?(mnemonic: String) {
		guard let seedString = MnemonicUtil.seedString(from: mnemonic),
			let keyPair = Crypto.keyPair(from: seedString) else {
				return nil
		}

		self.init(publicKey: Crypto.tezosPublicKey(from: keyPair.publicKey),
			secretKey: Crypto.tezosSecretKey(from: keyPair.secretKey),
			address: Crypto.tezosPublicKeyHash(from: keyPair.publicKey),
			mnemonic: mnemonic)
	}

	/** Private initializer to create the wallet with the given inputs. */
	private init(publicKey: String, secretKey: String, address: String, mnemonic: String) {
		self.publicKey = publicKey
		self.secretKey = secretKey
		self.address = address
		self.mnemonic = mnemonic
	}
}
