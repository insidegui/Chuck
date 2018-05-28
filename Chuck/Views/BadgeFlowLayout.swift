//
//  BadgeFlowLayout.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

final class BadgeFlowLayout: UICollectionViewFlowLayout {

    var didInvalidateLayout: ((CGSize) -> Void)?

    override func invalidateLayout() {
        super.invalidateLayout()

        guard collectionViewContentSize.height > 0 else { return }

        noteLayoutInvalidation()
    }

    private func noteLayoutInvalidation() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(doNoteLayoutInvalidation), object: nil)
        perform(#selector(doNoteLayoutInvalidation), with: nil, afterDelay: 0)
    }

    @objc private func doNoteLayoutInvalidation() {
        didInvalidateLayout?(collectionViewContentSize)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }

}
