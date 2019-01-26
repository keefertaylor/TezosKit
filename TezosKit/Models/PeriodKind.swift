// Copyright Keefer Taylor, 2018

import Foundation

/** An enum representing the current period for protocol upgrades. */
public enum PeriodKind: String {
  case proposal
  case testingVote
  case testing
  case promotionVote
}
