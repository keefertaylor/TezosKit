import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let tezosClient = TezosClient()
    tezosClient.getHeadHash() { headHash, error in
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


