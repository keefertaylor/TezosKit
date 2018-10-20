import Foundation

/**
 * A model class representing a balance of Tezos.
 */
public class TezosBalance {
  // The number of decimal places available in Tezos values.
  private let decimalDigitCount = 6

  private let integerAmount: String
  private let decimalAmount: String

  public var humanReadableRepresentation: String {
    return integerAmount + "." + decimalAmount + " ꜩ"
  }

  public init?(balance: Double) {
    // TODO: implement.
    return nil
  }

  public init?(balance: String) {
    // Pad small numbers with up to six zeros so that the below slicing works correctly
    var paddedBalance = balance
    while paddedBalance.count < decimalDigitCount {
      paddedBalance = "0" + paddedBalance
    }

    let integerDigitEndIndex =
        paddedBalance.index(paddedBalance.startIndex,
                            offsetBy: paddedBalance.count - decimalDigitCount)

    let integerString = paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex].count > 0 ?
        paddedBalance[paddedBalance.startIndex..<integerDigitEndIndex] : "0"
    let decimalString = paddedBalance[integerDigitEndIndex..<paddedBalance.endIndex]

    self.integerAmount = String(integerString)
    self.decimalAmount = String(decimalString)
  }
}
