//
//  SearchPresentationDriver.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

final class SearchPresentationDriver: NSObject {

    private var isPresentingSearch = false

    weak var presenter: UIViewController?
    let searchController: SearchViewController

    init(searchController: SearchViewController, presenter: UIViewController) {
        self.presenter = presenter
        self.searchController = searchController

        super.init()
    }

    private lazy var searchPresentationTransition: SearchTransition = {
        let transition = SearchTransition()

        transition.auxAnimations = { [weak self] in
            self?.searchController.configureWithPresentedState()
        }

        return transition
    }()

    private lazy var searchDismissalTransition: SearchTransition = {
        let transition = SearchTransition()

        transition.isDismissing = true

        transition.auxAnimations = { [weak self] in
            self?.searchController.configureWithDismissedState()
        }

        return transition
    }()

    func presentSearch(interactive: Bool = false) {
        searchController.configureWithDismissedState()

        isPresentingSearch = true

        searchController.transitioningDelegate = self
        searchPresentationTransition.wantsInteractiveStart = interactive

        presenter?.present(searchController, animated: true, completion: nil)
    }

}

extension SearchPresentationDriver: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is SearchViewController else { return nil }

        return searchPresentationTransition
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return searchPresentationTransition
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed is SearchViewController else { return nil }

        return searchDismissalTransition
    }

}
