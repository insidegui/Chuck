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
    }

    private var listStateDisposeBag = DisposeBag()

    private func bindListState(with observable: Observable<[JokeViewModel]>) {
        listStateDisposeBag = DisposeBag()

        // Maps the current list observable to either an empty list state or a list full of jokes
        let stateObservable = observable.map { jokes -> ListState in
            if jokes.count > 0 {
                return ListState.jokes(jokes)
            } else {
                return ListState.empty
            }
        }

        // Binds the current state observable to the state variable of the flow controller for others to observe
        stateObservable.bind(to: state).disposed(by: listStateDisposeBag)

        // Binds the current state to the list controller or shows the empty/error state if necessary
        state.asObservable().subscribe(onNext: { [weak self] currentState in
            switch currentState {
            case .empty:
                self?.showEmptyState()
            case .jokes(let jokes):
                self?.listJokesController.jokes.value = jokes
            }
        }, onError: { [weak self] error in
            self?.showErrorState(with: error)
        }).disposed(by: listStateDisposeBag)
    }

    // MARK: - States

    private func showErrorState(with error: Error) {

    }

    private func showEmptyState() {

    }

    // MARK: - Actions

    func presentSearch() {

    }

    func shareJoke(with viewModel: JokeViewModel) {
        let activityController = UIActivityViewController(activityItems: [viewModel.url], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }

}

extension AppFlowController: ListJokesViewControllerDelegate {

    func listJokesViewControllerDidSelectSearch(_ controller: ListJokesViewController) {
        presentSearch()
    }

    func listJokesViewController(_ controller: ListJokesViewController, didSelectShareWithViewModel viewModel: JokeViewModel) {
        shareJoke(with: viewModel)
    }

}
