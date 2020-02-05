// Copyright Keefer Taylor, 2020.

import TezosKit
import UIKit

class ViewController: UIViewController {
  /// UI Components.
  public let titleLabel: UILabel = UILabel()
  public let generateKey: UIButton = BackgroundHighlightedButton()
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

  /// The last operation hash received from TezosClient.
  var opHash: String?

  var nodeClient: TezosNodeClient?

  // MARK: - UIView

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = "Tezos Secure Enclave Signing"
    titleLabel.textColor = .black
    generateKey.setTitle("Generate Key", for: .normal)
    generateKey.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
    generateKey.backgroundColor = .gray
    generateKey.addTarget(self, action: #selector(generate), for: .touchUpInside)
    self.view.addSubview(generateKey)

    pkh.text = "Public Key Hash:"
    pkh.textColor = .black
    pkh.frame = CGRect(x: 50, y: 270, width: 300, height: 20)
    self.view.addSubview(pkh)

    genKey.text = ""
    genKey.textColor = .black
    genKey.frame = CGRect(x: 50, y: 310, width: 300, height: 20)
    self.view.addSubview(genKey)

    dest.text = "Destination:"
    dest.textColor = .black
    dest.frame = CGRect(x: 50, y: 350, width: 300, height: 20)
    self.view.addSubview(dest)

    destKey.text = "tz1NpWrAyDL9k2Lmnyxcgr9xuJakbBxdq7FB"
    destKey.textColor = .black
    destKey.frame = CGRect(x: 50, y: 390, width: 300, height: 20)
    self.view.addSubview(destKey)

    signTransaction.setTitle("Sign And Broadcast", for: .normal)
    signTransaction.frame = CGRect(x: 50, y: 460, width: 300, height: 50)
    signTransaction.backgroundColor = .gray
    signTransaction.addTarget(self, action: #selector(send), for: .touchUpInside)
    self.view.addSubview(signTransaction)

    h.text = "Operation Hash:"
    h.textColor = .black
    h.frame = CGRect(x: 50, y: 530, width: 300, height: 20)
    self.view.addSubview(h)

    hash2.text = ""
    hash2.textColor = .black
    hash2.frame = CGRect(x: 50, y: 570, width: 300, height: 20)
    self.view.addSubview(hash2)

    open.setTitle("Open in Block Explorer", for: .normal)
    open.frame = CGRect(x: 50, y: 610, width: 300, height: 50)
    open.backgroundColor = .gray
    open.addTarget(self, action: #selector(openFn), for: .touchUpInside)
    self.view.addSubview(open)
  }

  // MARK: - User Interaction

  @objc
  func generate() {
    let wallet = Wallet()!
    genKey.text = wallet.address
    print(wallet.address)

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
      from: wallet.address,
      signatureProvider: wallet,
      operationFeePolicy: .estimate
    ) { result in
      switch result {
      case .success(let opHash):
        self.opHash = opHash
      case .failure(let error):
        print("error :( \(error)")
      }
    }
  }

  @objc
  func openFn() {
    let url = URL(string: "https://babylonnet.tzstats.com/" + opHash!)!
    UIApplication.shared.open(url)
  }
}
