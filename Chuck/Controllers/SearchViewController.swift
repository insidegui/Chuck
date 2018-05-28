//
//  SearchViewController.swift
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

protocol SearchViewControllerDelegate: class {
    func searchViewControllerWantsToBeDismissed(_ controller: SearchViewController)
}

final class SearchViewController: UIViewController {

    weak var delegate: SearchViewControllerDelegate?

    lazy var suggestedCategories = Variable<[CategoryViewModel]>([])
    lazy var recentSearches = Variable<[RecentSearchViewModel]>([])

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
        modalPresentationCapturesStatusBarAppearance = true
    }

    private lazy var blurEffect = UIBlurEffect(style: .dark)

    private lazy var backgroundView: UIVisualEffectView = {
        let background = UIVisualEffectView(effect: blurEffect)

        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        background.addGestureRecognizer(tap)

        return background
    }()

    private lazy var vibrancyView: UIVisualEffectView = {
        let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))

        vibrancy.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return vibrancy
    }()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()

        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.placeholder = "Search for Facts"
        bar.barStyle = .black
        bar.keyboardAppearance = .dark

        return bar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isOpaque = false
        view.backgroundColor = .clear

        installBackgroundAndVibrancy()
        installSearchBar()
    }

    private func installBackgroundAndVibrancy() {
        backgroundView.frame = view.bounds
        view.addSubview(backgroundView)

        vibrancyView.frame = view.bounds
        backgroundView.contentView.addSubview(vibrancyView)
    }

    private func installSearchBar() {
        vibrancyView.contentView.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor, constant: Metrics.extraPadding * 2).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchBar.resignFirstResponder()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc private func backgroundTapped() {
        delegate?.searchViewControllerWantsToBeDismissed(self)
    }

}
