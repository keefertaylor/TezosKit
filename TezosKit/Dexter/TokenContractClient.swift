// Copyright Keefer Taylor, 2019.

import Foundation

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
    numTokens: Decimal,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = transferTokensOperation(from: source, to: destination, numTokens: numTokens, operationFeePolicy: operationFeePolicy, signatureProvider: signatureProvider)

    switch result {
      case .success(let op):
        tezosNodeClient.forgeSignPreapplyAndInject(op, source: source, signatureProvider: signatureProvider, completion: completion)
      case .failure(let error):
        completion(Result.failure(error))
    }
  }

  /// Create an operation to transfer tokens.
  ///
  /// - Parameters:
  ///   - source: The address initiating the transfer.
  ///   - destination: The address receiving the tokens.
  ///   - numTokens: The number of tokens to transfer.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - completion: A completion block called with the operation hash or an error.
  public func transferTokensOperation(
    from source: Address,
    to destination: Address,
    numTokens: Decimal,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Result<TezosKit.Operation, TezosKitError> {
    let amount = Tez.zeroBalance
    let parameter = PairMichelsonParameter(
      left: PairMichelsonParameter(
        left: StringMichelsonParameter(string: source),
        right: StringMichelsonParameter(string: destination)
      ),
      right: IntMichelsonParameter(decimal: numTokens)
    )

    return tezosNodeClient.operationFactory.smartContractInvocationOperation(
      amount: amount,
      entrypoint: EntryPoint.transfer,
      parameter: parameter,
      source: source,
      destination: tokenContractAddress,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
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
    allowance: Decimal,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    let result = approveAllowanceOperation(source: source, spender: spender, allowance: allowance, operationFeePolicy: operationFeePolicy, signatureProvider: signatureProvider)

    switch result {
      case .success(let op):
        tezosNodeClient.forgeSignPreapplyAndInject(op, source: source, signatureProvider: signatureProvider, completion: completion)
      case .failure(let error):
        completion(Result.failure(error))
    }
  }

  /// Create an operation to approve an allowance.
  ///
  /// - Parameters:
  ///   - source: The address initiating the approval.
  ///   - spender: The address being approved.
  ///   - allowance: The number of tokens to approve.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - completion: A completion block called with the operation hash or an error.
  public func approveAllowanceOperation(
    source: Address,
    spender: Address,
    allowance: Decimal,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Result<TezosKit.Operation, TezosKitError> {
    let amount = Tez.zeroBalance
    let parameter = PairMichelsonParameter(
      left: StringMichelsonParameter(string: spender),
      right: IntMichelsonParameter(decimal: allowance)
    )

    return tezosNodeClient.operationFactory.smartContractInvocationOperation(
      amount: amount,
      entrypoint: EntryPoint.approve,
      parameter: parameter,
      source: source,
      destination: tokenContractAddress,
      operationFeePolicy: operationFeePolicy,
      signatureProvider: signatureProvider
    )
  }

  /// Create operations to approve an allowance and transfer tokens, so thye can be sent together in one request.
  ///
  /// - Parameters:
  ///   - source: The address initiating the approval.
  ///   - spender: The address being approved.
  ///   - allowance: The number of tokens to approve.
  ///   - signatureProvider: An opaque object that can sign the transaction.
  ///   - completion: A completion block called with the operation hash or an error.
  public func approveAndTransferOperations(
    source: Address,
    spender: Address,
    destination: Address,
    numTokens: Decimal,
    operationFeePolicy: OperationFeePolicy,
    signatureProvider: SignatureProvider
  ) -> Result<[TezosKit.Operation], TezosKitError> {
    let approveOperation = approveAllowanceOperation(source: source, spender: spender, allowance: numTokens, operationFeePolicy: operationFeePolicy, signatureProvider: signatureProvider)
	let transferOperation = transferTokensOperation(from: source, to: destination, numTokens: numTokens, operationFeePolicy: operationFeePolicy, signatureProvider: signatureProvider)

    if case .success(let approveOp) = approveOperation, case .success(let transferOp) = transferOperation {
      return Result.success([approveOp, transferOp])

    } else {
      if case .failure(let error) = approveOperation {
        return Result.failure(error)

      } else if case .failure(let error) = transferOperation {
        return Result.failure(error)
      }
    }

    // Should never reach here
    return Result.failure(TezosKitError(kind: .unknown))
  }

  /// Retrieve the token balance for the given address.
  public func getTokenBalance(address: Address, completion: @escaping (Result<Decimal, TezosKitError>) -> Void) {
    let key = StringMichelsonParameter(string: address)
    tezosNodeClient.getBigMapValue(address: tokenContractAddress, key: key, type: .address) { result in
      guard
        case let .success(json) = result,
        let args = json[JSON.Keys.args] as? [ Any ],
        let second = args[1] as? [String: Any],
        let balanceString = second[JSON.Keys.int] as? String,
        let balance = Decimal(string: balanceString)
      else {
        completion(result.map { _ in 0 })
        return
      }

      completion(.success(balance))
    }
  }
}
