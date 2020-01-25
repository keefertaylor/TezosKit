// Copyright Keefer Taylor, 2018

import Foundation

/// An enum representing all supported operation types. Raw values of the enum represent the string the Tezos blockchain
/// expects for the "kind" attribute when forging / pre-applying / injecting operations
public enum OperationKind: String {
  case transaction
  case reveal
  case delegation
}
