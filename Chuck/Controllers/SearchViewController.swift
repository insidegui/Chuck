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
    func searchViewController(_ controller: SearchViewController, didSearchForTerm term: String)
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

    private func makeSearchBarBackground() -> UIImage {
        let width = view.bounds.size.width + Metrics.padding * 2

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

        bar.setSearchFieldBackgroundImage(makeSearchBarBackground(), for: .normal)

        if let field = bar.value(forKey: "searchField") as? UITextField,
            let placeholderLabel = field.value(forKey: "placeholderLabel") as? UILabel
        {
            placeholderLabel.font = UIFont.systemFont(ofSize: 16)
            placeholderLabel.textColor = .black
        }

        bar.searchTextPositionAdjustment = UIOffset(horizontal: Metrics.padding, vertical: 0)

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

        bindSearchBar()
    }

    private let disposeBag = DisposeBag()

    private func bindSearchBar() {
        let signal = searchBar.rx.text.asObservable()
                         .debounce(0.5, scheduler: MainScheduler.instance)
                         .filter({ ($0 ?? "").count > 3 })

        signal.subscribe(onNext: { [weak self] term in
            guard let `self` = self, let term = term else { return }
            self.delegate?.searchViewController(self, didSearchForTerm: term)
        }).disposed(by: disposeBag)
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
