// Copyright Keefer Taylor, 2018

import TezosKit
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

  // Ensure quotes are stripped properly
  public func testParsePeriodKindWithQuotes() {
    guard let proposalData = "\"proposal\"".data(using: .utf8),
      let proposal = PeriodKindResponseAdapter.parse(input: proposalData) else {
      XCTFail()
      return
    }
    XCTAssertEqual(proposal, .proposal)
  }

  // Ensure whitespace are stripped properly
  public func testParsePeriodKindWithWhitespace() {
    guard let proposalData = "\nproposal   ".data(using: .utf8),
      let proposal = PeriodKindResponseAdapter.parse(input: proposalData) else {
      XCTFail()
      return
    }
    XCTAssertEqual(proposal, .proposal)
  }

  // Ensure invalid strings cannot be parsed.
  public func testParsPeriodKindWithInvalidInput() {
    guard let invalidData = "not_valid".data(using: .utf8) else {
      XCTFail()
      return
    }

    let proposal = PeriodKindResponseAdapter.parse(input: invalidData)
    XCTAssertNil(proposal)
  }
}
