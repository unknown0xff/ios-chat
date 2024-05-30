//
//  Error.swift
//  hello9
//
//  Created by Ada on 5/29/24.
//  Copyright © 2024 hello9. All rights reserved.
//

import Foundation

struct HError: Error {
    let code: Int32
    let message: String
}
