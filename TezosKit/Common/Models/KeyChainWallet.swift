// Copyright Keefer Taylor, 2020.

import Foundation

/// A wallet which stores keys in a device's keychain.
public class KeyChainWallet: DeviceWallet {
  /// - Parameter prompt: A prompt to use when asking the wallet to sign bytes.
  public init?(prompt: String) {
    super.init(prompt: prompt, token: .keychain)
  }
}
