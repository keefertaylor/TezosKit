import CKMnemonic

/**
 * A static utility wrapper class for CKMnemonic which provides syntactic sugar to transform
 * exceptions into optionals.
 */
public class MnemonicUtil {

  /**
   * Generate a mnemonic.
   */
  public static func generateMnemonic() -> String? {
    do {
      return try CKMnemonic.generateMnemonic(strength: 128, language: .english)
    } catch {
      return nil
    }
  }

  /**
   * Generate a seed string from a given mnemonic.
   */
  public static func seedString(from mnemonic: String) -> String? {
    do {
      // Generate a 64 character seed string from the mnemonic.
      let rawSeedString =
          try CKMnemonic.deterministicSeedString(from: mnemonic, passphrase: "", language: .english)
      return String(rawSeedString[..<rawSeedString.index(rawSeedString.startIndex, offsetBy: 64)])
    } catch {
      return nil
    }
  }

  /** Please do not instantiate this static utility class. */
  private init() { fatalError() }
}
