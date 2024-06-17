//
//  HMyFriendListViewModel.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

struct HMyFriendListModel: Hashable {
    
    var portrait: URL?
    var isSelected: Bool
    var dispalyName: String
    var userId: String
    
    var enableMutiSelected: Bool = false
    
    init(userInfo: WFCCUserInfo, isSelected: Bool = false) {
        self.isSelected = isSelected
        self.portrait = .init(string: userInfo.portrait ?? "")
        self.dispalyName = userInfo.displayName ?? ""
        self.userId = userInfo.userId
    }
}

class HMyFriendListViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    @Published private(set) var selectedItems = [HMyFriendListModel]()
    
    typealias Row = HMyFriendListModel
    
    var maxSelectedCount: Int = 1
    var enableMutiSelected: Bool { maxSelectedCount > 1 }
    
    private var friends = [HMyFriendListModel]()
    
    func loadData() {
        let ids = WFCCIMService.sharedWFCIM().getMyFriendList(false) ?? []
        let friendsInfo = WFCCIMService.sharedWFCIM().getUserInfos(ids, inGroup: nil) ?? .init()
        friends = friendsInfo.map {
            var model = HMyFriendListModel(userInfo: $0)
            model.enableMutiSelected = self.enableMutiSelected
            return model
        }
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(friends)
        
        self.snapshot = snapshot
    }
    
    func toggleItemSelected(item: HMyFriendListModel, at indexPath: IndexPath) {
        
        let isSelected = item.isSelected
        if isSelected {
            selectedItems.removeAll { $0 == item }
        } else {
            var m = item
            m.isSelected = true
            selectedItems.append(m)
        }
        
        if let index = friends.firstIndex(where: { $0.userId == item.userId }) {
            friends[index].isSelected.toggle()
        }
        
        applySnapshot()
    }
    
}


class HMyFriendListDataSource: UITableViewDiffableDataSource<HMyFriendListViewModel.Section, HMyFriendListViewModel.Row> {
}
