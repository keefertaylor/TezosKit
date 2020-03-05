// Copyright Keefer Taylor, 2020.

import Foundation

/// A wallet which stores keys in a device's keychain.
public class KeyChainWallet: DeviceWallet {
  /// Labels for keys in the Keychain.
  private enum KeyLabels {
    public static let `public` = "TezosKitKeyChain.public"
    public static let `private` = "TezosKitKeyChain.private"
  }

  /// - Parameter prompt: A prompt to use when asking the wallet to sign bytes.
  public init?(prompt: String) {
    super.init(prompt: prompt, token: .keychain, publicKeyLabel: KeyLabels.public, privateKeyLabel: KeyLabels.private)
  }
}
