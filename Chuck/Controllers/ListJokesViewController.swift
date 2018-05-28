//
//  ListJokesViewController.swift
//  Chuck
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol ListJokesViewControllerDelegate: class {
    func listJokesViewControllerDidSelectSearch(_ controller: ListJokesViewController)
}

final class ListJokesViewController: UIViewController {

    weak var delegate: ListJokesViewControllerDelegate?

    private let disposeBag = DisposeBag()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .largeTitle
        label.text = "Facts"

        return label
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Search"
        button.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        button.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        button.tintColor = .primary

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        installTitleLabel()
        installSearchButton()
    }

    private func installTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.padding).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Metrics.extraPadding).isActive = true
    }

    private func installSearchButton() {
        view.addSubview(searchButton)
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.padding).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }

    @objc private func searchTapped() {
        delegate?.listJokesViewControllerDidSelectSearch(self)
    }

}
