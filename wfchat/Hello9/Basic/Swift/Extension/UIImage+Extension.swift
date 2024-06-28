//
//  UIImage+Extension.swift
//  Hello9
//
//  Created by Ada on 2024/6/22.
//  Copyright © 2024 Hello9. All rights reserved.
//

import Foundation

extension UIImage {
    
    class func image(withColor color: UIColor?, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.setFillColor((color ?? .clear).cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        
        UIGraphicsBeginImageContext(gradient.bounds.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func generateQRCode(from string: String, size: CGSize) -> UIImage? {
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // 设置纠错级别
        guard let qrCodeImage = filter.outputImage else { return nil }
        
        let scaleX = size.width / qrCodeImage.extent.size.width
        let scaleY = size.height / qrCodeImage.extent.size.height
        let transformedImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        return UIImage(ciImage: transformedImage)
    }
}
