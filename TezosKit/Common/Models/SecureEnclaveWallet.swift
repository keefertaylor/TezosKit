// Copyright Keefer Taylor, 2020.

import Base58Swift
import EllipticCurveKeyPair
import Security

/// A wallet which stores keys in a device's secure enclave.
/// TODO(keefertaylor): Wire this class for compatibility with non-enclave enabled environments
public class SecureEnclaveWallet {
  private enum KeyLabels {
    public static let `public` = "com.keefertaylor.tezoskit.secureenclave.public"
    public static let secret = "com.keefertaylor.tezoskit.secureenclave.secret"
  }

  private let manager: EllipticCurveKeyPair.Manager

  public init() {
    let accessControl = EllipticCurveKeyPair.AccessControl(
      protection: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
      flags: SecAccessControlCreateFlags.userPresence
    )

    let config = EllipticCurveKeyPair.Config(
      publicLabel: KeyLabels.public,
      privateLabel: KeyLabels.secret,
      operationPrompt: "Sign operation?",
      publicKeyAccessControl: accessControl,
      privateKeyAccessControl: accessControl,
      token: .secureEnclave
    )
    self.manager = EllipticCurveKeyPair.Manager(config: config)
  }

  public func publicKey() -> PublicKeyProtocol {
    // TODO(keefertaylor): Consider propagating errors.
    let publicKey = try! self.manager.publicKey()
    let publicKeyData = try! publicKey.data()
    // TODO(keefertaylor): Do I want DER format here?
    let publicKeyBytes = publicKeyData.raw.bytes

    return PublicKey(bytes: publicKeyBytes, signingCurve: .p256)
  }
}

//
//  private static let tag = "com.keefertaylor.tezoskit.secure_enclave_keys"
//
//  // TODO(keefertaylor): Better names
//  private let privateKeyRef: SecKey
//  private let publicKeyRef: SecKey
//
//  public init?() {
//    if (SecureEnclaveWallet.hasKeys()) {
//      self.privateKeyRef = getPrivateKey()
//    } else {
//      self.privateKeyRef = generatePrivateKey()
//    }
//
//    self.publicKeyRef = SecKeyCopyPublicKey(privateKeyRef)
//  }
//
//  public func sign(_ hex: String) -> [UInt8]? {
//    return nil
//  }
//
//  public func publicKey() -> PublicKeyProtocol {
//    let base58CheckRepresentation = self.publicKeyRef.data().raw
//
//    fatalError("Unimplemented")
//  }
//
//  private static func hasKeys() -> Bool {
//    // TODO(keefertaylor): implement me.
//    return false
//  }
//
//  private func generateKeys() {
//    // TODO(keefertaylor): Do not ignore error
//    // TODO(keefertaylor): Better name
//    let access = SecAccessControlCreateWithFlags(
//      kCFAllocatorDefault,
//      kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
//      .privateKeyUsage,
//      nil)!   // Ignore error
//
//    // TODO(keefertaylor): Investigate if these are the correct attributes to use
//    // TODO(keefertaylor): Guard that these keys don't already exist.
//    // See: https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/key_generation_attributes
//    let tag = SecureEnclaveWallet.tag.data(using: .utf8)!
//    let attributes: [String: Any] = [
//      kSecAttrKeyType as String: type,
//      kSecAttrKeySizeInBits as String: 256,
//      kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
//      kSecPrivateKeyAttrs as String: [
//        kSecAttrIsPermanent as String: true,
//        kSecAttrApplicationTag as String: tag,
//        kSecAttrAccessControl as String: access
//      ]
//    ]
//
//    var error: Unmanaged<CFError>?
//    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
//        throw error!.takeRetainedValue() as Error
//    }
//
//    let publicKey = SecKeyCopyPublicKey(privateKey)
//
//  }
//
//  func getPublicKey() throws -> SecureEnclaveKeyData {
//
//         let query: [String: Any] = [
//             kSecClass as String: kSecClassKey,
//             kSecAttrKeyType as String: attrKeyTypeEllipticCurve,
//             kSecAttrApplicationTag as String: publicLabel,
//             kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
//             kSecReturnData as String: true,
//             kSecReturnRef as String: true,
//             kSecReturnPersistentRef as String: true,
//         ]
//
//         let raw = try getSecKeyWithQuery(query)
//         return SecureEnclaveKeyData(raw as! CFDictionary)
//     }
//
//  func getPrivateKey() throws -> SecureEnclaveKeyReference {
//
//      let query: [String: Any] = [
//          kSecClass as String: kSecClassKey,
//          kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
//          kSecAttrLabel as String: privateLabel,
//          kSecReturnRef as String: true,
//          kSecUseOperationPrompt as String: self.operationPrompt,
//      ]
//
//      let raw = try getSecKeyWithQuery(query)
//      return SecureEnclaveKeyReference(raw as! SecKey)
//  }
//}
