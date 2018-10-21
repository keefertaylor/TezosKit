import Foundation

/** Keypair struct for tests. */
public struct TestKeyPair: KeyPair {
	public let publicKey: [UInt8]
	public let secretKey: [UInt8]
}
