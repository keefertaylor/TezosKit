// Copyright Keefer Taylor, 2018

import XCTest

class PeriodKindResponseAdapterTest: XCTestCase {
  public func testParsePeriodKind() {
    guard let proposalData = "proposal".data(using: .utf8),
    let testingData = "testing".data(using: .utf8),
    let testingVoteData = "testing_vote".data(using: .utf8),
    let promotionVoteData = "promotion_vote".data(using: .utf8),
    let proposal = PeriodKindResponseAdapter.parse(input: proposalData),
    let testing = PeriodKindResponseAdapter.parse(input: testingData),
    let testingVote = PeriodKindResponseAdapter.parse(input: testingVoteData),
      let promotionVote = PeriodKindResponseAdapter.parse(input: promotionVoteData) else {
          XCTFail()
        return
    }

    XCTAssertEqual(proposal, .proposal)
    XCTAssertEqual(testing, .testing)
    XCTAssertEqual(testingVote, .testing_vote)
    XCTAssertEqual(promotionVote, .promotion_vote)
  }
//
//  // Balances are returned as quoted from the API. Make sure that quotes can be stripped when
//  // parsing.
//  public func testParseBalanceWithQuotes() {
//    guard let balance = TezosBalance(balance: "3500000"),
//      let balanceData = ("\"" + balance.rpcRepresentation + "\"").data(using: .utf8),
//      let parsedBalance = TezosBalanceResponseAdapter.parse(input: balanceData) else {
//        XCTFail()
//        return
//    }
//
//    XCTAssertNotNil(parsedBalance)
//    XCTAssertEqual(parsedBalance, balance)
//  }
//
//  // Ensure white space does not mess up parsing.
//  public func testParseBalanceWithWhitespace() {
//    guard let balance = TezosBalance(balance: "3500000"),
//      let balanceData = ("    " + balance.rpcRepresentation + "\n\n\n").data(using: .utf8),
//      let parsedBalance = TezosBalanceResponseAdapter.parse(input: balanceData) else {
//        XCTFail()
//        return
//    }
//
//    XCTAssertNotNil(parsedBalance)
//    XCTAssertEqual(parsedBalance, balance)
//  }
//
//  // Ensure invalid strings cannot be parsed.
//  public func testParseBalanceWithInvalidInput() {
//    let invalidBalanceString = "xyz"
//    guard let invalidBalanceData = invalidBalanceString.data(using: .utf8) else {
//      XCTFail()
//      return
//    }
//    let parsedBalance = TezosBalanceResponseAdapter.parse(input: invalidBalanceData)
//
//    XCTAssertNil(parsedBalance)
//  }
}
