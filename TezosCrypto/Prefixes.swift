// Copyright Keefer Taylor, 2019

import Foundation

/// Common prefixes used across Tezos Cryptography.
public enum Prefix {
  public enum Watermark {
    public static let operation: [UInt8] = [ 3 ] // 03
  }

  public enum Keys {
    public static let `public`: [UInt8] = [13, 15, 37, 217] // edpk
    public static let secret: [UInt8] = [43, 246, 78, 7]    // edsk
    public static let seed: [UInt8] = [13, 15, 58, 7]       // edsk
  }

  public enum Sign {
    public static let operation: [UInt8] = [9, 245, 205, 134, 18] // edsig
  }

  public enum Address {
    public static let tz1: [UInt8] = [6, 161, 159] // tz1
    public static let tz2: [UInt8] = [6, 161, 161] // tz1
    public static let tz3_real: [UInt8] = [6, 161, 161] // tz3
  }

  public enum Secp {
    public static let secret: [UInt8] = [17, 162, 224, 201]  // spsk
    public static let `public`: [UInt8] = [3, 254, 226, 86] // sppk
    public static let sig: [UInt8] = [13, 115, 101, 19, 63] // spsig
  }

  public enum Nist {
    public static let secret: [UInt8] = [16, 81, 238, 189]  // p2sk
    public static let `public`: [UInt8] = [3, 178, 139, 127] // p2pk
    public static let sig: [UInt8] = [54, 240, 44, 52] // p2sig

  }
}
