//
//  SearchPresentationDriver.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

final class SearchPresentationDriver: NSObject {

    var isPresentingSearch = false
    private var isDragging = false

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

    private let threshold: CGFloat = 20
    private let limit: CGFloat = 80

}

extension SearchPresentationDriver: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isDragging else {
            return
        }

        let adjustedOffsetY = scrollView.contentOffset.y+scrollView.adjustedContentInset.top

        if !isPresentingSearch && adjustedOffsetY < -threshold {
            isPresentingSearch = true
            presentSearch(interactive: true)
            return
        }

        if isPresentingSearch {
            let progress = max(0.0, min(1.0, ((-adjustedOffsetY) - threshold) / limit))
            searchPresentationTransition.update(progress)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let adjustedOffsetY = scrollView.contentOffset.y+scrollView.adjustedContentInset.top

        let progress = max(0.0, min(1.0, ((-adjustedOffsetY) - threshold) / limit))

        if progress > 0.5 {
            searchPresentationTransition.finish()
        } else {
            searchPresentationTransition.cancel()
        }

        isPresentingSearch = false
        isDragging = false
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
