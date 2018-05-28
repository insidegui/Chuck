//
//  EmptyViewController.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

protocol EmptyViewControllerDelegate: class {
    func emptyViewControllerDidSelectSearch(_ controller: EmptyViewController)
}

class EmptyViewController: UIViewController {

    weak var delegate: EmptyViewControllerDelegate?

    var message: String? {
        get {
            return infoLabel.text
        }
        set {
            infoLabel.text = newValue
        }
    }

    var actionTitle: String? {
        get {
            return actionButton.title(for: .normal)
        }
        set {
            let shouldHide = newValue == nil || newValue?.count == 0
            actionButton.isHidden = shouldHide

            actionButton.setTitle(newValue, for: .normal)
        }
    }

    private lazy var infoLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .info
        label.textColor = .infoText

        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)

        button.widthAnchor.constraint(equalToConstant: Metrics.largeButtonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metrics.largeButtonHeight).isActive = true
        button.backgroundColor = .buttonBackground
        button.setTitleColor(.buttonText, for: .normal)
        button.titleLabel?.font = .largeButton
        button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        button.layer.cornerRadius = Metrics.buttonCornerRadius

        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoLabel, actionButton])

        stack.spacing = Metrics.extraPadding
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = .clear

        view.uiTestingLabel = .emptyView

        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.extraPadding).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.extraPadding).isActive = true
    }

    @objc private func searchTapped() {
        delegate?.emptyViewControllerDidSelectSearch(self)
    }

}
