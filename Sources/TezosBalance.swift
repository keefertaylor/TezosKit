import Foundation

/**
 * A model class representing a balance of Tezos.
 */
public class TezosBalance {
  // The number of decimal places available in Tezos values.
  private let decimalDigitCount = 6

  private let integerAmount: String
  private let decimalAmount: String

  /**
   * A human readable representation of the given balance.
   */
  public var humanReadableRepresentation: String {
    return integerAmount + "." + decimalAmount + " ꜩ"
  }

  /**
   * Initialize a new balance from a given decimal number.
   *
   * @warning Balances are accurate up to |decimalDigitCount| decimal places. Additional precision
   * is dropped.
   */
  public init(balance: Double) {
    let integerValue = Int(balance)

    // Convert 6 significant digits of decimals into integers to avoid having to deal with decimals.
    let multiplierDoubleValue = (pow(10, decimalDigitCount) as NSDecimalNumber).doubleValue
    let multiplierIntValue = (pow(10, decimalDigitCount) as NSDecimalNumber).intValue
    let significantDecimalDigitsAsInteger = Int(balance * multiplierDoubleValue)
    let significantIntegerDigitsAsInteger = integerValue * multiplierIntValue
    let decimalValue = significantDecimalDigitsAsInteger - significantIntegerDigitsAsInteger

    self.integerAmount = String(integerValue)
    self.decimalAmount = String(decimalValue)
  }

  /**
   * Initialize a new balance from an RPC representation of a balance.
   *
   * @warning The only allowed characters in the input string are digits. This method will crash if
   *          given an unexpected input.
   * TODO: Make this initializer nicely tell clients they've messed up rather than crashing.
   */
  public init(balance: String) {
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
