//
//  General.swift
//
//  Created by Shuyang Sun on 3/4/16.
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

let defaultAnimationDuration = 0.4

let mdAlertViewBackgroundColor = UIColor.whiteColor()
let mdAlertViewTitleTextColor = UIColor(hex: 0x000000, alpha: MDDarkTextPrimaryAlpha)
let mdAlertViewMessageTextColor = UIColor(hex: 0x000000, alpha: MDDarkTextSecondaryAlpha)
let mdAlertControllerBackgroundColor = UIColor(hex: 0x000, alpha: 0.65)
let mdAlertControllerButtonTextColorNormal = MDColorPalette.Blue.A400!
let mdAlertControllerButtonTextColorHighlighted = MDColorPalette.Blue.A200!
let mdAlertControllerButtonTapFeedbackColor = MDColorPalette.Blue.A100!

let mdAlertViewCornerRadius:CGFloat = 3.0
let mdAlertMaxWidth:CGFloat = 450
let mdAlertTitleFontSize:CGFloat = 18
let mdAlertMessageFontSize:CGFloat = 18
let mdAlertButtonFontSize:CGFloat = 16
let mdAlertButtonHeight:CGFloat = 60
let mdAlertPaddingVertical:CGFloat = 15
let mdAlertPaddingHorizontal:CGFloat = 20
let mdAlertMarginHorizontal:CGFloat = 35
let mdAlertMarginVertical:CGFloat = mdAlertButtonHeight
let mdAlertMinHeight:CGFloat = 150

let okButtonTitle = NSLocalizedString("OK", comment: "Title for ok button on alert view.")

func getAttributedStringFrom(text:String?, withFontSize fontSize:CGFloat = UIFont.systemFontSize(), color:UIColor = UIColor.blackColor(), bold:Bool = false) -> NSMutableAttributedString? {
	return text == nil ? nil : NSMutableAttributedString(string: text!, attributes:
		[NSFontAttributeName: bold ? UIFont.boldSystemFontOfSize(fontSize) : UIFont.systemFontOfSize(fontSize),
			NSForegroundColorAttributeName: color])
}