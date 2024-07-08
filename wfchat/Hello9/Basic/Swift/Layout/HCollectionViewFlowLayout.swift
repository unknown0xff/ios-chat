//
//  HCollectionViewFlowLayout.swift
//
//  Created by Ada on 2024/7/4.
//

import UIKit

public enum HCollectionViewFlowLayoutType {
    case left
    case center
    case right
}

/// 瀑布流layout，只支持横向,只支持用代理进行布局
public class HCollectionViewFlowLayout: UICollectionViewFlowLayout {
    /// 设置对齐方式 默认left
    public var alignType: HCollectionViewFlowLayoutType = .left
    public var delegate: UICollectionViewDelegateFlowLayout? {
        collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }
    
    // 在居中对齐的时候需要知道这行所有cell的宽度总和
    var sumCellWidth: CGFloat = 0
    
    public override func prepare() {
        super.prepare()
        scrollDirection = .vertical
    }
    
    ///整体思路：添加到数组，判断当前元素和前一个后一个元素的Y值，添加到数组中，然后一行一行的算
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes_t = super.layoutAttributesForElements(in: rect)
        
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        layoutAttributes_t?.forEach({ att in
            layoutAttributes.append(att.copy() as! UICollectionViewLayoutAttributes)
        })
        //用来临时存放一行的Cell数组
        var layoutAttributesTemp: [UICollectionViewLayoutAttributes] = []
        
        for (index, _) in layoutAttributes.enumerated() {
            // 当前cell的位置信息
            let currentAttr = layoutAttributes[index]
            // 上一个cell 的位置信息
            let previousAttr = index == 0 ? nil : layoutAttributes[index - 1]
            // 下一个cell 位置信息
            let nextAttr = index + 1 == layoutAttributes.count ? nil : layoutAttributes[index + 1]
            // 加入临时数组
            layoutAttributesTemp.append(currentAttr)
            // 总宽度++
            sumCellWidth += currentAttr.frame.size.width
            
            // 前一个item的Y
            let previousY = previousAttr == nil ? 0 : previousAttr?.frame.maxY
            // 当前item的Y
            let currentY = currentAttr.frame.maxY
            // 下一个item的Y
            let nextY = nextAttr == nil ? 0 : nextAttr?.frame.maxY
            
            //如果当前的y不等于前一个y并且当前的y不等于下一个的Y，说明是单独一行的，并且要过滤掉Header和Footer
            if (currentY != previousY) && (currentY != nextY) {
                if currentAttr.representedElementKind == UICollectionView.elementKindSectionHeader || currentAttr.representedElementKind == UICollectionView.elementKindSectionFooter {
                    layoutAttributesTemp.removeAll()
                    sumCellWidth = 0
                } else {
                    setCellFrameWith(layoutAttributes: &layoutAttributesTemp)
                }
            } else if currentY != nextY {
                //如果下一个cell的Y值和当前的Y值不同，则表示要换行了
                //说明整行结束数组添加完毕，则开始这行的frame的计算
                //如果一样，则什么都不做，等待下一次循环添加，完成后利用整体数组一并计算
                setCellFrameWith(layoutAttributes: &layoutAttributesTemp)
            }
        }
        return layoutAttributes
    }
    
    fileprivate func setCellFrameWith(layoutAttributes: inout [UICollectionViewLayoutAttributes]) {
        guard let firstAttributes = layoutAttributes.first else {
            return
        }
        let minItemSpace = getMinimumInteritemSpacingAtIndex(indexPath: firstAttributes.indexPath)
        var nowWidth: CGFloat = 0
        
        switch alignType {
        case .left:
        //第一个的x为sectionInset.left
            nowWidth = getSectionInsetAtIndex(indexPath: firstAttributes.indexPath).left
        //根据数组中的元素重新计算frame
            for attributes in layoutAttributes {
                var nowFrame = attributes.frame
                nowFrame.origin.x = nowWidth
                attributes.frame = nowFrame
                nowWidth += nowFrame.size.width + minItemSpace
            }
            sumCellWidth = 0
        case .center:
            let totalSpace = CGFloat(layoutAttributes.count - 1) * minItemSpace
            nowWidth = ((collectionView?.frame.size.width ?? 0) - sumCellWidth - totalSpace) / 2
            for attributes in layoutAttributes {
                var nowFrame = attributes.frame
                nowFrame.origin.x = nowWidth
                attributes.frame = nowFrame
                nowWidth += nowFrame.size.width + minItemSpace
            }
            sumCellWidth = 0
        case .right:
            nowWidth = (collectionView?.frame.size.width ?? 0) - getSectionInsetAtIndex(indexPath: firstAttributes.indexPath).right
            for attributes in layoutAttributes.reversed() {
                var nowFrame = attributes.frame
                nowFrame.origin.x = nowWidth - nowFrame.size.width
                attributes.frame = nowFrame
                nowWidth = nowWidth - nowFrame.size.width - minItemSpace
            }
            sumCellWidth = 0
        }
        layoutAttributes.removeAll()
    }
    
    fileprivate func getSectionInsetAtIndex(indexPath: IndexPath) -> UIEdgeInsets {
        if let collectView = collectionView {
            return delegate?.collectionView?(collectView, layout: self, insetForSectionAt: indexPath.section) ?? self.sectionInset
        } else {
            return self.sectionInset
        }
    }
    
    fileprivate func getMinimumInteritemSpacingAtIndex(indexPath: IndexPath) -> CGFloat {
        if let collectView = collectionView {
            return delegate?.collectionView?(collectView, layout: self, minimumInteritemSpacingForSectionAt: indexPath.section) ?? self.minimumInteritemSpacing
        } else {
            return self.minimumInteritemSpacing
        }
    }
}
