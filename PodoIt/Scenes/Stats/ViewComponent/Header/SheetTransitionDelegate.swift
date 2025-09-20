//
//  SheetTransitionDelegate.swift
//  PodoIt
//
//  Created by 정재성 on 9/17/25.
//

import UIKit
import Then

// MARK: - SheetTransitioningDelegate

final class SheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  private let transition = SheetTransition()

  var scrollView: UIScrollView?
  var cornerRadius: CGFloat = 21
  var prefersGrabberVisible = false
  var contentHeight: ContentHeight = .fit
  var usesPanGestureDismiss: Bool = true
  var usesTapGestureDismiss: Bool = true

  var animationDuration: TimeInterval {
    get { transition.animationDuration }
    set { transition.animationDuration = newValue }
  }

  init(scrollView: UIScrollView? = nil) {
    super.init()
    self.scrollView = scrollView
  }

  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?, source: UIViewController
  ) -> UIPresentationController? {
    PresentationController(presentedViewController: presented, presenting: presenting).then {
      $0.scrollView = scrollView
      $0.cornerRadius = cornerRadius
      $0.prefersGrabberVisible = prefersGrabberVisible
      $0.contentHeight = contentHeight
      $0.usesPanGestureDismiss = usesPanGestureDismiss
      $0.usesTapGestureDismiss = usesTapGestureDismiss
    }
  }

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    transition.wantsInteractiveStart = false
    transition.isPresenting = true
    return transition
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.isPresenting = false
    return transition
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    transition.isPresenting = false
    return transition
  }
}

// MARK: - SheetTransitioningDelegate.SheetTransition

extension SheetTransitioningDelegate {
  private class SheetTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    var isPresenting = true

    var animationDuration: TimeInterval = 0.35
    var presentationAnimator: UIViewPropertyAnimator?
    var dismissAnimator: UIViewPropertyAnimator?

    var dismissFractionComplete: CGFloat {
      return dismissAnimator?.fractionComplete ?? .zero
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
      return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      interruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      if isPresenting {
        return presentationAnimator ?? presentationInterruptibleAnimator(using: transitionContext)
      } else {
        return dismissAnimator ?? dismissInterruptibleAnimator(using: transitionContext)
      }
    }

    func presentationInterruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      guard let toViewController = transitionContext.viewController(forKey: .to), let toView = transitionContext.view(forKey: .to) else {
        return UIViewPropertyAnimator()
      }
      transitionContext.containerView.addSubview(toView)

      let finalFrame = transitionContext.finalFrame(for: toViewController)
      toView.frame = CGRect(
        x: finalFrame.minX,
        y: finalFrame.maxY,
        width: finalFrame.width,
        height: finalFrame.height
      )

      let animator = UIViewPropertyAnimator(
        duration: animationDuration,
        timingParameters: UISpringTimingParameters(duration: animationDuration, bounce: 0, initialVelocity: .zero)
      )
      animator.addAnimations {
        toView.frame = finalFrame
      }
      animator.addCompletion { position in
        if case .end = position {
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          return
        }
        transitionContext.completeTransition(false)
      }
      animator.addCompletion { [weak self] _ in
        self?.presentationAnimator = nil
      }
      presentationAnimator = animator
      return animator
    }

    func dismissInterruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
      guard let fromView = transitionContext.view(forKey: .from) else {
        return UIViewPropertyAnimator()
      }

      let animator = UIViewPropertyAnimator(
        duration: animationDuration,
        timingParameters: UISpringTimingParameters(duration: animationDuration, bounce: 0, initialVelocity: .zero)
      )
      animator.addAnimations {
        fromView.frame.origin.y = fromView.frame.maxY
      }
      animator.addCompletion { position in
        if case .end = position {
          fromView.removeFromSuperview()
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
          return
        }
        transitionContext.completeTransition(false)
      }
      animator.addCompletion { [weak self] _ in
        self?.dismissAnimator = nil
      }
      dismissAnimator = animator
      return animator
    }
  }
}

// MARK: - SheetTransitioningDelegate.PresentationController

extension SheetTransitioningDelegate {
  private class PresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    var scrollView: UIScrollView?
    var cornerRadius: CGFloat = 0
    var prefersGrabberVisible: Bool = false

    let dismissThreshold: CGFloat = 0.1
    let grabberViewOffset: CGFloat = 5

    var contentHeight: ContentHeight = .fit

    var usesPanGestureDismiss: Bool = true
    var usesTapGestureDismiss: Bool = true

    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
    lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)).then {
      $0.minimumNumberOfTouches = 1
      $0.maximumNumberOfTouches = 1
      $0.delegate = self
    }

    lazy var scrollViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)).then {
      $0.minimumNumberOfTouches = 1
      $0.maximumNumberOfTouches = 1
      $0.delegate = self
    }

    lazy var backgroundView = UIView().then {
      $0.backgroundColor = .black.withAlphaComponent(0.5)
      $0.alpha = 0
    }

    lazy var grabberView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 5)).then {
      $0.backgroundColor = .lightGray
      $0.isUserInteractionEnabled = false
      $0.layer.cornerRadius = $0.frame.height * 0.5
      $0.layer.masksToBounds = true
    }

    var presentedScrollView: UIScrollView? {
      return scrollView ?? presentedView?.subviews.first { $0 is UIScrollView } as? UIScrollView
    }

    var transitioningDelegate: SheetTransitioningDelegate? {
      presentedViewController.transitioningDelegate as? SheetTransitioningDelegate
    }

    override var frameOfPresentedViewInContainerView: CGRect {
      guard let containerView, let presentedView else {
        return super.frameOfPresentedViewInContainerView
      }
      switch contentHeight {
      case .fit:
        let maximumHeight = containerView.frame.height - containerView.safeAreaInsets.top - containerView.safeAreaInsets.bottom
        let fittingSize = presentedView.systemLayoutSizeFitting(
          CGSize(
            width: containerView.bounds.width,
            height: containerView.bounds.height
          ),
          withHorizontalFittingPriority: .required,
          verticalFittingPriority: .fittingSizeLevel
        )

        let offset: CGFloat
        if prefersGrabberVisible {
          offset = grabberView.frame.height + grabberViewOffset
        } else {
          offset = 0
        }
        let targetHeight = fittingSize.height == .zero ? maximumHeight : fittingSize.height
        let adjustedHeight = min(targetHeight, maximumHeight) + containerView.safeAreaInsets.bottom + offset

        let size = CGSize(width: containerView.frame.width, height: adjustedHeight)
        let origin = CGPoint(x: 0, y: containerView.frame.maxY - size.height)
        return CGRect(origin: origin, size: size)

      case .custom(let height):
        let contentHeight = height(containerView.frame.size, containerView.safeAreaInsets)
        let size = CGSize(width: containerView.frame.width, height: contentHeight)
        let origin = CGPoint(x: 0, y: containerView.frame.maxY - contentHeight)
        return CGRect(origin: origin, size: size)
      }
    }

    override func presentationTransitionWillBegin() {
      super.presentationTransitionWillBegin()
      if let scrollView = presentedScrollView {
        scrollView.addGestureRecognizer(scrollViewPanGesture)
      }

      containerView?.addSubview(backgroundView)
      if prefersGrabberVisible {
        presentedView?.addSubview(grabberView)
      }
      presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
        self?.presentedView?.layer.cornerRadius = self?.cornerRadius ?? 0
        self?.backgroundView.alpha = 1
      })
    }

    override func dismissalTransitionWillBegin() {
      super.dismissalTransitionWillBegin()
      presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
        self?.presentedView?.layer.cornerRadius = 0
        self?.backgroundView.alpha = 0
      })
    }

    override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      if let containerView {
        backgroundView.frame = containerView.bounds
      }
      guard let presentedView = presentedView else {
        return
      }
      presentedView.layoutIfNeeded()

      if prefersGrabberVisible {
        grabberView.frame.origin.y = -(grabberView.frame.height + grabberViewOffset)
        grabberView.center.x = presentedView.center.x
        presentedViewController.additionalSafeAreaInsets.top = grabberView.frame.height + grabberViewOffset
      }

      if cornerRadius > 0 {
        if #available(iOS 13.0, *) {
          presentedView.layer.cornerCurve = .continuous
        }
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      }

      if usesTapGestureDismiss && !(backgroundView.gestureRecognizers?.contains(tapGesture) ?? false) {
        backgroundView.addGestureRecognizer(tapGesture)
      }
      if usesPanGestureDismiss && !(presentedView.gestureRecognizers?.contains(panGesture) ?? false) {
        presentedView.addGestureRecognizer(panGesture)
      }
    }

    func dismiss(interactively isInteractive: Bool) {
      transitioningDelegate?.transition.wantsInteractiveStart = isInteractive
      presentedViewController.dismiss(animated: true)
    }

    @objc func handleTapGesture() {
      dismiss(interactively: false)
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
      guard let presentedView, let containerView else {
        return
      }
      switch recognizer.state {
      case .began:
        dismiss(interactively: true)
      case .changed:
        updateTransitionProgress(for: recognizer.translation(in: presentedView))
      case .ended, .cancelled, .failed:
        handleEndedInteraction(velocity: recognizer.velocity(in: recognizer.view))
      case .possible:
        break
      @unknown default:
        break
      }
    }

    func updateTransitionProgress(for translation: CGPoint) {
      guard let transitioningDelegate, let presentedView else {
        return
      }
      let adjustedHeight = presentedView.frame.height - translation.y
      let progress = 1 - (adjustedHeight / presentedView.frame.height)
      transitioningDelegate.transition.update(progress)
    }

    func handleEndedInteraction(velocity: CGPoint) {
      guard let transitioningDelegate else {
        return
      }
      transitioningDelegate.transition.wantsInteractiveStart = false

      if velocity.y > 0 && (velocity.y > 500 || transitioningDelegate.transition.dismissFractionComplete > dismissThreshold) {
        transitioningDelegate.transition.finish()
      } else {
        transitioningDelegate.transition.cancel()
      }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      guard let scrollView = presentedScrollView, gestureRecognizer == scrollViewPanGesture else {
        return true
      }
      guard scrollView.contentSize.height > scrollView.frame.height else {
        return true
      }
      let translation = scrollViewPanGesture.translation(in: scrollViewPanGesture.view)
      return scrollView.contentOffset.y <= 0 && translation.y > 0 && scrollView.isTracking
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return false
    }
  }
}

// MARK: - SheetTransitioningDelegate.ContentHeight

extension SheetTransitioningDelegate {
  enum ContentHeight {
    case fit
    case custom((CGSize, UIEdgeInsets) -> CGFloat)
  }
}
