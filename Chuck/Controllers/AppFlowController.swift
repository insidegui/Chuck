//
//  AppFlowController.swift
//  Chuck
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ChuckCore

final class AppFlowController: UIViewController {

    enum ListState {
        case empty
        case jokes([JokeViewModel])
    }

    lazy var isOffline = Variable<Bool>(false)

    private let disposeBag = DisposeBag()

    let syncEngine: SyncEngine

    init(syncEngine: SyncEngine) {
        self.syncEngine = syncEngine

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }

    private lazy var listJokesController: ListJokesViewController = {
        let controller = ListJokesViewController()

        controller.delegate = self
        controller.scrollingDelegate = searchPresenter

        return controller
    }()

    private lazy var searchController: SearchViewController = {
        let controller = SearchViewController(syncEngine: syncEngine)

        controller.delegate = self

        return controller
    }()

    private lazy var state = Variable<ListState>(.empty)

    private lazy var mainNavigationController: UINavigationController = {
        let controller = UINavigationController(rootViewController: listJokesController)

        controller.isNavigationBarHidden = true

        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        installChild(mainNavigationController)

        // Bind list initally to a selection of random jokes already cached locally
        bindListState(with: syncEngine.fetchRandomJokes(with: 20))

        // Show offline badge when in offline mode
        isOffline.asObservable().map({ !$0 }).bind(to: listJokesController.offlineBadge.rx.isHidden).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchPresenter.isPresentingSearch = false
    }

    private var listStateDisposeBag = DisposeBag()

    private func unbindListState() {
        listStateDisposeBag = DisposeBag()
    }

    private func bindListState(with observable: Observable<[JokeViewModel]>) {
        unbindListState()

        // Maps the current list observable to either an empty list state or a list full of jokes
        let stateObservable = observable.map { jokes -> ListState in
            if jokes.count > 0 {
                return ListState.jokes(jokes)
            } else {
                return ListState.empty
            }
        }.do(onNext: { [weak self] _ in
            self?.listJokesController.isLoading.value = false
        }, onSubscribed: { [weak self] in
            self?.listJokesController.isLoading.value = true
        })

        // Binds the current state observable to the state variable of the flow controller for others to observe
        stateObservable.do(onError: { [weak self] error in
            self?.showErrorState(with: error)
        }).bind(to: state).disposed(by: listStateDisposeBag)

        // Binds the current state to the list controller or shows the empty/error state if necessary
        state.asObservable().subscribe(onNext: { [weak self] currentState in
            switch currentState {
            case .empty:
                self?.showEmptyState(with: Messages.firstLaunchEmtpy, actionTitle: "SEARCH FACTS")
            case .jokes(let jokes):
                self?.hideEmptyState()
                self?.listJokesController.jokes.value = jokes
            }
        }, onError: { [weak self] error in
            self?.showErrorState(with: error)
        }).disposed(by: listStateDisposeBag)
    }

    // MARK: - States

    private func showErrorState(with error: Error) {
        listJokesController.isLoading.value = false
        hideEmptyState()
    }

    private lazy var emptyViewController: EmptyViewController = {
        let controller = EmptyViewController()

        controller.delegate = self

        return controller
    }()

    private func showEmptyState(with message: String, actionTitle: String) {
        guard listJokesController.isLoading.value == false else { return }

        if emptyViewController.view.superview == nil {
            addChildViewController(emptyViewController)
            emptyViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyViewController.view)

            emptyViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            emptyViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            emptyViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

            emptyViewController.didMove(toParentViewController: self)
        }

        emptyViewController.message = message
        emptyViewController.actionTitle = actionTitle

        emptyViewController.view.isHidden = false
        listJokesController.jokes.value = []
    }

    private func hideEmptyState() {
        emptyViewController.view.isHidden = true
    }

    // MARK: - Actions

    func shareJoke(with viewModel: JokeViewModel) {
        let activityController = UIActivityViewController(activityItems: [viewModel.url], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }

    func fetchRandomJoke() {
        prepareNotificationHaptic()

        let randomJokeObservable = syncEngine.randomJoke().map({[$0]}).do(onNext: { [weak self] _ in
            self?.performSuccessHaptic()
        })

        bindListState(with: randomJokeObservable)
    }

    func fetchSearchResults(with term: String) {
        unbindListState()
        hideEmptyState()

        listJokesController.isLoading.value = true

        syncEngine.syncSearchResults(with: term).subscribe { [weak self] event in
            switch event {
            case .completed:
                self?.showEmptySearchResultsStateIfNeeded()
            default:
                break
            }
            self?.listJokesController.isLoading.value = false
        }.disposed(by: listStateDisposeBag)

        syncEngine.fetchSearchResults(with: term).do(onNext: { [weak self] _ in
            self?.showEmptySearchResultsStateIfNeeded()
        }).bind(to: listJokesController.jokes).disposed(by: listStateDisposeBag)
    }

    private func showEmptySearchResultsStateIfNeeded() {
        if listJokesController.jokes.value.count > 0 {
            hideEmptyState()
        } else {
            let message = isOffline.value ? Messages.searchResultsEmtpyOffline : Messages.searchResultsEmtpy
            showEmptyState(with: message, actionTitle: "")
        }
    }

    // MARK: - Interaction

    private lazy var impactGenerator: UIImpactFeedbackGenerator = {
        return UIImpactFeedbackGenerator(style: .medium)
    }()

    private lazy var notificationGenerator = UINotificationFeedbackGenerator()

    private func prepareNotificationHaptic() {
        notificationGenerator.prepare()
    }

    private func performSuccessHaptic() {
        notificationGenerator.notificationOccurred(.success)
    }

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            super.motionBegan(motion, with: event)
            return
        }

        impactGenerator.prepare()
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            super.motionEnded(motion, with: event)
            return
        }

        impactGenerator.impactOccurred()
        fetchRandomJoke()
    }

    // MARK: - Search Presentation

    private lazy var searchPresenter: SearchPresentationDriver = {
        return SearchPresentationDriver(searchController: searchController, presenter: self)
    }()

}

extension AppFlowController: ListJokesViewControllerDelegate {

    func listJokesViewControllerDidSelectSearch(_ controller: ListJokesViewController) {
        searchPresenter.presentSearch()
    }

    func listJokesViewController(_ controller: ListJokesViewController, didSelectShareWithViewModel viewModel: JokeViewModel) {
        shareJoke(with: viewModel)
    }

}

extension AppFlowController: EmptyViewControllerDelegate {

    func emptyViewControllerDidSelectSearch(_ controller: EmptyViewController) {
        searchPresenter.presentSearch()
    }

}

extension AppFlowController: SearchViewControllerDelegate {

    func searchViewControllerWantsToBeDismissed(_ controller: SearchViewController) {
        dismiss(animated: true, completion: nil)
    }

    func searchViewController(_ controller: SearchViewController, didSearchForTerm term: String) {
        dismiss(animated: true, completion: nil)
        fetchSearchResults(with: term)
    }

}
