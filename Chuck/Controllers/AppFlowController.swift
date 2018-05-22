//
//  AppFlowController.swift
//  Chuck
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

final class AppFlowController: UIViewController {

    private lazy var listJokesController = ListJokesViewController()

    private lazy var mainNavigationController: UINavigationController = {
        return UINavigationController(rootViewController: listJokesController)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        installChild(mainNavigationController)
    }

}
