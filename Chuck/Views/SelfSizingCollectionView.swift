//
//  SelfSizingCollectionView.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

final class SelfSizingCollectionView: UICollectionView {

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        startObservingContentSizeIfNeeded()
    }

    private func startObservingContentSizeIfNeeded() {
        guard superview != nil else { return }
        guard let badgeLayout = collectionViewLayout as? BadgeFlowLayout else { return }

        badgeLayout.didInvalidateLayout = { [weak self] _ in
            self?.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: collectionViewLayout.collectionViewContentSize.height)
    }

}
