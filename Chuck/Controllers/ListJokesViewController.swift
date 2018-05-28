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
import ChuckCore

private struct JokeSectionModel: AnimatableSectionModelType {

    static let cellIdentifier = "jokeCell"

    var identity: String {
        return "Facts"
    }

    typealias Identity = String
    typealias Item = JokeViewModel

    var items: [JokeViewModel]

    init(original: JokeSectionModel, items: [JokeViewModel]) {
        self = original
        self.items = items
    }

    init(items: [JokeViewModel]) {
        self.items = items
    }

}

protocol ListJokesViewControllerDelegate: class {
    func listJokesViewControllerDidSelectSearch(_ controller: ListJokesViewController)
}

final class ListJokesViewController: UIViewController {

    weak var delegate: ListJokesViewControllerDelegate?

    lazy var jokes = Variable<[JokeViewModel]>([])

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

    private var effectiveHeaderHeight: CGFloat {
        return Metrics.headerHeight + view.safeAreaInsets.top
    }

    private lazy var headerHeightConstraint: NSLayoutConstraint = {
        return headerView.heightAnchor.constraint(equalToConstant: effectiveHeaderHeight)
    }()

    private lazy var headerView: UIVisualEffectView = {
        let header = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))

        header.translatesAutoresizingMaskIntoConstraints = false

        return header
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)

        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.estimatedRowHeight = 172
        table.rowHeight = UITableViewAutomaticDimension
        table.delegate = self

        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        installTableView()
        installHeader()
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

    // MARK: - Header

    private func installHeader() {
        view.addSubview(headerView)
        headerHeightConstraint.isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        headerHeightConstraint.constant = effectiveHeaderHeight
    }

    // MARK: - Table view

    private func installTableView() {
        view.addSubview(tableView)

        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        tableView.contentInset = UIEdgeInsets(top: Metrics.headerHeight, left: 0, bottom: 0, right: 0)

        bindTableView()
    }

    private func bindTableView() {
        tableView.register(JokeTableViewCell.self, forCellReuseIdentifier: JokeSectionModel.cellIdentifier)

        let dataSource = RxTableViewSectionedAnimatedDataSource<JokeSectionModel>(configureCell: { _, tableView, _, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: JokeSectionModel.cellIdentifier) as! JokeTableViewCell

            cell.viewModel = item

            return cell
        })

        let sections = jokes.asObservable().map({ [JokeSectionModel(items: $0)] })
        sections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

}

extension ListJokesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
