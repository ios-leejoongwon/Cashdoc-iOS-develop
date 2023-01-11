import UIKit

public class Highlighting<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol HighlightingCompatible {
    associatedtype HighlightingCompatibleType
    var highlighting: HighlightingCompatibleType { get }
}

public extension HighlightingCompatible {
    var highlighting: Highlighting<Self> {
        return Highlighting(self)
    }
}

extension UIView: HighlightingCompatible {}
