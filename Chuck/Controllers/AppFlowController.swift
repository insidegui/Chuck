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

    private let disposeBag = DisposeBag()

    let syncEngine: SyncEngine

    init(syncEngine: SyncEngine) {
        self.syncEngine = syncEngine

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }

    private lazy var listJokesController = ListJokesViewController()

    private lazy var mainNavigationController: UINavigationController = {
        let controller = UINavigationController(rootViewController: listJokesController)

        controller.isNavigationBarHidden = true

        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        installChild(mainNavigationController)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        syncEngine.syncSearchResults(with: "iphone").subscribe(onError: { error in
            fatalError(error.localizedDescription)
        }).disposed(by: disposeBag)

        syncEngine.fetchSearchResults(with: "iphone").bind(to: listJokesController.jokes).disposed(by: disposeBag)
    }

}
