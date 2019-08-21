// Copyright Keefer Taylor, 2019.

/// A client for a token contract.
///
/// - See: https://gitlab.com/camlcase-dev/dexter
public class TokenContractClient {
  /// An underlying gateway to the Tezos Network.
  private let tezosNodeClient: TezosNodeClient

  /// The address of a token contract.
  private let tokenContractAddress: Address

  /// Initialize a new token contract client.
  ///
  /// - Parameters:
  ///   - tokenContractAddress: The address of the token contract.
  ///   - tezosNodeClient: A TezosNodeClient which will make requests to the Tezos Network. Defaults to the default
  ///     client.
  public init(
    tokenContractAddress: Address,
    tezosNodeClient: TezosNodeClient = TezosNodeClient()
    ) {
    self.tezosNodeClient = tezosNodeClient
    self.tokenContractAddress = tokenContractAddress
  }

  // MARK: - Token Contract

  /// Transfer tokens.
  ///
  /// - Parameters:
  ///   - source: The address initiating the transfer.
  ///   - destination: The address receiving the tokens.
  ///   - numTokens: The number of tokens to transfer.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - completion: A completion block called with the operation hash or an error.
  public func transferTokens(
    from source: Address,
    to destination: Address,
    numTokens: Int,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let amount = Tez.zeroBalance
    let michelsonParameter = LeftMichelsonParameter(
      arg: PairMichelsonParameter(
        left: StringMichelsonParameter(string: source),
        right: PairMichelsonParameter(
          left: StringMichelsonParameter(string: destination),
          right: IntMichelsonParameter(int: numTokens)
        )
      )
    )

    tezosNodeClient.call(
      contract: tokenContractAddress,
      amount: amount,
      parameter: michelsonParameter,
      source: source,
      signatureProvider: signatureProvider,
      completion: completion
    )
  }

  //$ ~/alphanet.sh client get big map value for '"<account-address>"'  of type 'address' in <token-contract-name>
  public func getTokenBalance(address: Address, completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let key = StringMichelsonParameter(string: address)
    tezosNodeClient.getBigMapValue(address: tokenContractAddress, key: key, type: .address) { result in
      print(result)
    }
  }
}
