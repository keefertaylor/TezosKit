// Copyright Keefer Taylor, 2019

import Foundation
import Valet

/**
 * A utility class which allows storing and restoring wallet objects from the secure Keychain.
 */
public class WalletKeychainManager {
  /// Identifier for the TezosKit Valet.
  private let tezosKitValetIdentifier = "TezosKit"

  /// Identifier for a wallet in the keychain.
  private let tezosKitWalletIdentifier = "TezosKitWalletIdentifier"

  /// Valet instance which wraps a secure keystore.
  private let valet: Valet

  /** Initialize a new WalletKeychainManager. */
  public init() {
    let identifier = Identifier(nonEmpty: tezosKitValetIdentifier)!
    let mySecureEnclaveValet = SecureEnclaveValet.valet(with: identifier, accessControl: .userPresence)
  }

  /**
   * Tests if there is an existing wallet stored in the keychain.
   * - Returns: True if there is an existing wallet.
   */
  public func hasWallet() -> Bool {
  }

  /**
   * Store the given wallet in the keychain. This will overwrite any wallet in the keychain at this location.
   * - Parameter wallet: The wallet to save in the keychain.
   */
  public func storeWallet(_ wallet: Wallet) {
  }

  /**
   * Restore the given wallet in the keychain.
   */
  public func restoreWallet() -> Wallet? {
  }

  /**
   * Clear the wallet from the keychain.
   */
  public func clear() {
  }
}
