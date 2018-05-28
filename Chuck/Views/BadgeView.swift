//
//  BadgeView.swift
//  Chuck
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class BadgeView: UIView {

    enum Style: Int {
        case small
        case regular
    }

    var style: Style = .regular {
        didSet {
            guard style != oldValue else { return }

            updateStyle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .badge
        label.textColor = .badgeText
        label.textAlignment = .center

        return label
    }()

    private func setup() {
        backgroundColor = .badgeBackground

        addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.padding/2).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.padding/2).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        layer.cornerRadius = Metrics.badgeCornerRadius
    }

    private var heightForCurrentStyle: CGFloat {
        switch style {
        case .regular:
            return Metrics.badgeHeight
        case .small:
            return Metrics.smallBadgeHeight
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: heightForCurrentStyle)
    }

    private func updateStyle() {
        titleLabel.font = style == .regular ? .badge : .smallBadge

        invalidateIntrinsicContentSize()
    }

}
