//
//  UITextField+Combine.swift
//  Hello9
//
//  Created by Ada on 2024/6/26.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Combine

extension UITextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
