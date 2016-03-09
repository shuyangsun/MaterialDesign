//
//  MDAlertAction.swift
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

import Foundation

// -------------------------------------------------------------------------------------------------------------------------------------
/** A MDAlertAction helps creating an MDAlertController. An action is basically a button on the alert view controller. */
public class MDAlertAction {
	/** Name of the button. */
	var title:String = ""
	/** What happens when the user taps the button. */
	var actionHandler:((MDAlertAction) -> Void)?
	/** Wheather to dismiss the associated alert view controller after user taps the button. */
	var dismissAlertView = true

	/**
	Initialize a MDAlertAction
	- Parameters:
		- title: Name of the button.
		- actionHandler: What happens when the user taps the button.
		- dismissAlertView (default=true): Wheather to dismiss the associated alert view controller after user taps the button.
	*/
	public init(title: String, dismissAlert:Bool = true, handler:((MDAlertAction) -> Void)? = nil) {
		self.title = title
		self.dismissAlertView = dismissAlert
		self.actionHandler = handler
	}
}
// -------------------------------------------------------------------------------------------------------------------------------------