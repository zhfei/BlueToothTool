//
//  MiniAppTransition.swift
//  RepReady
//
//  Created by Jim Learning on 2023/8/29.
//

/**
  ```swift
    private lazy var transition = SwipeTransitioningDelegate()
 
    let toViewController = UIViewController()
    let configuration = SwipeTransitioningConfiguration()
    transition.present(fromViewController: self, toViewController: toViewController, configuration: configuration)
  ```
 */

import UIKit

extension UIGestureRecognizer {
    struct Name {
        static let SwipeTransitionDownPanGesture = "SwipeTransitionDownPanGesture"
        static let SwipeTransitionScreenEdgePanGesture = "SwipeTransitionScreenEdgePanGesture"
    }
}

enum GesturePriority {
    case all // scrollView + edgePanGesture + downPanGesture 全部生效
    case edgePanGesture // 从左侧边缘向右滑动
    case downPanGesture // 从 self.view 向下滑动
    case edgeDownPanGesture // edgePanGesture + downPanGesture
    case scrollView // scrollView 生效，edgePanGesture + downPanGesture 不生效
    case custom(views: [UIView]) // custom views 生效，edgePanGesture + downPanGesture 不生效
}

enum PanGestureAvailable {
    case both
    case edgePan
    case downPan
}

struct SwipeTransitioningConfiguration {
    var transitionDuration: CGFloat = 0.5
    var topInset: CGFloat = 0
    var cornerRadius: CGFloat = 20
    var gesturePriority: GesturePriority = .all
    var dismissed: (() -> Void)? = nil
}

class SwipeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private var presentationController: SwipePresentationController? = nil
    private var configuration = SwipeTransitioningConfiguration()
    
    func present(fromViewController: UIViewController, toViewController: UIViewController, configuration: SwipeTransitioningConfiguration = SwipeTransitioningConfiguration()) {
        self.configuration = configuration
        self.configuration.dismissed = { [weak self] in
            configuration.dismissed?()
            self?.presentationController = nil
        }
        toViewController.transitioningDelegate = self
        toViewController.modalPresentationStyle = .custom
        fromViewController.present(toViewController, animated: true)
    }
    
    func dismiss() {
        self.presentationController?.dismiss()
    }
}

extension SwipeTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeAnimator(transitionDuration: configuration.transitionDuration, topInset: configuration.topInset)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SwipeAnimator(transitionDuration: configuration.transitionDuration, topInset: 0)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.presentationController?.swipeTransitioning
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SwipePresentationController(presentedViewController: presented, presenting: presenting, configuration: configuration)
        self.presentationController = presentationController
        return presentationController
    }
}

protocol PresentViewControllerDismissDelegate: AnyObject {
    
    func dismiss()
}

final class SwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var transitionDuration: CGFloat
    var topInset: CGFloat
    private var propertyAnimator: UIViewPropertyAnimator!
    
    init(transitionDuration: CGFloat, topInset: CGFloat) {
        self.transitionDuration = transitionDuration
        self.topInset = topInset
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        if toVC.isBeingPresented {
            let containerView = transitionContext.containerView
            containerView.addSubview(toVC.view)
            toVC.view.frame = CGRect(origin: CGPoint(x: 0, y: containerView.bounds.maxY), size: containerView.bounds.size)
        }
        
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return UIViewPropertyAnimator()
        }
        let duration = transitionDuration(using: transitionContext)
        let containerView = transitionContext.containerView
        
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: UISpringTimingParameters(dampingRatio: 1))
        propertyAnimator.addAnimations { [weak toVC, weak transitionContext] in
            guard let toVC, let transitionContext else {
                return
            }
            if toVC.isBeingPresented {
                let frame = CGRect(origin: CGPoint(x: 0, y: self.topInset), size: toVC.view.bounds.size)
                toVC.view.frame = frame
            } else {
                guard let fromView = transitionContext.view(forKey: .from) else {
                    return
                }
                fromView.frame.origin.y = containerView.frame.maxY
            }
        }
        propertyAnimator.addCompletion { [weak transitionContext] _ in
            guard let transitionContext else {
                return
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        return propertyAnimator
    }
}

class SwipePresentationController: UIPresentationController {
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, configuration: SwipeTransitioningConfiguration) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.configuration = configuration
    }
    
    private var configuration = SwipeTransitioningConfiguration()
    
    private(set) var swipeTransitioning: UIPercentDrivenInteractiveTransition? = nil
    private var dimmingView: UIView = UIView()
    
    @objc func edgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let container = gesture.view else {
            return
        }
        switch gesture.state {
        case .began:
            guard swipeTransitioning == nil,
                  !presentingViewController.isBeingPresented,
                  !presentedViewController.isBeingDismissed else {
                break
            }
            swipeTransitioning = UIPercentDrivenInteractiveTransition()
            swipeTransitioning?.completionCurve = .easeOut
            presentingViewController.dismiss(animated: true, completion: nil)
        case .changed:
            let translation = gesture.translation(in: container)
            var width = container.bounds.width
            if width <= 0 {
                width = UIScreen.main.bounds.width
            }
            
            let progress = translation.x > 0 ? (translation.x / width) : 0
            
            swipeTransitioning?.update(progress)
            dimmingView.alpha = 1 - progress
        case .ended, .cancelled:
            guard let swipeTransitioning else {
                break
            }
            if (swipeTransitioning.percentComplete > 0.2 || gesture.velocity(in: container).x > container.bounds.width / 2) {
                swipeTransitioning.finish()
                dimmingView.alpha = 0
            } else {
                swipeTransitioning.cancel()
                dimmingView.alpha = 1
            }
            self.swipeTransitioning = nil
        default:
            break
        }
    }
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        guard let container = gesture.view else {
            return
        }
        switch gesture.state {
        case .began:
            guard swipeTransitioning == nil,
                  !presentingViewController.isBeingPresented,
                  !presentedViewController.isBeingDismissed else {
                break
            }
            swipeTransitioning = UIPercentDrivenInteractiveTransition()
            swipeTransitioning?.completionCurve = .easeOut
            presentingViewController.dismiss(animated: true, completion: nil)
        case .changed:
            let translation = gesture.translation(in: container)
            var height = container.bounds.height
            if height <= 0 {
                height = UIScreen.main.bounds.height
            }
            let progress = translation.y > 0 ? (translation.y / height ) : 0
            
            swipeTransitioning?.update(progress)
            dimmingView.alpha = 1 - progress
        case .ended, .cancelled:
            guard let swipeTransitioning else {
                break
            }
            let velocity = gesture.velocity(in: gesture.view)
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self else {
                    return
                }
                if swipeTransitioning.percentComplete > 0.2 || velocity.y > container.bounds.height / 2 {
                    swipeTransitioning.finish()
                    dimmingView.alpha = 0
                } else {
                    swipeTransitioning.cancel()
                    dimmingView.alpha = 1
                }
            } completion: { [weak self] _ in
                guard let self else {
                    return
                }
                self.swipeTransitioning = nil
            }
        default:
            break
        }
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView else {
            return
        }
        
        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = .clear
        dimmingView.isUserInteractionEnabled = true
        containerView.insertSubview(dimmingView, belowSubview: presentedViewController.view)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        dimmingView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: configuration.transitionDuration) { [weak self] in
            guard let self else {
                return
            }
            dimmingView.backgroundColor = Color.black.withAlphaComponent(0.2)
        }
        
        let cornersRadius = UICornersRadius(topLeft: configuration.cornerRadius,
                                            topRight: configuration.cornerRadius,
                                            bottomLeft: 0,
                                            bottomRight: 0)
        presentedViewController.view.layer.bounds = containerView.bounds
        presentedViewController.view.layer.set(cornersRadius: cornersRadius)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        guard completed else {
            return
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        pan.name = UIGestureRecognizer.Name.SwipeTransitionDownPanGesture
        pan.delegate = self
        containerView?.addGestureRecognizer(pan)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.edgePan(_:)))
        edgePan.name = UIGestureRecognizer.Name.SwipeTransitionScreenEdgePanGesture
        edgePan.edges = UIRectEdge.left
        edgePan.delegate = self
        containerView?.addGestureRecognizer(edgePan)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        
        guard completed else {
            return
        }
        
        UIView.animate(withDuration: configuration.transitionDuration) { [weak self] in
            guard let self else {
                return
            }
            dimmingView.backgroundColor = .clear
        } completion: { [weak self] finished in
            guard let self else {
                return
            }
            dimmingView.removeFromSuperview()
            configuration.dismissed?()
        }
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        dimmingView.frame = presentedViewController.view.bounds
        guard let containerView else {
            return
        }
        presentedViewController.view.frame = CGRect(origin: CGPoint(x: 0, y: configuration.topInset), size: CGSize(width: containerView.bounds.width, height: containerView.bounds.height - configuration.topInset))
    }
    
    @objc func tapped() {
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: configuration.transitionDuration) { [weak self] in
            guard let self else {
                return
            }
            dimmingView.backgroundColor = .clear
        }
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

extension SwipePresentationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch configuration.gesturePriority {
        case .all, .edgePanGesture, .downPanGesture, .edgeDownPanGesture:
            return true
        case .scrollView:
            return false
        case .custom(_):
            return false
        }
    }
    
    // if YES, gestureRecognizer will fail.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch configuration.gesturePriority {
        case .all:
            //if let scrollView = gestureRecognizer.view as? UIScrollView {
            //
            //}
            if gestureRecognizer.name == UIGestureRecognizer.Name.SwipeTransitionDownPanGesture, otherGestureRecognizer.view is UIScrollView {
                return true
            }
        default:
            return false
        }
        return false
    }
    
    // if YES, otherGestureRecognizer will fail.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        switch configuration.gesturePriority {
        case .all:
            //if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            //
            //}
            if gestureRecognizer.name == UIGestureRecognizer.Name.SwipeTransitionScreenEdgePanGesture {
                return true
            }
            return false
        case .edgePanGesture:
            if gestureRecognizer.name == UIGestureRecognizer.Name.SwipeTransitionScreenEdgePanGesture {
                return true
            }
            return false
        case .downPanGesture:
            if gestureRecognizer.name == UIGestureRecognizer.Name.SwipeTransitionDownPanGesture {
                return true
            }
            return false
        case .edgeDownPanGesture:
            if gestureRecognizer.name == UIGestureRecognizer.Name.SwipeTransitionDownPanGesture ||
                gestureRecognizer.name == UIGestureRecognizer.Name.SwipeTransitionScreenEdgePanGesture {
                return true
            }
            return false
        case .scrollView:
            if let scrollView = gestureRecognizer.view as? UIScrollView {
                if scrollView.contentSize.width > scrollView.frame.width ||
                    scrollView.contentSize.height > scrollView.frame.height {
                    return true
                }
            }
            return false
        case .custom(let views):
            if let view = gestureRecognizer.view, views.contains(view) {
                if let scrollView = view as? UIScrollView {
                    if scrollView.contentSize.width > scrollView.frame.width ||
                        scrollView.contentSize.height > scrollView.frame.height {
                        return true
                    }
                } else {
                    return true
                }
            }
            return false
        }
    }
}
