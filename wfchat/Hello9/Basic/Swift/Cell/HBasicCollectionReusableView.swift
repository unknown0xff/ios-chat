//
//  HBasicCollectionReusableView.swift
//  Hello9
//
//  Created by Ada on 2024/6/27.
//  Copyright © 2024 Hello9. All rights reserved.
//

class HBasicCollectionReusableView<T>: UICollectionReusableView {
    var indexPath: IndexPath!
    
    static var elementKind: String {
        Self.reuseIdentifier
    }
    
    var cellData: T? {
        didSet {
            bindData(cellData)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {  }
    func makeConstraints() { }
    func bindData(_ data: T?) { }
}

struct HSupplementaryRegistration<Supplementary, Item> where Supplementary : HBasicCollectionReusableView<Item> {
    static func Registration(_ item: Item) -> UICollectionView.SupplementaryRegistration<Supplementary> {
        return HSupplementaryRegistration<Supplementary, Item>(item).registration
    }
    
    private var registration: UICollectionView.SupplementaryRegistration<Supplementary>
    private init(_ item: Item) {
        self.registration = UICollectionView.SupplementaryRegistration<Supplementary>
           .init(elementKind: Supplementary.elementKind) { supplementaryView, elementKind, indexPath in
               supplementaryView.indexPath = indexPath
               supplementaryView.cellData = item
           }
    }
}
