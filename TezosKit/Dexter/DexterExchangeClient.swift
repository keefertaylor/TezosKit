// Copyright Keefer Taylor, 2019.

import Foundation

/// A client for a DEXter exchange.
/// - See: https://gitlab.com/camlcase-dev/dexter
public class DexterExchangeClient {
  /// JSON keys for network requests.
  private enum JSON {
    public enum Keys {
      public static let args = "args"
      public static let int = "int"
    }
  }

  /// Entrypoints for smart contracts
  private enum EntryPoint {
    public static let addLiquidity = "addLiquidity"
    public static let removeLiquidity = "removeLiquidity"
    public static let tokenToXTZ = "tokenToXtz"
    public static let xtzToToken = "xtzToToken"
  }

  /// An underlying gateway to the Tezos Network.
  private let tezosNodeClient: TezosNodeClient

  /// The address of a DEXter exchange contract.
  private let exchangeContractAddress: Address

  // MARK: - Balance Queries

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
        let right1 = args1[0] as? [String: Any],
        let args2 = right1[JSON.Keys.args] as? [Any],
        let left2 = args2[1] as? [String: Any],
        let args3 = left2[JSON.Keys.args] as? [Any],
        let right2 = args3[1] as? [String: Any],
        let balanceString = right2[JSON.Keys.int] as? String,
        let balance = Int(balanceString)
      else {
        completion(result.map { _ in 0 })
        return
      }

      completion(.success(balance))
    }
  }

  // MARK: - Liquidity Management

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
    let parameter = PairMichelsonParameter(
      left: PairMichelsonParameter(
        left: StringMichelsonParameter(string: source),
        right: IntMichelsonParameter(int: minLiquidity)
      ),
      right: PairMichelsonParameter(
        left: IntMichelsonParameter(int: maxTokensDeposited),
        right: StringMichelsonParameter(date: deadline)
      )
    )

    tezosNodeClient.call(
      contract: exchangeContractAddress,
      amount: amount,
      entrypoint: EntryPoint.addLiquidity,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  /// Withdraw liquidity from the exchange.
  ///
  /// - Parameters:
  ///   - source: The address withdrawing the liquidity
  ///   - destination: The location to withdraw the liquidity to.
  ///   - signatureProvider: An opaque object that can sign the operation.
  ///   - liquidityBurned: The amount of liquidity to remove from the exchange.
  ///   - tezToWithdraw: The amount of Tez to withdraw from the exchange.
  ///   - minTokensToWithdraw: The minimum number of tokens to withdraw.
  ///   - deadline: A deadline for the transaction to occur by.
  ///   - completion: A completion block which will be called with the result hash, if successful.
  public func removeLiquidity(
    from source: Address,
    destination: Address,
    signatureProvider: SignatureProvider,
    liquidityBurned: Int,
    tezToWidthdraw: Tez,
    minTokensToWithdraw: Int,
    deadline: Date,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    guard let mutezToWithdraw = Int(tezToWidthdraw.rpcRepresentation) else {
      completion(.failure(TezosKitError(kind: .unknown)))
      return
    }

    let parameter = PairMichelsonParameter(
      left: PairMichelsonParameter(
        left: PairMichelsonParameter(
          left: StringMichelsonParameter(string: source),
          right: StringMichelsonParameter(string: destination)
        ),
        right: PairMichelsonParameter(
          left: IntMichelsonParameter(int: liquidityBurned),
          right: IntMichelsonParameter(int: mutezToWithdraw)
        )
      ),
      right: PairMichelsonParameter(
        left: IntMichelsonParameter(int: minTokensToWithdraw),
        right: StringMichelsonParameter(date: deadline)
      )
    )

    tezosNodeClient.call(
      contract: exchangeContractAddress,
      amount: Tez.zeroBalance,
      entrypoint: EntryPoint.removeLiquidity,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  // MARK: - Trades

  /// Buy tokens with Tez.
  ///
  /// - Parameters:
  ///   - source: The address making the trade.
  ///   - amount: The amount of Tez to sell.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - minTokensToPurchase: The minimum number of tokens to purchase.
  ///   - deadline: A deadline for the transaction to occur by.
  ///   - completion: A completion block which will be called with the result hash, if successful.
  public func tradeTezForToken(
    source: Address,
    amount: Tez,
    signatureProvider: SignatureProvider,
    minTokensToPurchase: Int,
    deadline: Date,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let parameter = PairMichelsonParameter(
      left: PairMichelsonParameter(
        left: StringMichelsonParameter(string: source),
        right: IntMichelsonParameter(int: minTokensToPurchase)
      ),
      right: StringMichelsonParameter(date: deadline)
    )

    tezosNodeClient.call(
      contract: exchangeContractAddress,
      amount: amount,
      entrypoint: EntryPoint.xtzToToken,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  /// Buy Tez with tokens.
  ///
  /// - Parameters:
  ///   - source: The address making the trade.
  ///   - destination: The destination for the tokens.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - tokensToSell: The number of tokens to sell.
  ///   - minTezToBuy: The minimum number of Tez to buy.
  ///   - deadline: A deadline for the transaction to occur by.
  ///   - completion: A completion block which will be called with the result hash, if successful.
  public func tradeTokenForTez(
    source: Address,
    destination: Address,
    signatureProvider: SignatureProvider,
    tokensToSell: Int,
    minTezToBuy: Tez,
    deadline: Date,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    guard let minMutezToBuy = Int(minTezToBuy.rpcRepresentation) else {
      completion(.failure(TezosKitError(kind: .unknown)))
      return
    }

    let parameter = PairMichelsonParameter(
      left: PairMichelsonParameter(
        left: PairMichelsonParameter(
          left: StringMichelsonParameter(string: source),
          right: StringMichelsonParameter(string: destination)
        ),
        right: PairMichelsonParameter(
          left: IntMichelsonParameter(int: tokensToSell),
          right: IntMichelsonParameter(int: minMutezToBuy)
        )
      ),
      right: StringMichelsonParameter(date: deadline)
    )

    tezosNodeClient.call(
      contract: exchangeContractAddress,
      entrypoint: EntryPoint.tokenToXTZ,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }
}
