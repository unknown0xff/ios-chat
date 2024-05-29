//
//  HBasicViewModel.swift
//  ios-hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//

import Foundation

enum HBasicSection: Hashable {
    case main
}

protocol HBasicViewModel {
    associatedtype Section: Hashable = HBasicSection
    associatedtype Row: Hashable
    
    var snapshot: NSDiffableDataSourceSnapshot<Section,Row> { get }
}

