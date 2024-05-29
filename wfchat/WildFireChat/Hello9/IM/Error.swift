//
//  Error.swift
//  WildFireChat
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

import Foundation

struct HError: Error {
    let code: Int32
    let message: String
}
