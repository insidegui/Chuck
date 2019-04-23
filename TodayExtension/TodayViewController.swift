//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Guilherme Rambo on 15/04/19.
//  Copyright © 2019 Guilherme Rambo. All rights reserved.
//

import UIKit
import NotificationCenter
import RxSwift
import RxCocoa
import ChuckCore

class TodayViewController: UIViewController, NCWidgetProviding {

    // 1. UI

    private let uiStack = ChuckUIStack()

    private lazy var effectView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIVibrancyEffect.widgetPrimary())

        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.frame = view.bounds

        return v
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .gray)

        v.translatesAutoresizingMaskIntoConstraints = false
        v.hidesWhenStopped = true

        return v
    }()

    private lazy var jokeLabel: UILabel = {
        let l = UILabel()

        l.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        l.textColor = UIColor.darkText
        l.lineBreakMode = .byWordWrapping
        l.numberOfLines = 0
        l.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        l.frame = view.bounds

        return l
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        installViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        jokeLabel.frame = view.bounds.insetBy(dx: 24, dy: 0)

        updateSize()
    }

    // MARK: - Layout

    private func installViews() {
        view.addSubview(effectView)
        effectView.contentView.addSubview(jokeLabel)

        effectView.contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: effectView.contentView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: effectView.contentView.centerXAnchor)
        ])
    }

    // 2. UPDATES

    private let bag = DisposeBag()

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        state = .loading

        uiStack.syncEngine.randomJoke().observeOn(MainScheduler.instance).bind { [weak self] joke in
            self?.state = .content(joke)

            completionHandler(NCUpdateResult.newData)
        }.disposed(by: bag)
    }

    private func updateSize() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(doUpdateSize), object: nil)
        perform(#selector(doUpdateSize), with: nil, afterDelay: 0)
    }

    @objc private func doUpdateSize() {
        preferredContentSize = jokeLabel.intrinsicContentSize
    }

    // 3. STATE

    enum State {
        case loading
        case content(JokeViewModel)
    }

    var state: State = .loading {
        didSet {
            updateUI()
        }
    }

    private func updateUI() {
        switch state {
        case .loading:
            spinner.startAnimating()
            jokeLabel.isHidden = true
        case .content(let joke):
            jokeLabel.text = joke.body

            spinner.stopAnimating()
            jokeLabel.isHidden = false

            updateSize()
        }
    }
    
}
