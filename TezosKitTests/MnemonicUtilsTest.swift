import XCTest
import TezosKit

class MnemonicUtilsTest2: XCTestCase {
  // Mnemonic and Passphrase for tests.
  private let mnemonic = "soccer click number muscle police corn couch bitter gorilla camp camera shove expire praise pill"
  private let passphrase = "TezosKitTests"

  // Expected seed strings with / without passphrase.
  private let expectedSeedStringNoPassphrase = "cce78b57ed8f4ec6767ed35f3aa41df525a03455e24bcc45a8518f63fbeda772"
  private let expectedSeedStringWithPassphrase = "cc90fecd0a596e2cd41798612682395faa2ebfe18945a88c6f01e4bfab17c3e3"

  // Mnemonic generation should always succeed.
  public func testGenerateMnemonic() {
    let result = MnemonicUtil.generateMnemonic()
    XCTAssertNotNil(result)
  }

  public func testSeedStringFromMnemonicNoPassphrase() {
    guard let result = MnemonicUtil.seedString(from: mnemonic) else {
      fatalError()
    }
    XCTAssertEqual(result, expectedSeedStringNoPassphrase)
  }

  public func testSeedStringFromMnemonicEmptyPassphrase() {
    guard let result = MnemonicUtil.seedString(from: mnemonic, passphrase: "") else {
      fatalError()
    }

    // Empty passphrase should be the same as no passphrase.
    XCTAssertEqual(result, expectedSeedStringNoPassphrase)
  }

  public func testSeedStringFromMnemonicWithPassphrase() {
    guard let result = MnemonicUtil.seedString(from: mnemonic, passphrase: passphrase) else {
      fatalError()
    }

    // Empty passphrase should be the same as no passphrase.
    XCTAssertEqual(result, expectedSeedStringWithPassphrase)
  }
}
