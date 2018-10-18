import Foundation

public struct TezosBalance {
  public let balance: String
  public var formattedBalance: String {
    let decimalDigitCount = 6

    // Pad small numbers with up to six zeros so that the below slicing works correctly
    var paddedBalance = balance
    while paddedBalance.count < decimalDigitCount {
      paddedBalance = "0" + paddedBalance
    }

    let integerDigitEndIndex =
        paddedBalance.index(paddedBalance.startIndex, offsetBy: paddedBalance.count - decimalDigitCount)

    let integerString = paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex].count > 0 ?
        paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex] : "0"
    let decimalString = paddedBalance[integerDigitEndIndex..<paddedBalance.endIndex]

    return integerString + "." + decimalString
  }

  public init(balance: String) {
    // Trim any non-numeric characters. The Tezos API quotes numbers as they return to us.
    let nonDigitCharacterSet = CharacterSet.decimalDigits.inverted
    let trimmedBalance = balance.trimmingCharacters(in: nonDigitCharacterSet)
    self.balance = trimmedBalance
  }
}
