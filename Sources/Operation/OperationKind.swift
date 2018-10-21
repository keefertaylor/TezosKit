import Foundation

/**
 * An enum representing all supported operation types. Raw values of the enum represent the string
 * the Tezos blockchain expects for the "kind" attribute when forging / pre-applying / injecting
 * operations.
 */
public enum OperationKind: String {
  case delegation = "delegation"
  case transaction = "transaction"
  case origination = "origination"
  case activateAccount = "activate_account"
}
