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

    private lazy var infoLabel: UILabel = {
        let label = UILabel()

        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .info
        label.textColor = .infoText
        label.text = """
                     It looks like you haven't seen any
                     facts yet, which is unfortunate.

                     Start by searching for some! If you just want to see a random fact, shake your device.
                     """

        return label
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)

        button.widthAnchor.constraint(equalToConstant: Metrics.largeButtonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metrics.largeButtonHeight).isActive = true
        button.setTitle("SEARCH FACTS", for: .normal)
        button.backgroundColor = .buttonBackground
        button.setTitleColor(.buttonText, for: .normal)
        button.titleLabel?.font = .largeButton
        button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        button.layer.cornerRadius = Metrics.buttonCornerRadius

        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [infoLabel, searchButton])

        stack.spacing = Metrics.extraPadding
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.uiTestingLabel = .emptyView

        view.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.extraPadding).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.extraPadding).isActive = true
    }

    @objc private func searchTapped() {
        delegate?.emptyViewControllerDidSelectSearch(self)
    }

}
