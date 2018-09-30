import Foundation

public struct TezosBalance {
  public let balance: String
  public var formattedBalance: String {
    let digitCount = balance.count
    let decimalDigitCount = 6
    let integerDigitEndIndex = balance.index(balance.startIndex, offsetBy: digitCount - decimalDigitCount)

    let integerString = balance[balance.startIndex..<integerDigitEndIndex]
    let decimalString = balance[integerDigitEndIndex..<balance.endIndex]

    return integerString + "." + decimalString
  }

  public init(balance: String) {
    // Trim any non-numeric characters. The Tezos API quotes numbers as they return to us.
    let nonDigitCharacterSet = CharacterSet.decimalDigits.inverted
    let trimmedBalance = balance.trimmingCharacters(in: nonDigitCharacterSet)
    self.balance = trimmedBalance
  }
}
