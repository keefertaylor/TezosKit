import Foundation

public extension String {
	public func mnemonicData() -> Data {
		let length = self.count
		let dataLength = length / 2
		var dataToReturn = Data(capacity: dataLength)

    var outIndex = 0
		var outChars = ""
    for (_, char) in enumerated() {
			outChars += String(char)
			if outIndex % 2 == 1 {
				let i: UInt8 = UInt8(strtoul(outChars, nil, 16))
				dataToReturn.append(i)
				outChars = ""
			}
			outIndex += 1
		}

		return dataToReturn
	}
}
