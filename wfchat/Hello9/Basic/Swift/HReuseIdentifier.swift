//
//  HReuseIdentifier.swift
//  ios-hello9
//
//  Created by Ada on 5/28/24.
//  Copyright © 2024 ios-hello9. All rights reserved.
//
import UIKit

protocol HReuseIdentifier {
    static var reuseIdentifier: String { get }
}

extension HReuseIdentifier {
    public static var reuseIdentifier: String {
        String(describing: self)
    }
}
