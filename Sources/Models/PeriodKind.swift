// Copyright Keefer Taylor, 2018

import Foundation

/** An enum representing the current period for protocol upgrades. */
public enum PeriodKind: String {
  case proposal
  case testing_vote
  case testing
  case promotion_vote
}
