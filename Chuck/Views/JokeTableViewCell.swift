//
//  JokeTableViewCell.swift
//  Chuck
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import ChuckCore

class JokeTableViewCell: UITableViewCell {

    var didSelectShare: (() -> Void)?

    var viewModel: JokeViewModel? {
        didSet {
            update()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private lazy var shadowView: UIView = {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = Metrics.cardCornerRadius

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 12

        return view
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        return label
    }()

    private lazy var badgeView: BadgeView = {
        let badge = BadgeView()

        badge.translatesAutoresizingMaskIntoConstraints = false

        return badge
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Share"
        button.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)

        return button
    }()

    private func setup() {
        uiTestingLabel = .jokeCell

        clipsToBounds = false
        contentView.clipsToBounds = false

        contentView.addSubview(shadowView)
        shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.padding).isActive = true
        shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.padding).isActive = true
        shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.padding).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.padding).isActive = true

        shadowView.addSubview(bodyLabel)
        shadowView.addSubview(badgeView)
        shadowView.addSubview(shareButton)

        bodyLabel.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: Metrics.padding).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: Metrics.padding).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -Metrics.padding).isActive = true

        badgeView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: Metrics.padding).isActive = true
        badgeView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: -Metrics.padding).isActive = true
        badgeView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: Metrics.padding).isActive = true

        shareButton.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -Metrics.padding).isActive = true
        shareButton.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: -Metrics.padding).isActive = true
    }

    private func update() {
        guard let viewModel = viewModel else { return }

        bodyLabel.font = UIFont.systemFont(ofSize: viewModel.preferredMetrics.fontSize, weight: viewModel.preferredMetrics.fontWeight)
        bodyLabel.text = viewModel.body
        badgeView.title = viewModel.categoryName
    }

    // MARK: - Interaction animation

    private var isFingerDown = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        isFingerDown = true
        contract()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        isFingerDown = false
        expand()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        isFingerDown = false
        expand()
    }

    private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
    }()

    private let animationOptions: UIViewAnimationOptions = [
        .beginFromCurrentState,
        .allowAnimatedContent,
        .allowUserInteraction
    ]

    private func contract() {
        feedbackGenerator.prepare()

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.2, options: animationOptions, animations: {
            self.shadowView.layer.transform = CATransform3DMakeScale(0.92, 0.92, 1)
            self.shareButton.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        }, completion: { _ in
            self.performHapticsAndCallActionIfAppropriate()
        })
    }

    private func expand() {
        UIView.animate(withDuration: 0.7, delay: 0.2, usingSpringWithDamping: 1.3, initialSpringVelocity: 0.9, options: animationOptions, animations: {
            self.shadowView.layer.transform = CATransform3DIdentity
            self.shareButton.layer.transform = CATransform3DIdentity
        }, completion: nil)
    }

    // MARK: - Actions

    private func performHapticsAndCallActionIfAppropriate() {
        guard isFingerDown else { return }

        feedbackGenerator.impactOccurred()
        didSelectShare?()
    }

    @objc private func didTapShareButton() {
        feedbackGenerator.impactOccurred()
        didSelectShare?()
    }

}
