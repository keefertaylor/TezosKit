// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class MichelsonAnnotationTests: XCTestCase {
  func testValidAnnotations() {
    let annotationValue = "tezoskit"
    let validAnnotations = [ "@\(annotationValue)", "%\(annotationValue)", ":\(annotationValue)"]
    for annotation in validAnnotations {
      XCTAssertNotNil(MichelsonAnnotation(annotation: annotation))
    }
  }

  func testInvalidAnnotation() {
    XCTAssertNil(MichelsonAnnotation(annotation: "&nonsense"))
  }
}
