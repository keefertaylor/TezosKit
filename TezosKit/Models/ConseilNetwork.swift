// Copyright Keefer Taylor, 2019

import Foundation

/** An enum representing possible query states on conseil. */
// TODO: Consider renaming this to 'network' and re-using across TezosNode RPCs.
public enum ConseilNetwork: String {
  case alphanet
  case mainnet
  case zeronet
}
