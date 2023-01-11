import UIKit

extension UICollectionReusableView: Reusable {}

// MARK: - CollectionViewCell

struct CollectionViewCell<Cell: Reusable> {

  // MARK: Lifecycle

  init(identifier: String? = nil) {
    self.identifier = identifier ?? UUID().uuidString
  }

  // MARK: Public

  public typealias Class = Cell

  public let identifier: String
}

extension UICollectionView {
    
    func register<Cell>(_ cell: CollectionViewCell<Cell>) {
        register(Cell.self, forCellWithReuseIdentifier: cell.identifier)
    }
    
    final func register<T: UICollectionViewCell>(cellType: T.Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    final func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        let bareCell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellType.reuseIdentifier) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
    
    final func register<T: UICollectionReusableView>(supplementaryViewType: T.Type, ofKind elementKind: String) {
        register(supplementaryViewType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: supplementaryViewType.reuseIdentifier)
    }
    
    final func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath, viewType: T.Type = T.self) -> T {
        let view = self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath)
        guard let typedView = view as? T else {
            fatalError(
                "Failed to dequeue a supplementary view with identifier \(viewType.reuseIdentifier) "
                    + "matching type \(viewType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the supplementary view beforehand"
            )
        }
        return typedView
    }
    
    func dequeue<Cell>(_ cell: CollectionViewCell<Cell>, for indexPath: IndexPath) -> Cell {
      // swiftlint:disable:next force_cast
      self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! Cell
    }
}
