//
//  UIViewController+Children.swift
//  Chuck
//
//  Created by Guilherme Rambo on 22/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

extension UIViewController {

    func installChild(_ viewController: UIViewController,
                      withMask autoresizingMask: UIViewAutoresizing = [.flexibleWidth, .flexibleHeight])
    {
        addChildViewController(viewController)
        viewController.view.autoresizingMask = autoresizingMask
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }

}
