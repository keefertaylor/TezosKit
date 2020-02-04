// Copyright Keefer Taylor, 2020.

import UIKit

class BackgroundHighlightedButton: UIButton {
  @IBInspectable var highlightedBackgroundColor: UIColor?
  @IBInspectable var nonHighlightedBackgroundColor: UIColor?
  override var isHighlighted: Bool {
    get {
      return super.isHighlighted
    }
    set {
      if newValue {
        self.backgroundColor = .blue
      } else {
        self.backgroundColor = .gray
      }
      super.isHighlighted = isHighlighted
    }
  }
}
