// Copyright Keefer Taylor, 2019.

private enum JSON {
  public enum Keys {
    public static let args = "args"
    public static let int = "int"
  }
}

/// A client for a DEXter exchange.
/// - See: https://gitlab.com/camlcase-dev/dexter
public class DexterExchangeClient {
  /// An underlying gateway to the Tezos Network.
  private let tezosNodeClient: TezosNodeClient

  /// The address of a DEXter exchange contract.
  private let exchangeContractAddress: Address

  /// Initialize a new DEXter client.
  ///
  /// - Parameters:
  ///   - exchangeContractAddress: The address of the exchange contract.
  ///   - tezosNodeClient: A TezosNodeClient which will make requests to the Tezos Network. Defaults to the default
  ///     client.
  public init(exchangeContractAddress: Address, tezosNodeClient: TezosNodeClient = TezosNodeClient()) {
    self.tezosNodeClient = tezosNodeClient
    self.exchangeContractAddress = exchangeContractAddress
  }

  /// Get the total balance of the exchange in Tez.
  public func getExchangeBalanceTez(completion: @escaping (Result<Tez, TezosKitError>) -> Void) {
    tezosNodeClient.getBalance(address: exchangeContractAddress, completion: completion)
  }

  /// Get the total balance of the exchange in tokens.
  public func getExchangeBalanceTokens(
    tokenContractAddress: Address,
    completion: @escaping(Result<Int, TezosKitError>) -> Void
  ) {
    let tokenClient = TokenContractClient(tokenContractAddress: tokenContractAddress, tezosNodeClient: tezosNodeClient)
    tokenClient.getTokenBalance(address: exchangeContractAddress, completion: completion)
  }

  /// Get the total exchange liquidity.
  public func getExchangeLiquidity(completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    tezosNodeClient.getContractStorage(address: exchangeContractAddress) { result in
      guard
        case let .success(json) = result,
        let args0 = json[JSON.Keys.args] as? [Any],
        let right0 = args0[1] as? [String: Any],
        let args1 = right0[JSON.Keys.args] as? [Any],
        let right1 = args1[1] as? [String: Any],
        let args2 = right1[JSON.Keys.args] as? [Any],
        let left2 = args2[0] as? [String: Any],
        let balanceString = left2[JSON.Keys.int] as? String,
        let balance = Int(balanceString)
      else {
        completion(result.map { _ in 0 })
        return
      }

      completion(.success(balance))
    }
  }

  /// Add liquidity to the exchange.
  ///
  /// - Parameters:
  ///   - source: The address adding the liquidity
  ///   - amount: The amount of liquidity to add.
  ///   - signatureProvider: An opaque object that can sign the operation.
  ///   - minLiquidity: The minimum liquidity the address is willing to accept.
  ///   - maxTokens: The maximum amount of tokens the address is willing to add to the liquidity pool.
  ///   - deadline: A deadline for the transaction to occur by.
  ///   - completion: A completion block which will be called with the result hash, if successful.
  public func addLiquidity(
    from source: Address,
    amount: Tez,
    signatureProvider: SignatureProvider,
    minLiquidity: Int,
    maxTokensDeposited: Int,
    deadline: Date,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let param = LeftMichelsonParameter(
      arg: LeftMichelsonParameter(
        arg: PairMichelsonParameter(
          left: IntMichelsonParameter(int: minLiquidity),
          right: PairMichelsonParameter(
            left: IntMichelsonParameter(int: maxTokensDeposited),
            right: StringMichelsonParameter(date: deadline)
          )
        )
      )
    )

    tezosNodeClient.call(
      contract: exchangeContractAddress,
      amount: amount,
      parameter: param,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

//  // $ ~/alphanet.sh client transfer <tez> from <liquidity-minter> \
//  //  to <exchange-contract-name> \
//  //  --arg 'Left (Left (Pair <min-liquidity-minted> (Pair <max-tokens-deposited> "<deadline>")))' \
//  //  --burn-cap 1
//
//  // Deadline shoudl be a DateTime
//
//  //  $ ~/alphanet.sh client transfer <tez> from <liquidity-remover> to <exchange-contract-name> --arg
//  // 'Left (Right (Pair (Pair <liquidity-burned> <min-mutez-withdrawn>)
  // (Pair <min-token-withdrawn> "<deadline>")))' --burn-cap 1
//  public func removeLiquidity(from source: Address) {
//    let param = LeftMichelsonParameter(
//      arg: RightMichelsonParameter(
//        PairMichelsonParam(
//          left: PairMichelsonParam(
//            left: IntMichelsonParam(int: liquidityBurned)
//            right: IntMichelsonParam(int: minMutezWithdrawn)
//          )
//          right: PairMichelsonParam(
//            left: IntMichelsonParam(int: minTokenWithdrawn),
//            right: StringMichelsonParam(deadline)
//          )
//        )
//      )
//    )
//  }
//
//  // $ ~/alphanet.sh client transfer <tez> from <buyer> to <exchange-contract-name> \
//  //--arg 'Right (Left (Pair <min-tokens-required> "<deadline>"))' \
//  // --burn-cap 1
//  public func tradeTezForToken() {
//    let param = RightMichelsonParameter(
//      arg: LeftMichelsonParameter(
//        arg: PairMichelsonParam(
//          left: IntMichelsonParam(int: minTokensRequired),
//          right: StringMichelsonParam(string: deadline)
//        )
//      )
//    )
//  }
//
//  //  $ ~/alphanet.sh client transfer 0 from <buyer> to <exchange-contract-name> \
//  //  --arg 'Right (Right (Left (Pair <tokens-sold> (Pair <min-tez-required> "<deadline>"))))' \
//  //  --burn-cap 1
//  public func tradeTokenForTez() {
//    let param = RightMichelsonParameter(
//      arg: RightMichelsonParameter(
//        arg: LeftMichelsonParameter(
//          arg: PairMichelsonParam(
//            left: IntMichelsonParam(int: tokensSold),
//            right: PairMichelsonParam(
//              left: IntMichelsonParam(int: minTezRequired),
//              right: StringMichelsonParam(string: deadline)
//            )
//          )
//        )
//      )
//    )
//  }
//

//
}
