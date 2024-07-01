//
//  HNodeHomeViewModel.swift
//  Hello9
//
//  Created by Ada on 2024/7/1.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Combine

class HNodeHomeViewModel: HBaseViewModel {
    
    @Published private(set) var dataSource: (snapshot: NSDiffableDataSourceSnapshot<Section, Row>, animated: Bool)
     = (Snapshot(), false)
    
    enum Row: Hashable {
        case specialHeader
        case specialNumber(_ model: HNodeSpecialNumberListModel)
        case specialFooter
        
        case rankHead
        case rankListItem(_ model: HNodeRankListItem)
        
        case sourceSet
    }
    
    enum Section: Int {
        case specialNumber
        case rankHead
        case rankList
        case sourceSet
    }
    
    func loadData() {
        applySnapshot()
    }
    
    func applySnapshot(animated: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.specialNumber, .rankHead, .rankList, .sourceSet])
        
        snapshot.appendItems([
            .specialHeader,
            .specialNumber(.init()),
            .specialNumber(.init()),
            .specialFooter
        ], toSection: .specialNumber)
        
        snapshot.appendItems([.rankHead], toSection: .rankHead)
        
        snapshot.appendItems([
            .rankListItem(.init()),
            .rankListItem(.init()),
            .rankListItem(.init())
        ], toSection: .rankList)
        
        snapshot.appendItems([.sourceSet], toSection: .sourceSet)
        
        dataSource = (snapshot, animated)
    }
}
