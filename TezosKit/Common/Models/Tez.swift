// Copyright Keefer Taylor, 2018

import BigInt
import Foundation

/// A model class representing a positive floating point amounty of Tez.
public struct Tez {
  /// A balance of zero.
  public static let zeroBalance = Tez(0.0)

  /// The number of decimal places available in Tezos values.
  private static let decimalDigitCount = 6

  /// A int representing the integer amount of the balance.
  /// For instance, a balance of 123.456 would be represented in this field as 123.
  private let integerAmount: BigInt

  /// A int representing the decimal amount of the balance.
  /// For instance, a balance of 123.456 would be represented in this field as 4564.
  private let decimalAmount: BigInt

  /// A human readable representation of the given balance.
  public var humanReadableRepresentation: String {
    // Decimal values need to be at least decimalDigitCount long. If the decimal value resolved to
    // be less than 6 then the number dropped leading zeros. E.G. '0' instead of '000000' or '400'
    // rather than 000400.
    var paddedDecimalAmount = String(decimalAmount)
    while paddedDecimalAmount.count < Tez.decimalDigitCount {
      paddedDecimalAmount = "0" + paddedDecimalAmount
    }
    return String(integerAmount) + "." + String(paddedDecimalAmount)
  }

  /// A representation of the given balance for use in RPC requests.
  public var rpcRepresentation: String {
    // Decimal values need to be at least decimalDigitCount long. If the decimal value resolved to
    // be less than 6 then the number dropped leading zeros. E.G. '0' instead of '000000' or '400'
    // rather than 000400.
    var paddedDecimalAmount = String(decimalAmount)
    while paddedDecimalAmount.count < Tez.decimalDigitCount {
      paddedDecimalAmount = "0" + paddedDecimalAmount
    }

    // Trim any leading zeroes by converting to an Int.
    let intermediateString = String(integerAmount) + String(paddedDecimalAmount)
    return intermediateString.replacingOccurrences(
      of: "^0+",
      with: "",
      options: .regularExpression
    )
  }

  /// Initialize a new balance from a given decimal number.
  ///
  /// - Warning: Balances are accurate up to |decimalDigitCount| decimal places. Additional precision is dropped.
  public init(_ balance: Double) {
    let integerValue = BigInt(balance)

    // Convert decimalDigitCount significant digits of decimals into integers to avoid having to
    // deal with decimals.
    let multiplierDoubleValue = (pow(10, Tez.decimalDigitCount) as NSDecimalNumber).doubleValue
    let multiplierIntValue = (pow(10, Tez.decimalDigitCount) as NSDecimalNumber).intValue
    let significantDecimalDigitsAsInteger = BigInt(balance * multiplierDoubleValue)
    let significantIntegerDigitsAsInteger = BigInt(integerValue * BigInt(multiplierIntValue))
    let decimalValue = significantDecimalDigitsAsInteger - significantIntegerDigitsAsInteger

    self.init(integerAmount: integerValue, decimalAmount: decimalValue)
  }

  /// Initialize a new balance from an RPC representation of a balance.
  public init?(_ balance: String) {
    // Make sure the given string only contains digits.
    guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: balance)) else {
      return nil
    }

    // Pad small numbers with up to six zeros so that the below slicing works correctly
    var paddedBalance = balance
    while paddedBalance.count < Tez.decimalDigitCount {
      paddedBalance = "0" + paddedBalance
    }

    let integerDigitEndIndex =
      paddedBalance.index(paddedBalance.startIndex, offsetBy: paddedBalance.count - Tez.decimalDigitCount)

    let integerRange = paddedBalance.startIndex ..< integerDigitEndIndex
    let integerString = paddedBalance[integerRange].isEmpty ? "0" : paddedBalance[integerRange]
    let decimalString = paddedBalance[integerDigitEndIndex ..< paddedBalance.endIndex]

    guard
      let integerAmount = BigInt(String(integerString)),
      let decimalAmount = BigInt(String(decimalString))
    else {
      return nil
    }

    self.init(integerAmount: integerAmount, decimalAmount: decimalAmount)
  }

  internal init(mutez: Int) {
    self.init(String(mutez))!
  }

  private init(integerAmount: BigInt, decimalAmount: BigInt) {
    self.integerAmount = integerAmount
    self.decimalAmount = decimalAmount
  }
}

extension Tez: AdditiveArithmetic {
  public static func + (left: Tez, right: Tez) -> Tez {
    var newIntegerAmount = left.integerAmount + right.integerAmount
    var newDecimalAmount = left.decimalAmount + right.decimalAmount

    if newDecimalAmount / BigInt((pow(10, Tez.decimalDigitCount) as NSDecimalNumber).intValue) >= 1 {
      newIntegerAmount += 1
      newDecimalAmount -= BigInt((pow(10, Tez.decimalDigitCount) as NSDecimalNumber).intValue)
    }

    return Tez(integerAmount: newIntegerAmount, decimalAmount: newDecimalAmount)
  }

  public static func -= (lhs: inout Tez, rhs: Tez) {
    let result = lhs - rhs
    lhs = result
  }

  public static func - (lhs: Tez, rhs: Tez) -> Tez {
    var newIntegerAmount = lhs.integerAmount - rhs.integerAmount
    var newDecimalAmount = lhs.decimalAmount - rhs.decimalAmount

    if newDecimalAmount < 0 {
      newIntegerAmount -= 1
      newDecimalAmount += BigInt((pow(10, Tez.decimalDigitCount) as NSDecimalNumber).intValue)
    }

    return Tez(integerAmount: newIntegerAmount, decimalAmount: newDecimalAmount)
  }

  public static func += (lhs: inout Tez, rhs: Tez) {
    let result = lhs + rhs
    lhs = result
  }

  public static var zero: Tez {
    return Tez.zeroBalance
  }
}

extension Tez: Comparable {
  public static func < (lhs: Tez, rhs: Tez) -> Bool {
    let lhsMutez = BigInt(lhs.rpcRepresentation)!
    let rhsMutez = BigInt(rhs.rpcRepresentation)!
    return lhsMutez < rhsMutez
  }
}

extension Tez: Equatable {
  public static func == (lhs: Tez, rhs: Tez) -> Bool {
    return lhs.rpcRepresentation == rhs.rpcRepresentation
  }
}

extension Tez: CustomStringConvertible {
  public var description: String {
    return humanReadableRepresentation
  }
}
