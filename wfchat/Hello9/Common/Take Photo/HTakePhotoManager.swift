//
//  HTakePhotoManager.swift
//  Hello9
//
//  Created by Ada on 2024/6/28.
//  Copyright © 2024 Hello9. All rights reserved.
//
//  相册/拍照统一方法
//

import Foundation
import ZLPhotoBrowser

class HTakePhotoManager {
    
    static func showPhotoPicker(
        onlyPhoto: Bool = false,
        maxSelectCount: Int = 1,
        enableEdit: Bool = true,
        completion: @escaping (([UIImage]) -> Void)
    ) {
        
        func showPhotoLibaray() {
            ZLPhotoConfiguration.default().maxSelectCount = maxSelectCount
            ZLPhotoConfiguration.default().allowTakePhotoInLibrary = false
            ZLPhotoConfiguration.default().allowSelectVideo = false
            ZLPhotoConfiguration.default().allowEditImage = enableEdit
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { results, isOriginal in
               completion( results.map { $0.image } )
            }
            if let top = UIViewController.h_top {
                ps.showPhotoLibrary(sender: top)
            }
        }
        
        if onlyPhoto {
            showPhotoLibaray()
            return
        }
        
        let alert = UIAlertController(title: "选择照片", message: "", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        let camara = UIAlertAction(title: "打开 相机", style: .default) {  _ in
            let camera = ZLCustomCamera()
            camera.takeDoneBlock = { image, videoUrl in
                if let image {
                    completion([image])
                } else {
                    completion([])
                }
            }
            UIViewController.h_top?.showDetailViewController(camera, sender: nil)
        }
        let photo = UIAlertAction(title: "打开 相册", style: .default) { _ in
            showPhotoLibaray()
        }
        alert.addAction(camara)
        alert.addAction(photo)
        alert.addAction(cancel)
        
        UIViewController.h_top?.present(alert, animated: true)
    }
}
