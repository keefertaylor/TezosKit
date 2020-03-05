// Copyright Keefer Taylor, 2020.

import TezosKit
import UIKit

class ViewController: UIViewController {
  /// UI Components.
  public let titleLabel: UILabel = UILabel()
  public let generateEnclaveKey: UIButton = BackgroundHighlightedButton()
  public let generateKeychainKey: UIButton = BackgroundHighlightedButton()
  public let pkh: UILabel = UILabel()
  public let genKey: UILabel = UILabel()
  public let dest: UILabel = UILabel()
  public let destKey: UILabel = UILabel()
  public let signTransaction: UIButton = BackgroundHighlightedButton()
  public let h = UILabel()
  public let hash2 = UILabel()
  public let open: UIButton = BackgroundHighlightedButton()

  /// The wallet that we're interacting with.
  var wallet: SignatureProvider?

  var address: String?

  /// The last operation hash received from TezosClient.
  var opHash: String?

  var nodeClient: TezosNodeClient?

  // MARK: - UIView

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "Tezos Secure Enclave Signing"
    titleLabel.textColor = .black
    titleLabel.frame = CGRect(x: 50, y: 50, width: 300, height: 50)
    self.view.addSubview(titleLabel)

    generateKeychainKey.setTitle("Generate Key (Keychain)", for: .normal)
    generateKeychainKey.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
    generateKeychainKey.backgroundColor = .gray
    generateKeychainKey.addTarget(self, action: #selector(generateKeychainWallet), for: .touchUpInside)
    self.view.addSubview(generateKeychainKey)

    generateEnclaveKey.setTitle("Generate Key (Secure Enclave)", for: .normal)
    generateEnclaveKey.frame = CGRect(x: 50, y: 270, width: 300, height: 50)
    generateEnclaveKey.backgroundColor = .gray
    generateEnclaveKey.addTarget(self, action: #selector(generateEnclaveWallet), for: .touchUpInside)
    self.view.addSubview(generateEnclaveKey)

    pkh.text = "Public Key Hash:"
    pkh.textColor = .black
    pkh.frame = CGRect(x: 50, y: 340, width: 300, height: 20)
    self.view.addSubview(pkh)

    genKey.text = ""
    genKey.textColor = .black
    genKey.frame = CGRect(x: 50, y: 390, width: 300, height: 20)
    self.view.addSubview(genKey)

    dest.text = "Destination:"
    dest.textColor = .black
    dest.frame = CGRect(x: 50, y: 410, width: 300, height: 20)
    self.view.addSubview(dest)

    destKey.text = "tz1NpWrAyDL9k2Lmnyxcgr9xuJakbBxdq7FB"
    destKey.textColor = .black
    destKey.frame = CGRect(x: 50, y: 430, width: 300, height: 20)
    self.view.addSubview(destKey)

    signTransaction.setTitle("Sign And Broadcast", for: .normal)
    signTransaction.frame = CGRect(x: 50, y: 470, width: 300, height: 50)
    signTransaction.backgroundColor = .gray
    signTransaction.addTarget(self, action: #selector(send), for: .touchUpInside)
    self.view.addSubview(signTransaction)

    h.text = "Operation Hash:"
    h.textColor = .black
    h.frame = CGRect(x: 50, y: 570, width: 300, height: 20)
    self.view.addSubview(h)

    hash2.text = ""
    hash2.textColor = .black
    hash2.frame = CGRect(x: 50, y: 610, width: 300, height: 20)
    self.view.addSubview(hash2)

    open.setTitle("Open in Block Explorer", for: .normal)
    open.frame = CGRect(x: 50, y: 640, width: 300, height: 50)
    open.backgroundColor = .gray
    open.addTarget(self, action: #selector(openFn), for: .touchUpInside)
    self.view.addSubview(open)
  }

  // MARK: - User Interaction

  @objc
  func generateEnclaveWallet() {
    let wallet = SecureEnclaveWallet(prompt: "Sign using secure enclave")!
    genKey.text = wallet.address
    print(wallet.address)

    self.address = wallet.address
    self.wallet = wallet
  }

  @objc
   func generateKeychainWallet() {
     let wallet = KeyChainWallet(prompt: "Sign using keychain")!
     genKey.text = wallet.address
     print(wallet.address)

     self.address = wallet.address
     self.wallet = wallet
   }

  @objc
  func send() {
    guard let wallet = self.wallet else {
      return
    }

    let nodeURL = URL(string: "https://tezos-dev.cryptonomic-infra.tech")!
    let nodeClient = TezosNodeClient(remoteNodeURL: nodeURL, callbackQueue: DispatchQueue(label: "tezosqueue"))
    self.nodeClient = nodeClient
    nodeClient.send(
      amount: Tez("1")!,
      to: "tz1NpWrAyDL9k2Lmnyxcgr9xuJakbBxdq7FB",
      from: self.address!,
      signatureProvider: wallet,
      operationFeePolicy: .estimate
    ) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let opHash):
          self.opHash = opHash
          self.hash2.text = opHash
        case .failure(let error):
          print("error :( \(error)")
        }
      }
    }
  }

  @objc
  func openFn() {
    let url = URL(string: "https://babylonnet.tzstats.com/" + opHash!)!
    UIApplication.shared.open(url)
  }
}
