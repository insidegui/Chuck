//
//  CustomIntrinsicsView.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class CustomIntrinsicsView: UIView {

    var customIntrinsicSize: CGSize = CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return customIntrinsicSize
    }

}
