// Copyright Keefer Taylor, 2020.

import Foundation

/// A wallet which stores keys in a device's secure enclave.
///
/// WARNING: Keys generated in the secure enclave are not able to be backed up. Additionally, iOS may choose to remove these keys at it's discretion, including
///          when biometrics on the device are changed, a the device is restored, or the host app is deleted. This wallet should only be used as part of a
///          multisignature signing scheme with a proper backup.
///          Read more: https://medium.com/@keefertaylor/signing-tezos-transactions-with-ioss-secure-enclave-and-face-id-6166a752519?source=your_stories_page---------------------------
@available(OSX 10.12.1, iOS 9.0, *)
public class SecureEnclaveWallet: DeviceWallet {
  /// Labels for keys in the enclave.
  private enum KeyLabels {
    public static let `public` = "TezosKitEnclave.public"
    public static let `private` = "TezosKitEnclave.private"
  }

  /// Returns whether the device contains a secure enclave.
  public static var deviceHasSecureEnclave: Bool {
    return EllipticCurveKeyPair.Device.hasSecureEnclave
  }

  /// - Parameter prompt: A prompt to use when asking the wallet to sign bytes.
  public init?(prompt: String) {
    // Ensure that the device has access to a secure enclave.
    guard SecureEnclaveWallet.deviceHasSecureEnclave else {
      return nil
    }

    super.init(
      prompt: prompt,
      token: .secureEnclave,
      publicKeyLabel: KeyLabels.public,
      privateKeyLabel: KeyLabels.private
    )
  }
}
