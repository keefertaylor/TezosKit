// Copyright Keefer Taylor, 2018

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let tezosClient = TezosClient()
    tezosClient.getHeadHash { headHash, error in
      guard let headHash = headHash,
        error == nil else {
        print("Couldn't fetch head :(")
        if let error = error {
          print("Error: \(error)")
        }
        return
      }

      print("The hash at the head of the chain is: \(headHash)")
    }

    return true
  }
}
