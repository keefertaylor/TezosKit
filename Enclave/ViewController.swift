//
//  ViewController.swift
//  Enclave
//
//  Created by Keefer Taylor on 5/1/19.
//  Copyright © 2019 Keefer Taylor. All rights reserved.
//

import UIKit
import TezosKit

class BackgroundHighlightedButton: UIButton {
  @IBInspectable var highlightedBackgroundColor :UIColor?
  @IBInspectable var nonHighlightedBackgroundColor :UIColor?
  override var isHighlighted :Bool {
    get {
      return super.isHighlighted
    }
    set {
      if newValue {
        self.backgroundColor = .blue
      }
      else {
        self.backgroundColor = .gray
      }
      super.isHighlighted = isHighlighted
    }
  }
}


class ViewController: UIViewController {
  public let title: UILabel = UILabel()


  public let generateKey: UIButton = BackgroundHighlightedButton()
  public let pkh: UILabel = UILabel()
  public let genKey: UILabel = UILabel()
  public let dest: UILabel = UILabel()
  public let destKey: UILabel = UILabel()

  var nodeClient: TezosNodeClient?

  public let signTransaction: UIButton = BackgroundHighlightedButton()
  public let h = UILabel()
  public let hash2 = UILabel()

  public let open: UIButton = BackgroundHighlightedButton()


  override func viewDidLoad() {
    super.viewDidLoad()

//    title.setTitle("Tezos Secure Enclave Signing")

    generateKey.setTitle("Generate Key", for: .normal)
    generateKey.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
    generateKey.backgroundColor = .gray
    generateKey.addTarget(self, action: #selector(generate), for: .touchUpInside)
    self.view.addSubview(generateKey)

    pkh.text = "Public Key Hash:"
    pkh.frame = CGRect(x: 50, y: 270, width: 300, height: 20)
    self.view.addSubview(pkh)

    genKey.text = ""
    genKey.frame = CGRect(x: 50, y: 310, width: 300, height: 20)
    self.view.addSubview(genKey)

    dest.text = "Destination:"
    dest.frame = CGRect(x: 50, y: 350, width: 300, height: 20)
    self.view.addSubview(dest)


    destKey.text = "tz1NpWrAyDL9k2Lmnyxcgr9xuJakbBxdq7FB"
    destKey.frame = CGRect(x: 50, y: 390, width: 300, height: 20)
    self.view.addSubview(destKey)

    signTransaction.setTitle("Sign And Broadcast", for: .normal)
    signTransaction.frame = CGRect(x: 50, y: 460, width: 300, height: 50)
    signTransaction.backgroundColor = .gray
    signTransaction.addTarget(self, action: #selector(send), for: .touchUpInside)
    self.view.addSubview(signTransaction)

    h.text = "Operation Hash:"
    h.frame = CGRect(x: 50, y: 530, width: 300, height: 20)
    self.view.addSubview(h)

    hash2.text = ""
    hash2.frame = CGRect(x: 50, y: 570, width: 300, height: 20)
    self.view.addSubview(hash2)

    open.setTitle("Open in TzScan", for: .normal)
    open.frame = CGRect(x: 50, y: 610, width: 300, height: 50)
    open.backgroundColor = .gray
    open.addTarget(self, action: #selector(openFn), for: .touchUpInside)
    self.view.addSubview(open)
  }

  @objc
  func generate() {
    // TODO: Update this
    // TODO: REcall key compression.
    genKey.text = "tz3fq2juip9PQfxnQ5JTdwzEscdkVpWi2rTs"
  }

  var opHash: String? = nil

  @objc
  func send() {
    let nodeURL =  URL(string: "http://alphanet-node.tzscan.io:80")! // URL(string: "http://127.0.0.1:8732")!
    nodeClient = TezosNodeClient(remoteNodeURL: nodeURL)

    let wallet = Wallet()!
    nodeClient!.send(
    amount: Tez("1")!, to: "tz1NpWrAyDL9k2Lmnyxcgr9xuJakbBxdq7FB", from: "tz3fq2juip9PQfxnQ5JTdwzEscdkVpWi2rTs", keys: wallet.keys) { result in
      switch result {
      case .failure(let error):
        print("WRONG")
        print(error)
      case .success(let hash):
        self.opHash = hash
        self.hash2.text = hash
      }
    }
  }

  @objc
  func openFn() {
    let url = URL(string: "https://alphanet.tzscan.io/" + opHash!)!
    UIApplication.shared.open(url)
  }


}

