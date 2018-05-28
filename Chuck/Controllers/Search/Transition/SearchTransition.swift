//
//  SearchTransition.swift
//  Chuck
//
//  Created by Guilherme Rambo on 28/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import UIKit

class SearchTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    var isDismissing = false

    var auxAnimations: (()-> Void)?
    var auxAnimationsCancel: (()-> Void)?

    var context: UIViewControllerContextTransitioning?
    var animator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionAnimator(using: transitionContext).startAnimation()
    }

    func transitionAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let duration = transitionDuration(using: transitionContext)

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)

        let container = transitionContext.containerView

        if !isDismissing {
            guard let to = transitionContext.view(forKey: .to) else { return animator }

            to.frame = container.bounds
            container.addSubview(to)
        }

        animator.addCompletion { position in
            switch position {
            case .end:
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            default:
                transitionContext.completeTransition(false)
                self.auxAnimationsCancel?()
            }
        }

        if let auxAnimations = auxAnimations {
            animator.addAnimations(auxAnimations)
        }

        self.animator = animator
        self.context = transitionContext

        animator.addCompletion { [unowned self] _ in
            self.animator = nil
            self.context = nil
        }
        animator.isUserInteractionEnabled = true

        return animator
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return transitionAnimator(using: transitionContext)
    }

    func interruptTransition() {
        guard let context = context else {
            return
        }
        context.pauseInteractiveTransition()
        pause()
    }
}

