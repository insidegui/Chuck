//
//  UITestingLabel.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

public enum UITestingLabel: String {
    case jokeCell
    case jokesList
    case loadingIndicator
    case searchButton
    case emptyView
    case searchView
    case searchBar
    case categoryBadge
    case recentSearchBadge
}

extension UIResponder {

    public var uiTestingLabel: UITestingLabel? {
        get {
            guard let label = accessibilityLabel else { return nil }

            return UITestingLabel(rawValue: label)
        }
        set {
            accessibilityLabel = newValue?.rawValue
        }
    }

}
