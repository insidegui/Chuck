//
//  SearchSuggestionsViewController.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ChuckCore

protocol SearchSuggestionsViewControllerDelegate: class {
    func searchSuggestionsViewController(_ controller: SearchSuggestionsViewController, didSelectSuggestionWithTerm term: String)
}

class SearchSuggestionsViewController: UIViewController {

    weak var delegate: SearchSuggestionsViewControllerDelegate?

    lazy var categories = Variable<[CategoryViewModel]>([])
    lazy var recents = Variable<[RecentSearchViewModel]>([])

    private lazy var categoriesController: BadgesCollectionViewController = {
        let controller = BadgesCollectionViewController()

        controller.uiTestingLabelForCells = .categoryBadge
        controller.delegate = self

        return controller
    }()

    private lazy var recentsController: BadgesCollectionViewController = {
        let controller = BadgesCollectionViewController()

        controller.uiTestingLabelForCells = .recentSearchBadge
        controller.delegate = self

        return controller
    }()

    private lazy var categoriesLabel: UILabel = {
        let l = UILabel()

        l.font = .info
        l.textColor = .infoText
        l.text = "SUGGESTIONS"

        return l
    }()

    private lazy var categoriesStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoriesLabel, categoriesController.view])

        stack.spacing = Metrics.padding / 2
        stack.axis = .vertical

        return stack
    }()

    private lazy var recentsLabel: UILabel = {
        let l = UILabel()

        l.font = .info
        l.textColor = .infoText
        l.text = "RECENTS"

        return l
    }()

    private lazy var recentsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [recentsLabel, recentsController.view])

        stack.spacing = Metrics.padding / 2
        stack.axis = .vertical

        return stack
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoriesStack, recentsStack])

        stack.spacing = Metrics.extraPadding
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        installUI()
        bindUI()
    }

    private func installUI() {
        addChildViewController(categoriesController)
        addChildViewController(recentsController)

        view.addSubview(mainStack)
        mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainStack.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        categoriesController.didMove(toParentViewController: self)
        recentsController.didMove(toParentViewController: self)
    }

    private let disposeBag = DisposeBag()

    private func bindUI() {
        // Hide categories when there are no categories to show
        categories.asObservable().map({ $0.count == 0 }).bind(to: categoriesStack.rx.isHidden).disposed(by: disposeBag)

        // Hide recent searches when there are no recent searches to show
        recents.asObservable().map({ $0.count == 0 }).bind(to: recentsStack.rx.isHidden).disposed(by: disposeBag)

        categories.asObservable().map({ $0.map { $0.name } }).bind(to: categoriesController.badgeTitles).disposed(by: disposeBag)
        recents.asObservable().map({ $0.map { $0.term } }).bind(to: recentsController.badgeTitles).disposed(by: disposeBag)
    }

}

extension SearchSuggestionsViewController: BadgesCollectionViewControllerDelegate {

    func badgesCollectionViewController(_ controller: BadgesCollectionViewController, didSelectItemWithTitle title: String) {
        delegate?.searchSuggestionsViewController(self, didSelectSuggestionWithTerm: title)
    }

}
