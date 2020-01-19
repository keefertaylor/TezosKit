// Copyright Keefer Taylor, 2019.

/// A client for an  FA1.2 Token Contract.
///
/// - See: https://gitlab.com/tzip/tzip/tree/master/proposals/tzip-7
public class TokenContractClient {
  private enum EntryPoint {
    public static let approve = "approve"
    public static let transfer = "transfer"
  }

  private enum JSON {
    public enum Keys {
      public static let args = "args"
      public static let int = "int"
    }
  }

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
    let parameter = PairMichelsonParameter(
      left: PairMichelsonParameter(
        left: StringMichelsonParameter(string: source),
        right: StringMichelsonParameter(string: destination)
      ),
      right: IntMichelsonParameter(int: numTokens)
    )

    tezosNodeClient.call(
      contract: tokenContractAddress,
      amount: amount,
      entrypoint: EntryPoint.transfer,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  /// Approve an allowance.
  ///
  /// - Parameters:
  ///   - source: The address initiating the approval.
  ///   - spender: The address being approved.
  ///   - allowance: The number of tokens to approve.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - completion: A completion block called with the operation hash or an error.
  public func approveAllowance(
    source: Address,
    spender: Address,
    allowance: Int,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let amount = Tez.zeroBalance
    let parameter = PairMichelsonParameter(
      left: StringMichelsonParameter(string: spender),
      right: IntMichelsonParameter(int: allowance)
    )

    tezosNodeClient.call(
      contract: tokenContractAddress,
      amount: amount,
      entrypoint: EntryPoint.approve,
      parameter: parameter,
      source: source,
      signatureProvider: signatureProvider,
      operationFeePolicy: .estimate,
      completion: completion
    )
  }

  /// Retrieve the token balance for the given address.
  public func getTokenBalance(address: Address, completion: @escaping (Result<Int, TezosKitError>) -> Void) {
    let key = StringMichelsonParameter(string: address)
    tezosNodeClient.getBigMapValue(address: tokenContractAddress, key: key, type: .address) { result in
      guard
        case let .success(json) = result,
        let args = json[JSON.Keys.args] as? [ Any ],
        let second = args[1] as? [String: Any],
        let balanceString = second[JSON.Keys.int] as? String,
        let balance = Int(balanceString)
      else {
        completion(result.map { _ in 0 })
        return
      }

      completion(.success(balance))
    }
  }
}
