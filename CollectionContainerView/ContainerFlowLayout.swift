//
//  ContainerFlowLayout.swift
//  CollectionContainerView
//
//  Created by Mangaraju, Venkata Maruthu Sesha Sai [GCB-OT NE] on 7/29/18.
//  Copyright © 2018 Sai. All rights reserved.
//

import UIKit

final public class ContainerFlowLayout: UICollectionViewFlowLayout {
    
    public var useDefaultFlowLayout = false
    public var numberOfColumns: Int = 1 {
        didSet {
            if numberOfColumns <= 0 {
                numberOfColumns = 1
            }
        }
    }

    fileprivate var totalInteritemSpacing: CGFloat {
        get {
            return CGFloat(numberOfColumns - 1) * minimumInteritemSpacing
        }
    }
    
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
    }
    
    fileprivate func columnWidthAt(columnIndex: Int) -> CGFloat {
        return contentWidth - (sectionInset.left + sectionInset.right + totalInteritemSpacing)
    }
    
    func itemSizeWidth(at indexPath: IndexPath) -> CGFloat {
        let columnIndex = indexPath.row % numberOfColumns
        return columnWidthAt(columnIndex: columnIndex)
    }
    
    // MARK: - Lifecycle overrides
    
    override public var collectionViewContentSize: CGSize {
        guard !useDefaultFlowLayout else { return super.collectionViewContentSize }
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override public func prepare() {
        super.prepare()
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard !useDefaultFlowLayout else { return super.layoutAttributesForElements(in: rect) }

        let attributes = super.layoutAttributesForElements(in: rect)
        var attributesCopy = [UICollectionViewLayoutAttributes]()

        attributes?.forEach {
            var itemAttributes = $0
            if let itemAttributesCopy = $0.copy() as? UICollectionViewLayoutAttributes {
                itemAttributes = itemAttributesCopy
            }
            attributesCopy.append(itemAttributes)
            applyTransform(to: itemAttributes)
            contentHeight = max(contentHeight, itemAttributes.frame.maxY)
        }
        return attributesCopy
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard !useDefaultFlowLayout else { return super.layoutAttributesForItem(at: indexPath) }

        let attribute = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        applyTransform(to: attribute)
        return attribute
    }
    
    // MARK: - Layout transformation
    
    fileprivate func applyTransform(to attribute: UICollectionViewLayoutAttributes?) {
        if let attribute = attribute, !useDefaultFlowLayout {
            let index = attribute.indexPath.row
            let rowIndex = index / numberOfColumns
            
            if rowIndex == 0 {
                attribute.frame.origin.y = 0.0
            }
            else if index - numberOfColumns >= 0 {
                if let previousAttribute = layoutAttributesForItem(at: IndexPath(row: index - numberOfColumns, section: 0)) {
                    attribute.frame.origin.y = previousAttribute.frame.maxY + minimumLineSpacing
                }
            }
        }
    }
}

