//
//  HNodeSpecialNumberListViewModel.swift
//  Hello9
//
//  Created by Ada on 2024/7/3.
//  Copyright © 2024 Hello9. All rights reserved.
//


class HNodeSpecialNumberListViewModel: HBaseViewModel {
    
    typealias Row = HNodeSpecialNumberListModel
    
    enum ItemType: Int {
        case selfCollected
        case exclusive // 专属
        case exchanged // 已经兑换
    }
    
    @Published 
    private(set) var dataSource = (snapshot: NSDiffableDataSourceSnapshot<HBasicSection, Row>(), animated: false)
    
    let type: ItemType
    init(type: ItemType) {
        self.type = type
    }
    
    func loadData() {
        applySnapshot()
    }
    
    func applySnapshot(animated: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        
        let data = (1...30).map { _ in
            var item = Row()
            item.isExclusive = self.type == .exclusive ? true : Bool.random()
            item.isCollected = Bool.random()
            item.showCompetitor = self.type == .selfCollected
            item.showCollected = self.type == .selfCollected
            return item
        }
        
        snapshot.appendItems(data)
        
        dataSource = (snapshot, animated)
    }
}


