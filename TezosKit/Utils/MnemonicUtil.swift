// Copyright Keefer Taylor, 2018

import MnemonicKit

/// A static utility wrapper which provides a facade for a mnemonic library.
public enum MnemonicUtil {
  /// Generate a mnemonic.
  public static func generateMnemonic() -> String? {
    return Mnemonic.generateMnemonic(strength: 128)
  }

  /// Generate a seed string from a given mnemonic.
  ///
  /// - Parameters:
  ///   - mnemonic: A BIP39 mnemonic phrase.
  ///   - passphrase: An optional passphrase used for encryption.
  public static func seedString(from mnemonic: String, passphrase: String = "") -> String? {
    guard let rawSeedString =
      Mnemonic.deterministicSeedString(from: mnemonic, passphrase: passphrase) else {
      return nil
    }
    return String(rawSeedString[..<rawSeedString.index(rawSeedString.startIndex, offsetBy: 64)])
  }

  /// Validate if the given mnemonic is a valid mnemonic.
  ///
  /// - Parameters:
  ///   - mnemonic: The mnemonic to validate.
  /// - Returns: true if the mnemonic was valid, otherwise false.
  public static func validate(mnemonic: String) -> Bool {
    return Mnemonic.validate(mnemonic: mnemonic)
  }
}
