//
//  FadeTransitioningDelegate.swift
//  RepReady
//
//  Created by Jim Learning on 2024/2/26.
//

import UIKit

class FadeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var isPresenting = true

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}

extension FadeTransitioningDelegate: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = transitionContext.view(forKey: isPresenting ? .to : .from) else { return }

        containerView.addSubview(toView)
        toView.frame = containerView.bounds

        let alpha: CGFloat = isPresenting ? 0.0 : 1.0
        toView.alpha = alpha

        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            toView.alpha = self.isPresenting ? 1.0 : 0.0
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
