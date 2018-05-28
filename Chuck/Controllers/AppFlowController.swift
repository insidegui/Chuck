//
//  AppFlowController.swift
//  Chuck
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit
import ChuckCore

final class AppFlowController: UIViewController {

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

}
