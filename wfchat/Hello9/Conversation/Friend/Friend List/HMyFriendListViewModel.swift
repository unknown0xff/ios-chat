//
//  HMyFriendListViewModel.swift
//  Hello9
//
//  Created by Ada on 6/17/24.
//  Copyright © 2024 Hello9. All rights reserved.
//

struct HMyFriendListModel: Hashable {
    
    var isSelected: Bool
    var isInGroup: Bool = false
    var enableMutiSelected: Bool = false
    
    var userInfo: HUserInfoModel
    
    init(userInfo: WFCCUserInfo, isSelected: Bool = false) {
        self.isSelected = isSelected
        self.userInfo = .init(info: userInfo)
    }
}

class HMyFriendListViewModel: HBasicViewModel {
    
    @Published private(set) var snapshot = NSDiffableDataSourceSnapshot<HBasicSection, Row>.init()
    
    @Published private(set) var selectedItems = [HMyFriendListModel]()
    
    typealias Row = HMyFriendListModel
    
    var maxSelectedCount: Int = 1
    var enableMutiSelected: Bool { maxSelectedCount > 1 }
    var showSearchBar: Bool = false
    var groupMembers = [String]()
    var forceApplySearchResult: Bool = false
    
    var searchWord: String = "" {
        didSet {
            search()
        }
    }
    
    @Published private(set) var searchFriends = [HMyFriendListModel]()
    @Published private(set) var indexTitles = [String]()
    
    private var friends = [HMyFriendListModel]()
    
    private let userIds: [String]
    init(userIds: [String] = []) {
        self.userIds = userIds
    }
    
    func loadData() {
        let ids: [String]
        if !userIds.isEmpty {
            ids = userIds
        } else {
            ids = WFCCIMService.sharedWFCIM().getMyFriendList(false) ?? []
        }
        let friendsInfo = WFCCIMService.sharedWFCIM().getUserInfos(ids, inGroup: nil) ?? .init()
        friends = friendsInfo.map {
            var model = HMyFriendListModel(userInfo: $0)
            model.enableMutiSelected = self.enableMutiSelected
            model.isInGroup = self.groupMembers.contains($0.userId)
            return model
        }
        
        func compare(_ i1: String, _ i2: String) -> Bool {
            if i1 == "#" && i2 == "#" {
                return true
            }
            if i1 == "#" && i2 != "#" {
                return false
            }
            if i1 != "#" && i2 == "#" {
                return true
            }
            return i1 < i2
        }
        friends.sort {
            let i1 = $0.userInfo.searchIndex
            let i2 = $1.userInfo.searchIndex
            return compare(i1, i2)
        }
        indexTitles = Set(friends.map { $0.userInfo.searchIndex }).map { $0 }
            .sorted(by: compare)
        applySnapshot()
    }
    
    func firstFriendIndexOfTitleIndex(_ titleIndex: Int) -> Int? {
        if titleIndex >= indexTitles.count {
            return nil
        }
        let index = friends.firstIndex { $0.userInfo.searchIndex == indexTitles[titleIndex] }
        return index
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections([.main])
        if !searchFriends.isEmpty && forceApplySearchResult {
            snapshot.appendItems(searchFriends)
        } else {
            snapshot.appendItems(friends)
        }
        
        self.snapshot = snapshot
    }
    
    func selectedItem(item: HMyFriendListModel) {
        let contain = selectedItems.contains(where: { $0.userInfo.userId == item.userInfo.userId })
        if contain { return }
        
        var m = item
        m.isSelected = true
        m.enableMutiSelected = enableMutiSelected
        selectedItems.append(m)
        
        if let index = friends.firstIndex(where: { $0.userInfo.userId == item.userInfo.userId }) {
            friends[index].isSelected = true
        }
        applySnapshot()
    }
    
    func toggleItemSelected(item: HMyFriendListModel) {
        
        let isSelected = item.isSelected
        if isSelected {
            selectedItems.removeAll { $0.userInfo.userId == item.userInfo.userId }
        } else {
            var m = item
            m.isSelected = true
            selectedItems.append(m)
        }
        
        if let index = friends.firstIndex(where: { $0.userInfo.userId == item.userInfo.userId }) {
            friends[index].isSelected.toggle()
        }
        
        if let index = searchFriends.firstIndex(where: { $0.userInfo.userId == item.userInfo.userId }) {
            searchFriends[index].isSelected.toggle()
        }
        
        applySnapshot()
    }
    
    func search() {
        if searchWord.isEmpty {
            searchFriends = []
        } else {
            let result = WFCCIMService.sharedWFCIM().searchFriends(searchWord) ?? .init()
            searchFriends = result.map {
                var model = HMyFriendListModel(userInfo: $0)
                model.enableMutiSelected = forceApplySearchResult && self.enableMutiSelected
                model.isInGroup = self.groupMembers.contains($0.userId)
                return model
            }
        }
        if forceApplySearchResult {
            applySnapshot()
        }
    }
}


class HMyFriendListDataSource: UITableViewDiffableDataSource<HMyFriendListViewModel.Section, HMyFriendListViewModel.Row> {
}
