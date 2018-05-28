//
//  BadgeCollectionViewCell.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class BadgeCollectionViewCell: UICollectionViewCell {

    var title: String? {
        get {
            return badgeView.title
        }
        set {
            badgeView.title = newValue
        }
    }

    private lazy var badgeView: BadgeView = {
        let badge = BadgeView()

        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = .vibrantBadgeBackground

        return badge
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        contentView.addSubview(badgeView)
        badgeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        badgeView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        badgeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    override var intrinsicContentSize: CGSize {
        return badgeView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }

}
