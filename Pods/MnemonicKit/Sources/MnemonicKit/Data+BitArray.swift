import Foundation
import CryptoSwift

public extension UInt8 {
	public func mnemonicBits() -> [String] {
		let totalBitsCount = MemoryLayout<UInt8>.size * 8

		var bitsArray = [String](repeating: "0", count: totalBitsCount)

		for j in 0 ..< totalBitsCount {
			let bitVal: UInt8 = 1 << UInt8(totalBitsCount - 1 - j)
			let check = self & bitVal

			if (check != 0) {
				bitsArray[j] = "1"
			}
		}
		return bitsArray
	}
}

public extension Data {
	public func toBitArray() -> [String] {
		var toReturn = [String]()
		for num: UInt8 in bytes {
			toReturn.append(contentsOf: num.mnemonicBits())
		}
		return toReturn
	}
}
