// Copyright Keefer Taylor, 2019

import Foundation

/// Entities that may be queried in the Conseil API.
public enum ConseilEntity: String, CaseIterable {
  case account = "accounts"
  case baker = "bakers"
  case ballots = "ballots"
  case block = "blocks"
  case fee = "fees"
  case operation = "operations"
  case operationGroup = "operation_groups"
  case proposal = "proposals"
}
