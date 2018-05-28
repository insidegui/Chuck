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
import os.log

protocol SearchViewControllerDelegate: class {
    func searchViewControllerWantsToBeDismissed(_ controller: SearchViewController)
    func searchViewController(_ controller: SearchViewController, didSearchForTerm term: String)
}

final class SearchViewController: UIViewController {

    private let log = OSLog(subsystem: "Chuck", category: "SearchViewController")

    weak var delegate: SearchViewControllerDelegate?

    let syncEngine: SyncEngine

    init(syncEngine: SyncEngine) {
        self.syncEngine = syncEngine

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
        modalPresentationCapturesStatusBarAppearance = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported")
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

    private func makeSearchBarBackground() -> UIImage {
        let width = view.bounds.size.width + Metrics.padding

        let rect = CGRect(x: 0, y: 0, width: width, height: Metrics.searchBarHeight)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)

        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }

        UIBezierPath(roundedRect: rect, cornerRadius: Metrics.searchBarRadius).addClip()

        ctx.setFillColor(UIColor.white.withAlphaComponent(0.7).cgColor)

        ctx.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()

        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.placeholder = "Search for Facts"
        bar.barStyle = .black
        bar.keyboardAppearance = .dark
        bar.backgroundImage = UIImage()
        bar.uiTestingLabel = .searchBar

        bar.setSearchFieldBackgroundImage(makeSearchBarBackground(), for: .normal)

        if let field = bar.value(forKey: "searchField") as? UITextField,
            let placeholderLabel = field.value(forKey: "placeholderLabel") as? UILabel
        {
            placeholderLabel.font = UIFont.systemFont(ofSize: 16)
            placeholderLabel.textColor = .black
        }

        bar.searchTextPositionAdjustment = UIOffset(horizontal: Metrics.padding, vertical: 0)
        bar.delegate = self

        return bar
    }()

    lazy var suggestionsController: SearchSuggestionsViewController = {
        let controller = SearchSuggestionsViewController()

        controller.delegate = self
        controller.view.translatesAutoresizingMaskIntoConstraints = false

        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.uiTestingLabel = .searchView

        view.isOpaque = false
        view.backgroundColor = .clear

        installBackgroundAndVibrancy()
        installSearchBar()
        installSuggestionsController()
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
        searchBar.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor, constant: Metrics.padding / 2).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor, constant: -Metrics.padding / 2).isActive = true
    }

    private func installSuggestionsController() {
        addChildViewController(suggestionsController)

        vibrancyView.contentView.addSubview(suggestionsController.view)

        suggestionsController.view.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor, constant: Metrics.padding).isActive = true
        suggestionsController.view.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor, constant: -Metrics.padding).isActive = true
        suggestionsController.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Metrics.extraPadding).isActive = true

        suggestionsController.didMove(toParentViewController: self)
    }

    private func saveSearchToRecents(with term: String) {
        do {
            try syncEngine.registerSearchHistory(for: term)
        } catch {
            os_log("Failed to register recent search: %{public}@", log: self.log, type: .error, String(describing: error))
        }
    }

    private var suggestionsDisposeBag = DisposeBag()

    private func bindSearchSuggestions() {
        suggestionsDisposeBag = DisposeBag()

        syncEngine.fetchRandomCategories().bind(to: suggestionsController.categories).disposed(by: suggestionsDisposeBag)
        syncEngine.fetchRecentSearches(with: 16).bind(to: suggestionsController.recents).disposed(by: suggestionsDisposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchBar.text = nil
        bindSearchSuggestions()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc private func backgroundTapped() {
        delegate?.searchViewControllerWantsToBeDismissed(self)
    }

    // MARK: - Transition Support

    func configureWithDismissedState() {
        backgroundView.effect = nil
        searchBar.alpha = 0
        suggestionsController.view.alpha = 0
        vibrancyView.layer.transform = CATransform3DMakeTranslation(0, -100, 0)
        view.endEditing(true)
    }

    func configureWithPresentedState() {
        backgroundView.effect = blurEffect
        searchBar.alpha = 1
        suggestionsController.view.alpha = 1
        vibrancyView.layer.transform = CATransform3DIdentity
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let term = searchBar.text, term.count > 3 else { return }

        saveSearchToRecents(with: term)

        delegate?.searchViewController(self, didSearchForTerm: term)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

}

extension SearchViewController: SearchSuggestionsViewControllerDelegate {

    func searchSuggestionsViewController(_ controller: SearchSuggestionsViewController, didSelectSuggestionWithTerm term: String) {
        searchBar.text = term
        delegate?.searchViewController(self, didSearchForTerm: term)
    }

}
