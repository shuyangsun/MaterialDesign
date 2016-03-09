//
//  MDAlertController.swift
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

/** A class that is similar with UIAlertController, but the presentation style is using Material Design. */
public class MDAlertController: UIViewController {

	var alertView:UIView!
	var titleLabel:UILabel!
	var messageLabel:UILabel!
	var snapshot:UIView? {
		willSet {
			if newValue != nil {
				self.view.insertSubview(newValue!, atIndex: 0)
				// Setup constraints
				newValue!.addConstraints([
					NSLayoutConstraint(item: newValue!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: newValue!, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: newValue!, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: newValue!, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0)
				])
			}
		}
	}
	var backgroundView:UIView!
	var buttonOutlineView:UIView! {
		didSet {
			for tuple in self._actionsAndButtons {
				let button = tuple.button
				self.buttonOutlineView.addSubview(button)
			}
			self.updateButtonConstraints()
		}
	}
	private var _alertTitle:String?
	private var _alertMessage:String?
	private var _actionsAndButtons:[(action:MDAlertAction, button:UIButton)] = []
	private var _didAddCustomAction = false

	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Initialize a MDAlertController with title and message. If you don't add any action (customized button) to it, there will be an "OK" button by default, which does nothing but dismiss this alert view controller.
	- Parameters:
		- title: The title of alert view.
		- message: The message body of alert view.
	*/
	public convenience init(title: String?, message: String?) {
		self.init()
		self._alertTitle = title
		self._alertMessage = message
		let actionOK = MDAlertAction(title: okButtonTitle)
		self.addAction(actionOK)
		self._didAddCustomAction = false
		self.modalPresentationStyle = .Custom
		// -------------------------------------------------------------------------------------------------------------------------------------
		// WARNING: Uncomment next time and replace "RootVCType" with your root view controller type. Then setup your root view controller's "animationControllerForPresentedController" and "animationControllerForDismissedController" to return an instance of MDAlertAnimator.
//		self.transitioningDelegate = UIApplication.sharedApplication().windows[0].rootViewController as! <#RootVCType#>
		// -------------------------------------------------------------------------------------------------------------------------------------
	}
	// -------------------------------------------------------------------------------------------------------------------------------------


	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Add an alert action (button) to this controller. Adding any button will automatically remove the default "OK" button.
	- Parameters:
		- action: An action specifying the title and handler block of the button.
	*/
	public func addAction(action:MDAlertAction) {
		if !self._didAddCustomAction {
			// If the user hasn't add any custom action, remove the default "OK" action
			if !self._actionsAndButtons.isEmpty {
				self._actionsAndButtons.first?.button.removeFromSuperview()
				self._actionsAndButtons.removeFirst()
			}
		}
		let button = UIButton()
		button.setAttributedTitle(getAttributedStringFrom(action.title.uppercaseString, withFontSize: mdAlertButtonFontSize, color: mdAlertControllerButtonTextColorNormal, bold: true), forState: .Normal)
		button.setAttributedTitle(getAttributedStringFrom(action.title.uppercaseString, withFontSize: mdAlertButtonFontSize, color: mdAlertControllerButtonTextColorHighlighted, bold: true), forState: .Highlighted)
		button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
		self._actionsAndButtons.append((action, button))
		if self.buttonOutlineView != nil {
			self.buttonOutlineView.addSubview(button)
			self.updateButtonConstraints()
		}
		self._didAddCustomAction = true
	}
	// -------------------------------------------------------------------------------------------------------------------------------------

	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Present this alert view controller. The presenting controller will be the root controller, so the alert view controller will always show at the top of view controller hierarchy.
	*/
	public func show() {
		UIApplication.sharedApplication().windows[0].rootViewController!.presentViewController(self, animated: true, completion: nil)
	}
	// -------------------------------------------------------------------------------------------------------------------------------------

	private func setup() {
		self.view.backgroundColor = UIColor.clearColor()
		if self.backgroundView == nil {
			self.backgroundView = UIView(frame: self.view.bounds)
			self.backgroundView.backgroundColor = mdAlertControllerBackgroundColor
			self.view.addSubview(self.backgroundView)
			self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
			// Setup constraints
			self.backgroundView.addConstraints([
				NSLayoutConstraint(item: self.backgroundView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.backgroundView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.backgroundView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.backgroundView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1, constant: 0)
			])
		}

		if self.alertView == nil {
			self.alertView = UIView()
			self.alertView.backgroundColor = mdAlertViewBackgroundColor
			self.alertView.layer.cornerRadius = mdAlertViewCornerRadius
			self.alertView.clipsToBounds = false
			self.view.addSubview(alertView)
		}

		let titleAttrText = getAttributedStringFrom(self._alertTitle, withFontSize: mdAlertTitleFontSize, color: mdAlertViewTitleTextColor, bold: true)
		var titleStrSize = titleAttrText!.boundingRectWithSize(CGSizeMake(9999, 9999), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil)
		titleStrSize = CGRect(x: titleStrSize.origin.x, y: titleStrSize.origin.y, width: titleStrSize.width, height: titleStrSize.height + 5)
		if self.titleLabel == nil {
			self.titleLabel = UILabel()
			self.titleLabel.textColor = mdAlertViewTitleTextColor
			self.titleLabel.attributedText = titleAttrText
			self.alertView.addSubview(self.titleLabel)
			// Setup constraints
			self.titleLabel.addConstraints([
				NSLayoutConstraint(item: self.backgroundView, attribute: .Top, relatedBy: .Equal, toItem: self.alertView, attribute: .Top, multiplier: 1, constant: mdAlertPaddingVertical * 1.5),
				NSLayoutConstraint(item: self.backgroundView, attribute: .Leading, relatedBy: .Equal, toItem: self.alertView, attribute: .Leading, multiplier: 1, constant: mdAlertPaddingHorizontal),
				NSLayoutConstraint(item: self.backgroundView, attribute: .Trailing, relatedBy: .Equal, toItem: self.alertView, attribute: .Trailing, multiplier: 1, constant: -mdAlertPaddingHorizontal)
			])
		}

		let alertWidth = min(self.view.bounds.width - mdAlertMarginHorizontal * 2, mdAlertMaxWidth)
		let messageAttrText = getAttributedStringFrom(self._alertMessage, withFontSize: mdAlertMessageFontSize, color: mdAlertViewMessageTextColor, bold: false)
		var messageStrSize = messageAttrText!.boundingRectWithSize(CGSizeMake(alertWidth - mdAlertPaddingHorizontal * 2, 10000), options: [.UsesLineFragmentOrigin, .UsesFontLeading], context: nil)
		let height = min(messageStrSize.height + 5, self.view.bounds.height - 2 * mdAlertMarginVertical - mdAlertButtonHeight - mdAlertPaddingVertical * 3 - titleStrSize.height)
		messageStrSize = CGRect(x: messageStrSize.origin.x, y: messageStrSize.origin.y, width: messageStrSize.width, height: height)
		if self.messageLabel == nil {
			self.messageLabel = UILabel()
			self.messageLabel.numberOfLines = 9999
			self.messageLabel.textColor = mdAlertViewMessageTextColor
			self.messageLabel.attributedText = messageAttrText
			self.alertView.addSubview(self.messageLabel)
			// Setup constraints
			self.messageLabel.addConstraints([
				NSLayoutConstraint(item: self.messageLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.alertView, attribute: .Leading, multiplier: 1, constant: mdAlertPaddingHorizontal),
				NSLayoutConstraint(item: self.messageLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.alertView, attribute: .Trailing, multiplier: 1, constant: -mdAlertPaddingHorizontal),
				NSLayoutConstraint(item: self.messageLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.alertView, attribute: .CenterY, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.messageLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: messageStrSize.height)
			])
		}

		if self.buttonOutlineView == nil {
			self.buttonOutlineView = UIView()
			self.buttonOutlineView.backgroundColor = UIColor.clearColor()
			self.buttonOutlineView.layer.cornerRadius = mdAlertViewCornerRadius
			self.buttonOutlineView.clipsToBounds = true
			self.alertView.addSubview(self.buttonOutlineView)
			// Setup constraints
			self.buttonOutlineView.addConstraints([
				NSLayoutConstraint(item: self.messageLabel, attribute: .Leading, relatedBy: .Equal, toItem: self.alertView, attribute: .Leading, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.messageLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self.alertView, attribute: .Trailing, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.messageLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.alertView, attribute: .Bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: self.messageLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: mdAlertButtonHeight)
			])
		}

		let alertHeight = min(self.view.bounds.height, max(mdAlertMinHeight, mdAlertButtonHeight + mdAlertPaddingVertical * 3 + messageStrSize.height + titleStrSize.height))
		// Setup constraints
		self.alertView.addConstraints([
			NSLayoutConstraint(item: self.alertView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.alertView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self.alertView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: alertWidth),
			NSLayoutConstraint(item: self.alertView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: alertHeight)
		])
	}

	override public func viewDidLoad() {
		super.viewDidLoad()
		self.setup()
	}

	override public func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	override public func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.alertView.addMDShadow(withDepth: 5)
	}

	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		coordinator.animateAlongsideTransition(nil) { context in
			if context.viewControllerForKey(UITransitionContextFromViewControllerKey) === self ||
				context.viewControllerForKey(UITransitionContextToViewControllerKey) === self {
				self.rotationDidChange()
			}
		}
	}

	func rotationDidChange() {
		self.snapshot?.removeFromSuperview()
		self.snapshot = self.presentingViewController?.view.snapshotViewAfterScreenUpdates(false)
		self.view.insertSubview(self.snapshot!, atIndex: 0)
	}

	private func updateButtonConstraints() {
		let count = self._actionsAndButtons.count
		for var i = 0; i < count; i++ {
			let tuple = self._actionsAndButtons[i]
			let button = tuple.button
			// Setup constraints
			button.removeConstraints(button.constraints)
			var constraints = [
				NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self.buttonOutlineView, attribute: .Top, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self.buttonOutlineView, attribute: .Bottom, multiplier: 1, constant: 0)
			]
			if i == 0 {
				constraints.append(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: self.buttonOutlineView, attribute: .Trailing, multiplier: 1, constant: -mdAlertPaddingHorizontal))
			} else {
				let lastButton = self._actionsAndButtons[i - 1].button
				constraints.append(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: lastButton, attribute: .Leading, multiplier: 1, constant: -mdAlertPaddingHorizontal * 1.5))
			}
			button.addConstraints(constraints)
		}
	}

	func buttonTapped(button:UIButton) {
		let centerPoint = CGPoint(x: button.bounds.width/2.0, y: button.bounds.height/2.0)
		let convertedPoint = self.alertView.convertPoint(centerPoint, fromView: button)
		self.alertView.triggerTapFeedBack(atLocation: convertedPoint, withColor: mdAlertControllerButtonTapFeedbackColor, atBottom:false) {
			var actionClosure:((MDAlertAction) -> Void)? = nil
			var action:MDAlertAction? = nil
			for tuple in self._actionsAndButtons {
				if tuple.button === button {
					action = tuple.action
					actionClosure = action?.actionHandler
					break
				}
			}
			if action != nil {
				if action!.dismissAlertView {
					self.dismissViewControllerAnimated(true) {
						actionClosure?(action!)
					}
				} else {
					actionClosure?(action!)
				}
			}
		}
	}

//	private func getViewsDictionary() -> [String:UIView] {
//		return [
//			"view": self.view,
//			"alertView": self.alertView,
//			"titleLabel": self.titleLabel,
//			"messageLabel": self.messageLabel,
//			"snapshot": self.snapshot!,
//			"backgroundView": self.backgroundView,
//			"buttonOutlineView": self.buttonOutlineView
//		]
//	}
}
