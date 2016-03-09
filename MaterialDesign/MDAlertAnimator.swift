//
//  MDAlertAnimator.swift
//
//  Created by Shuyang Sun on 1/14/16.
//
//	The MIT License (MIT)
//	Copyright (c) <2016> <Shuyang Sun>
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

public class MDAlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	var reverse = false

	@objc public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return defaultAnimationDuration
	}

	@objc public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		if transitionContext.isAnimated() {
			if !self.reverse {
				// Transitioning to MDAlertController
				if let containerView = transitionContext.containerView() {
					let alertVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! MDAlertController
					let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!

					// Animation magic happens here
					// Add a background view first
					let snapshotFromVC = fromVC.view.snapshotViewAfterScreenUpdates(false)
					alertVC.snapshot = snapshotFromVC
					snapshotFromVC.frame = fromVC.view.frame

					alertVC.backgroundView.alpha = 0
					alertVC.alertView.alpha = 0
					alertVC.alertView.transform = CGAffineTransformMakeScale(2, 2)

					containerView.addSubview(alertVC.view)
					UIView.animateWithDuration(self.transitionDuration(transitionContext),
						delay: 0,
						usingSpringWithDamping: 0.5,
						initialSpringVelocity: 0.5,
						options: .CurveEaseInOut,
						animations: {
							alertVC.backgroundView.alpha = 1
							alertVC.alertView.alpha = 1
							alertVC.alertView.transform = CGAffineTransformIdentity
						}) { succeed in
							alertVC.snapshot?.removeFromSuperview()
							alertVC.snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
							alertVC.snapshot?.frame = fromVC.view.frame
							alertVC.view.insertSubview(alertVC.snapshot!, atIndex: 0)
							transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
					}
				}
			} else {
				// Transitioning back to homeVC
				if let containerView = transitionContext.containerView() {
					let alertVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! MDAlertController
					containerView.addSubview(alertVC.view)

					UIView.animateWithDuration(self.transitionDuration(transitionContext),
						delay: 0,
						usingSpringWithDamping: 1,
						initialSpringVelocity: 0.5,
						options: .CurveEaseIn,
						animations: {
							alertVC.alertView.transform = CGAffineTransformMakeScale(0.1, 0.1)
							containerView.alpha = 0
						}) { succeed in
							// FIXME: Not called if interaction time is less than animation time.
							containerView.removeFromSuperview()
							transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
					}
				}
			}
		}
	}
}
