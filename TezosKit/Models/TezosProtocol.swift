// Copyright Keefer Taylor, 2019.

import Foundation

/// Protocols supported by TezosKit.
///
/// - Note: The Tezos network upgrades asynchronously and protocol versions between Zeronet, Alphanet and Mainnet are
///         not necessarily the same.
public enum TezosProtocol {
  case athens // Protocol version 4
}
