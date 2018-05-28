//
//  BadgesCollectionViewController.swift
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

private struct BadgeSectionModel: AnimatableSectionModelType {

    static let cellIdentifier = "badgeCell"

    var identity: String {
        return "Facts"
    }

    typealias Identity = String
    typealias Item = String

    var items: [String]

    init(original: BadgeSectionModel, items: [String]) {
        self = original
        self.items = items
    }

    init(items: [String]) {
        self.items = items
    }

}

protocol BadgesCollectionViewControllerDelegate: class {
    func badgesCollectionViewController(_ controller: BadgesCollectionViewController, didSelectItemWithTitle title: String)
}

class BadgesCollectionViewController: UIViewController {

    weak var delegate: BadgesCollectionViewControllerDelegate?

    lazy var badgeTitles = Variable<[String]>([])

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
        view.isOpaque = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        installCollectionView()
    }

    private lazy var flowLayout: BadgeFlowLayout = {
        let flow = BadgeFlowLayout()

        flow.estimatedItemSize = CGSize(width: 112, height: 24)
        flow.minimumLineSpacing = Metrics.padding / 2
        flow.minimumInteritemSpacing = Metrics.padding / 2

        return flow
    }()

    private lazy var collectionView: SelfSizingCollectionView = {
        let collection = SelfSizingCollectionView(frame: .zero, collectionViewLayout: flowLayout)

        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.setContentCompressionResistancePriority(.required, for: .vertical)

        return collection
    }()

    private func installCollectionView() {
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        bindCollectionView()
    }

    private let disposeBag = DisposeBag()

    private func bindCollectionView() {
        collectionView.register(BadgeCollectionViewCell.self, forCellWithReuseIdentifier: BadgeSectionModel.cellIdentifier)

        let dataSource = RxCollectionViewSectionedReloadDataSource<BadgeSectionModel>(configureCell: { _, collectionView, indexPath, title in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeSectionModel.cellIdentifier, for: indexPath) as! BadgeCollectionViewCell

            cell.title = title

            return cell
        }, configureSupplementaryView: { _, _, _, _ in fatalError() })

        let sections = badgeTitles.asObservable().map({ [BadgeSectionModel(items: $0)] })
        sections.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

}

extension BadgesCollectionViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = badgeTitles.value[indexPath.item]
        delegate?.badgesCollectionViewController(self, didSelectItemWithTitle: title)
    }

}
