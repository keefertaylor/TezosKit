// Copyright Keefer Taylor, 2019

import Foundation

/** An enum representing possible field types on a Conseil service. */
// TODO: Bug Mike if this list can be code-genned
public enum ConseilFields: String {
  case accountID = "account_id"
  case spendable
  case counter
  case balance
}
