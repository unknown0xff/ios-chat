
import UIKit

public typealias UICollectionViewWaterfallLayoutItemSizeProvider = (IndexPath) -> CGSize

public struct UICollectionLayoutWaterfallConfiguration {
    
    public var columnCount: Int
    
    public var spacing: CGFloat
    
    public var contentInsetsReference: UIContentInsetsReference
    
    public var itemSizeProvider: UICollectionViewWaterfallLayoutItemSizeProvider
        
    public init(
        columnCount: Int = 2,
        spacing: CGFloat = 8,
        contentInsetsReference: UIContentInsetsReference = .automatic,
        itemSizeProvider: @escaping UICollectionViewWaterfallLayoutItemSizeProvider
    ) {
        self.columnCount = columnCount
        self.spacing = spacing
        self.contentInsetsReference = contentInsetsReference
        self.itemSizeProvider = itemSizeProvider
    }
}


public extension UICollectionViewCompositionalLayout {
    
    static func waterfall(
        columnCount: Int = 2,
        spacing: CGFloat = 8,
        contentInsetsReference: UIContentInsetsReference = .automatic,
        itemSizeProvider: @escaping UICollectionViewWaterfallLayoutItemSizeProvider
    ) -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionLayoutWaterfallConfiguration(
            columnCount: columnCount,
            spacing: spacing,
            contentInsetsReference: contentInsetsReference,
            itemSizeProvider: itemSizeProvider
        )
        return waterfall(configuration: configuration)
    }
    
    static func waterfall(configuration: UICollectionLayoutWaterfallConfiguration) -> UICollectionViewCompositionalLayout {
        
        var numberOfItems: (Int) -> Int = { _ in 0 }
        
        let layout = UICollectionViewCompositionalLayout { section, environment in
            
            let groupLayoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(environment.container.effectiveContentSize.height)
            )
            
            let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { environment in
                let itemProvider = LayoutItemProvider(configuration: configuration, environment: environment)
                var items = [NSCollectionLayoutGroupCustomItem]()
                for i in 0..<numberOfItems(section) {
                    let indexPath = IndexPath(item: i, section: section)
                    let item = itemProvider.item(for: indexPath)
                    items.append(item)
                }
                return items
            }
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsetsReference = configuration.contentInsetsReference
            return section
        }
        
        numberOfItems = { [weak layout] in
            layout?.collectionView?.numberOfItems(inSection: $0) ?? 0
        }
        
        return layout
    }
}

class LayoutItemProvider {
    
    private var columnHeights: [CGFloat]
    
    private let columnCount: CGFloat
    
    private let itemSizeProvider: UICollectionViewWaterfallLayoutItemSizeProvider
    
    private let spacing: CGFloat
    
    private let contentSize: CGSize
    
    init(
        configuration: UICollectionLayoutWaterfallConfiguration,
        environment: NSCollectionLayoutEnvironment
    ) {
        self.columnHeights = [CGFloat](repeating: 0, count: configuration.columnCount)
        self.columnCount = CGFloat(configuration.columnCount)
        self.itemSizeProvider = configuration.itemSizeProvider
        self.spacing = configuration.spacing
        self.contentSize = environment.container.effectiveContentSize
    }
    
    func item(for indexPath: IndexPath) -> NSCollectionLayoutGroupCustomItem {
        let frame = frame(for: indexPath)
        columnHeights[columnIndex()] = frame.maxY + spacing
        return NSCollectionLayoutGroupCustomItem(frame: frame)
    }
    
    private func frame(for indexPath: IndexPath) -> CGRect {
        let size = itemSize(for: indexPath)
        let origin = itemOrigin(width: size.width)
        return CGRect(origin: origin, size: size)
    }
    
    private func itemOrigin(width: CGFloat) -> CGPoint {
        let y = columnHeights[columnIndex()].rounded()
        let x = (width + spacing) * CGFloat(columnIndex())
        return CGPoint(x: x, y: y)
    }
    
    private func itemSize(for indexPath: IndexPath) -> CGSize {
        let width = itemWidth()
        let height = itemHeight(for: indexPath, itemWidth: width)
        return CGSize(width: width, height: height)
    }
    
    private func itemWidth() -> CGFloat {
        let spacing = (columnCount - 1) * spacing
        return (contentSize.width - spacing) / columnCount
    }
    
    private func itemHeight(for indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        let itemSize = itemSizeProvider(indexPath)
        let aspectRatio = itemSize.height / itemSize.width
        let itemHeight = itemWidth * aspectRatio
        return itemHeight.rounded()
    }
    
    private func columnIndex() -> Int {
        columnHeights
            .enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}
