//
//  MaterialDesign.swift
//
//  Created by Shuyang Sun on 11/29/15.
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

public extension UIColor {

	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Initialize a UIColor with hexadecimal value and alpha.
	- Parameters:
		- hex: The hexadecimal value for the color, can be represented as 0xAABBCC.
		- alpha: The alpha value for transparency, between 0 and 1.0. 0 Is transparent, 1 is opaque.
	*/
	public convenience init(hex:Int, alpha:CGFloat = 1.0) {
		let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
		let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
		let blue = CGFloat(hex & 0xFF) / 255.0
		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}
	// -------------------------------------------------------------------------------------------------------------------------------------

	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
		-Returns: The hexadecimal value of caller (does not contain alpha information).
	*/
	public var hex:Int {
		var r:CGFloat = 0
		var g:CGFloat = 0
		var b:CGFloat = 0
		var a:CGFloat = 0
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		return Int(r * 255.0) << 16 + Int(g * 255.0) << 8 + Int(b * 255.0)
	}
	// -------------------------------------------------------------------------------------------------------------------------------------

	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Returns the current UIColor with specified alpha value.
	- Parameters:
		- alpha: The alpha value for transparency, between 0 and 1.0. 0 Is transparent, 1 is opaque.
	- Returns: The UIColor which called this method with specified alpha.
	*/
	public func colorWithAlpha(alpha:CGFloat) -> UIColor {
		return UIColor(hex: self.hex, alpha: alpha)
	}
	// -------------------------------------------------------------------------------------------------------------------------------------
}

/**
 This class is designed to identify which layer is used for shadow display, it's just a subclass of CALayer.
*/
class ShadowLayer: CALayer { /*** Nothing Here ***/ }

public extension UIView {
	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Call this method on UIView to add Material Design shadow on the caller. You can specify the shadow depth and shadow color.

	WARNNING: This shadow will stay with the view, but it is static instead of dynamic. Because of that, this method's performance is significantly better than setting shadow properties on CALayer. However, since it's dynamic, you should update shadow accordingly by recalling this method whenever your view's shape changes.
	- Parameters:
		- shadowDepth: The depth value for shadow, it should be an integer ranging from 0 to 5. Any value outside this range will be ignored. 0 means "no shadow", 5 means "deepest shadow". Elements on a higher level of hierarchy (floating higher) should have higher value.
		- shadowColor (default=black): The color of this shadow. Specifying alpha value for color will have effects on the shadow, but this is not recomended since default alpha value for each shadow level will be added. Specifying alpha value for shadowColor may confused user for the level of hierarchy.
	*/
	public func addMDShadow(withDepth shadowDepth:Int?, shadowColor:UIColor = UIColor.blackColor()) {
		// If all the condition meets, add the shadow.
		if let depth = shadowDepth {
			if depth >= 1 && depth <= 5 {
				let topLayer = self.layer
				var bottomLayer:CALayer! = nil
				var foundExistingShadowLayer = false
				if let subLayers = self.layer.sublayers {
					for subLayer in subLayers {
						// If there existed a shadow layer
						if subLayer is ShadowLayer {
							bottomLayer = subLayer
							foundExistingShadowLayer = true
						}
					}
				}
				if !foundExistingShadowLayer {
					bottomLayer = ShadowLayer()
					bottomLayer.frame = self.layer.bounds
					bottomLayer.backgroundColor = UIColor.clearColor().CGColor
					// Adding bottom layer will cause some unwanted effects for now, need to be fixed.
					//					self.layer.addSublayer(bottomLayer)
				}

				typealias ShadowProperties = (alpha:CGFloat, xOffset:CGFloat, yOffset:CGFloat, blur:CGFloat)
				var shadowValues:(topShadowProperties:ShadowProperties, bottomShadowProperties:ShadowProperties)?
				switch depth {
				case 1: shadowValues = ((0.12, 0, 1, 1.5), (0.24, 0, 1, 1))
				case 2:	shadowValues = ((0.16, 0, 3, 3), (0.23, 0, 3, 3))
				case 3:	shadowValues = ((0.19, 0, 10, 10), (0.23, 0, 6, 3))
				case 4:	shadowValues = ((0.25, 0, 14, 14), (0.22, 0, 10, 5))
				case 5:	shadowValues = ((0.30, 0, 19, 19), (0.22, 0, 15, 6))
				default: shadowValues = nil
				}

				if let shadowVal = shadowValues {
					var r:CGFloat = 0
					var g:CGFloat = 0
					var b:CGFloat = 0
					var a:CGFloat = 0
					shadowColor.getRed(&r, green: &g, blue: &b, alpha: &a)

					let topLayerShadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width + 1, height: self.bounds.height + 1), cornerRadius: self.layer.cornerRadius)
					topLayer.shadowPath = topLayerShadowPath.CGPath
					topLayer.shadowColor = UIColor(red: r, green: g, blue: b, alpha: shadowVal.topShadowProperties.alpha).CGColor
					topLayer.shadowOffset = CGSize(width: shadowVal.topShadowProperties.xOffset, height: shadowVal.topShadowProperties.yOffset)
					topLayer.shadowRadius = shadowVal.topShadowProperties.blur
					topLayer.shadowOpacity = 1.0

					let bottomLayerShadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width + 1, height: self.bounds.height + 1), cornerRadius: self.layer.cornerRadius)
					bottomLayer.shadowPath = bottomLayerShadowPath.CGPath
					bottomLayer.shadowColor = UIColor(red: r, green: g, blue: b, alpha: shadowVal.bottomShadowProperties.alpha).CGColor
					bottomLayer.shadowOffset = CGSize(width: shadowVal.bottomShadowProperties.xOffset, height: shadowVal.bottomShadowProperties.yOffset)
					bottomLayer.shadowRadius = shadowVal.bottomShadowProperties.blur
					bottomLayer.shadowOpacity = 1.0
				}
			}
		}

		if shadowDepth == nil || shadowDepth! < 1 || shadowDepth! > 5 {
			self.layer.shadowPath = nil
			self.layer.shadowColor = UIColor.clearColor().CGColor
			if let subLayers = self.layer.sublayers {
				for subLayer in subLayers {
					// If there existed a shadow layer
					if subLayer is ShadowLayer {
						subLayer.shadowPath = nil
						subLayer.shadowColor = UIColor.clearColor().CGColor
					}
				}
			}
		}
	}
	// -------------------------------------------------------------------------------------------------------------------------------------

	// -------------------------------------------------------------------------------------------------------------------------------------
	/**
	Call this method on UIView to trigger Material Design style tap feedback at a certain location. It generates a water ripple effect from the starting point.
	- Parameters:
		- location: The location to start tap feedback. Usually this value should be a CGPoint that is inside the view's bounds, but you can start it ouside the view's bounds.
		- color (default=white): The color of water ripple. Specifying the alpha value for this color will effect the alpha value of the tap feedback, it is up to you to use any color or alpha you want. However, the actually alpha value is half of the original color, because we don't want to make the feedback opaque so it blocks the actuall view. So feel free to leave the alpha for color as 1.0, it will be rendered as 0.5.
		- duration (default=0.4): How many seconds this tap feedback should animate.
		- showSurfaceReaction (default=true): When this value is true, there will be another layer of animation below the water ripple effect, which is default for Material Design.
		- atBottom (default=true): Determines if the feedback animation should apear on top or bottom of the view hierarchy. Most of the time we want it at bottom so it doens't cover any subviews. However, if there are subviews on this view that make this animation unatrual, set it to false so it will happen at the top of view hierarchy.
		- completion (default=nil): A completion block for submitting actions after the feedback animation is over.
	*/
	public func triggerTapFeedBack(atLocation location:CGPoint, withColor color:UIColor = UIColor.whiteColor(), let duration:NSTimeInterval = defaultAnimationDuration, showSurfaceReaction:Bool = true, atBottom:Bool = true, completion: ((Void) -> Void)? = nil) {
		
		let overlayView = UIView(frame: self.bounds)
		overlayView.clipsToBounds = true
		overlayView.layer.cornerRadius = self.layer.cornerRadius
		overlayView.backgroundColor = UIColor.clearColor()

		let surfaceReactionView = UIView(frame: overlayView.bounds)
		if showSurfaceReaction {
			var r:CGFloat = 0
			var g:CGFloat = 0
			var b:CGFloat = 0
			var a:CGFloat = 0
			color.getRed(&r, green: &g, blue: &b, alpha: &a)
			surfaceReactionView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a/2.0)
			surfaceReactionView.opaque = false
			surfaceReactionView.alpha = 0.0
			overlayView.addSubview(surfaceReactionView)
		}

		let feedBackView = UIView(frame: CGRect(x: location.x, y: location.y, width: 2, height: 2))
		feedBackView.backgroundColor = color
		feedBackView.layer.cornerRadius = 1
		feedBackView.opaque = false
		feedBackView.alpha = 0.0
		overlayView.addSubview(feedBackView)
		if atBottom {
			self.insertSubview(overlayView, atIndex: 0)
		} else {
			self.addSubview(overlayView)
		}

		let dtXLeftSquare = location.x * location.x
		let	dtYTopSquare = location.y * location.y
		let dtXRightSquare = (self.bounds.width - location.x) * (self.bounds.width - location.x)
		let dtYBottomSquare = (self.bounds.height - location.y) * (self.bounds.height - location.y)
		let topLeftDistance = sqrt(dtXLeftSquare + dtYTopSquare)
		let topRightDistance = sqrt(dtXRightSquare + dtYTopSquare)
		let bottomLeftDistance = sqrt(dtXLeftSquare + dtYBottomSquare)
		let bottomRightDistance = sqrt(dtXRightSquare + dtYBottomSquare)
		let scaleFactor = max(topLeftDistance, topRightDistance, bottomLeftDistance, bottomRightDistance) - self.layer.cornerRadius * 0.414

		if showSurfaceReaction {
			// Show surface reaction
			UIView.animateWithDuration(duration / 3.0,
				delay: 0.0,
				options: .CurveEaseIn,
				animations: {
					surfaceReactionView.alpha = 1.0
				}) { succeed in
					// Hide surface reaction
					UIView.animateWithDuration(duration * 2.0/3.0,
						delay: 0.0,
						options: .CurveEaseOut,
						animations: {
							surfaceReactionView.alpha = 0.0
						}) { succeed in
							surfaceReactionView.removeFromSuperview()
					}
			}
		}

		let circilAnimationDuration = showSurfaceReaction ? duration * 2.0/3.0 : duration

		// Expand the circle
		UIView.animateWithDuration(circilAnimationDuration,
			delay: 0.0,
			options: .CurveEaseOut,
			animations: {
				feedBackView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
			}) { succeed in
				feedBackView.removeFromSuperview()
				overlayView.removeFromSuperview()
				completion?()
		}

		// Show the circle
		UIView.animateWithDuration(circilAnimationDuration/8.0,
			delay: 0.0,
			options: .CurveEaseOut,
			animations: {
				feedBackView.alpha = 1.0
		}, completion: nil)

		// Hid the circle
		UIView.animateWithDuration(circilAnimationDuration * (1.0 - 1.0/8.0 - 1.0/3.0),
			delay: circilAnimationDuration * (1.0/8.0 + 1.0/3.0),
			options: .CurveEaseOut,
			animations: {
				feedBackView.alpha = 0.0
		}, completion: nil)
	}
	// -------------------------------------------------------------------------------------------------------------------------------------
}

// -------------------------------------------------------------------------------------------------------------------------------------
/**
 A enum getting the colors from Material Design color palette. Use .P# or .A# to get primary color or accent color for a specific color palette respectively.
*/
public enum MDColorPalette:String {
	case Red = "Red", Pink = "Pink", Purple = "Purple", DeepPurple = "Deep Purple", Indigo = "Indigo", Blue = "Blue", LightBlue = "Light Blue", Cyan = "Cyan", Teal = "Teal", Green = "Green", LightGreen = "Light Green", Lime = "Lime", Yellow = "Yellow", Amber = "Amber", Orange = "Orange", DeepOrange = "Deep Orange", Brown = "Brown", Grey = "Grey", BlueGrey = "Blue Grey";

	public var P50:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xFFEBEE)
		case .Pink: return UIColor(hex: 0xFCE4EC)
		case .Purple: return UIColor(hex: 0xF3E5F5)
		case .DeepPurple: return UIColor(hex: 0x673AB7)
		case .Indigo: return UIColor(hex: 0xE8EAF6)
		case .Blue: return UIColor(hex: 0xE3F2FD)
		case .LightBlue: return UIColor(hex: 0xE1F5FE)
		case .Cyan: return UIColor(hex: 0xE0F7FA)
		case .Teal: return UIColor(hex: 0xE0F2F1)
		case .Green: return UIColor(hex: 0xE8F5E9)
		case .LightGreen: return UIColor(hex: 0xF1F8E9)
		case .Lime: return UIColor(hex: 0xF9FBE7)
		case .Yellow: return UIColor(hex: 0xFFFDE7)
		case .Amber: return UIColor(hex: 0xFFF8E1)
		case .Orange: return UIColor(hex: 0xFFF3E0)
		case .DeepOrange: return UIColor(hex: 0xFBE9E7)
		case .Brown: return UIColor(hex: 0xEFEBE9)
		case .Grey: return UIColor(hex: 0xFAFAFA)
		case .BlueGrey: return UIColor(hex: 0xECEFF1)
		}
	}

	public var P100:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xFFCDD2)
		case .Pink: return UIColor(hex: 0xF8BBD0)
		case .Purple: return UIColor(hex: 0xE1BEE7)
		case .DeepPurple: return UIColor(hex: 0xD1C4E9)
		case .Indigo: return UIColor(hex: 0xC5CAE9)
		case .Blue: return UIColor(hex: 0xBBDEFB)
		case .LightBlue: return UIColor(hex: 0xB3E5FC)
		case .Cyan: return UIColor(hex: 0xB2EBF2)
		case .Teal: return UIColor(hex: 0xB2DFDB)
		case .Green: return UIColor(hex: 0xC8E6C9)
		case .LightGreen: return UIColor(hex: 0xDCEDC8)
		case .Lime: return UIColor(hex: 0xF0F4C3)
		case .Yellow: return UIColor(hex: 0xFFF9C4)
		case .Amber: return UIColor(hex: 0xFFECB3)
		case .Orange: return UIColor(hex: 0xFFE0B2)
		case .DeepOrange: return UIColor(hex: 0xFFCCBC)
		case .Brown: return UIColor(hex: 0xD7CCC8)
		case .Grey: return UIColor(hex: 0xF5F5F5)
		case .BlueGrey: return UIColor(hex: 0xCFD8DC)
		}
	}

	public var P200:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xEF9A9A)
		case .Pink: return UIColor(hex: 0xF48FB1)
		case .Purple: return UIColor(hex: 0xCE93D8)
		case .DeepPurple: return UIColor(hex: 0xB39DDB)
		case .Indigo: return UIColor(hex: 0x9FA8DA)
		case .Blue: return UIColor(hex: 0x90CAF9)
		case .LightBlue: return UIColor(hex: 0x81D4FA)
		case .Cyan: return UIColor(hex: 0x80DEEA)
		case .Teal: return UIColor(hex: 0x80CBC4)
		case .Green: return UIColor(hex: 0xA5D6A7)
		case .LightGreen: return UIColor(hex: 0xC5E1A5)
		case .Lime: return UIColor(hex: 0xE6EE9C)
		case .Yellow: return UIColor(hex: 0xFFF59D)
		case .Amber: return UIColor(hex: 0xFFE082)
		case .Orange: return UIColor(hex: 0xFFCC80)
		case .DeepOrange: return UIColor(hex: 0xFFAB91)
		case .Brown: return UIColor(hex: 0xBCAAA4)
		case .Grey: return UIColor(hex: 0xEEEEEE)
		case .BlueGrey: return UIColor(hex: 0xB0BEC5)
		}
	}

	public var P300:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xE57373)
		case .Pink: return UIColor(hex: 0xF06292)
		case .Purple: return UIColor(hex: 0xBA68C8)
		case .DeepPurple: return UIColor(hex: 0x9575CD)
		case .Indigo: return UIColor(hex: 0x7986CB)
		case .Blue: return UIColor(hex: 0x64B5F6)
		case .LightBlue: return UIColor(hex: 0x4FC3F7)
		case .Cyan: return UIColor(hex: 0x4DD0E1)
		case .Teal: return UIColor(hex: 0x4DB6AC)
		case .Green: return UIColor(hex: 0x81C784)
		case .LightGreen: return UIColor(hex: 0xAED581)
		case .Lime: return UIColor(hex: 0xDCE775)
		case .Yellow: return UIColor(hex: 0xFFF176)
		case .Amber: return UIColor(hex: 0xFFD54F)
		case .Orange: return UIColor(hex: 0xFFB74D)
		case .DeepOrange: return UIColor(hex: 0xFF8A65)
		case .Brown: return UIColor(hex: 0xA1887F)
		case .Grey: return UIColor(hex: 0xE0E0E0)
		case .BlueGrey: return UIColor(hex: 0x90A4AE)
		}
	}

	public var P400:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xEF5350)
		case .Pink: return UIColor(hex: 0xEC407A)
		case .Purple: return UIColor(hex: 0xAB47BC)
		case .DeepPurple: return UIColor(hex: 0x7E57C2)
		case .Indigo: return UIColor(hex: 0x5C6BC0)
		case .Blue: return UIColor(hex: 0x42A5F5)
		case .LightBlue: return UIColor(hex: 0x29B6F6)
		case .Cyan: return UIColor(hex: 0x26C6DA)
		case .Teal: return UIColor(hex: 0x26A69A)
		case .Green: return UIColor(hex: 0x66BB6A)
		case .LightGreen: return UIColor(hex: 0x9CCC65)
		case .Lime: return UIColor(hex: 0xD4E157)
		case .Yellow: return UIColor(hex: 0xFFEE58)
		case .Amber: return UIColor(hex: 0xFFCA28)
		case .Orange: return UIColor(hex: 0xFFA726)
		case .DeepOrange: return UIColor(hex: 0xFF7043)
		case .Brown: return UIColor(hex: 0x8D6E63)
		case .Grey: return UIColor(hex: 0xBDBDBD)
		case .BlueGrey: return UIColor(hex: 0x78909C)
		}
	}

	public var P500:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xF44336)
		case .Pink: return UIColor(hex: 0xE91E63)
		case .Purple: return UIColor(hex: 0x9C27B0)
		case .DeepPurple: return UIColor(hex: 0x673AB7)
		case .Indigo: return UIColor(hex: 0x3F51B5)
		case .Blue: return UIColor(hex: 0x2196F3)
		case .LightBlue: return UIColor(hex: 0x03A9F4)
		case .Cyan: return UIColor(hex: 0x00BCD4)
		case .Teal: return UIColor(hex: 0x009688)
		case .Green: return UIColor(hex: 0x4CAF50)
		case .LightGreen: return UIColor(hex: 0x8BC34A)
		case .Lime: return UIColor(hex: 0xCDDC39)
		case .Yellow: return UIColor(hex: 0xFFEB3B)
		case .Amber: return UIColor(hex: 0xFFC107)
		case .Orange: return UIColor(hex: 0xFF9800)
		case .DeepOrange: return UIColor(hex: 0xFF5722)
		case .Brown: return UIColor(hex: 0x795548)
		case .Grey: return UIColor(hex: 0x9E9E9E)
		case .BlueGrey: return UIColor(hex: 0x607D8B)
		}
	}

	public var P600:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xE53935)
		case .Pink: return UIColor(hex: 0xD81B60)
		case .Purple: return UIColor(hex: 0x8E24AA)
		case .DeepPurple: return UIColor(hex: 0x5E35B1)
		case .Indigo: return UIColor(hex: 0x3949AB)
		case .Blue: return UIColor(hex: 0x1E88E5)
		case .LightBlue: return UIColor(hex: 0x039BE5)
		case .Cyan: return UIColor(hex: 0x00ACC1)
		case .Teal: return UIColor(hex: 0x00897B)
		case .Green: return UIColor(hex: 0x43A047)
		case .LightGreen: return UIColor(hex: 0x7CB342)
		case .Lime: return UIColor(hex: 0xC0CA33)
		case .Yellow: return UIColor(hex: 0xFDD835)
		case .Amber: return UIColor(hex: 0xFFB300)
		case .Orange: return UIColor(hex: 0xFB8C00)
		case .DeepOrange: return UIColor(hex: 0xF4511E)
		case .Brown: return UIColor(hex: 0x6D4C41)
		case .Grey: return UIColor(hex: 0x757575)
		case .BlueGrey: return UIColor(hex: 0x546E7A)
		}
	}

	public var P700:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xD32F2F)
		case .Pink: return UIColor(hex: 0xC2185B)
		case .Purple: return UIColor(hex: 0x7B1FA2)
		case .DeepPurple: return UIColor(hex: 0x512DA8)
		case .Indigo: return UIColor(hex: 0x303F9F)
		case .Blue: return UIColor(hex: 0x1976D2)
		case .LightBlue: return UIColor(hex: 0x0288D1)
		case .Cyan: return UIColor(hex: 0x0097A7)
		case .Teal: return UIColor(hex: 0x00796B)
		case .Green: return UIColor(hex: 0x388E3C)
		case .LightGreen: return UIColor(hex: 0x689F38)
		case .Lime: return UIColor(hex: 0xAFB42B)
		case .Yellow: return UIColor(hex: 0xFBC02D)
		case .Amber: return UIColor(hex: 0xFFA000)
		case .Orange: return UIColor(hex: 0xF57C00)
		case .DeepOrange: return UIColor(hex: 0xE64A19)
		case .Brown: return UIColor(hex: 0x5D4037)
		case .Grey: return UIColor(hex: 0x616161)
		case .BlueGrey: return UIColor(hex: 0x455A64)
		}
	}

	public var P800:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xC62828)
		case .Pink: return UIColor(hex: 0xAD1457)
		case .Purple: return UIColor(hex: 0x6A1B9A)
		case .DeepPurple: return UIColor(hex: 0x4527A0)
		case .Indigo: return UIColor(hex: 0x283593)
		case .Blue: return UIColor(hex: 0x1565C0)
		case .LightBlue: return UIColor(hex: 0x0277BD)
		case .Cyan: return UIColor(hex: 0x00838F)
		case .Teal: return UIColor(hex: 0x00695C)
		case .Green: return UIColor(hex: 0x2E7D32)
		case .LightGreen: return UIColor(hex: 0x558B2F)
		case .Lime: return UIColor(hex: 0x9E9D24)
		case .Yellow: return UIColor(hex: 0xF9A825)
		case .Amber: return UIColor(hex: 0xFF8F00)
		case .Orange: return UIColor(hex: 0xEF6C00)
		case .DeepOrange: return UIColor(hex: 0xD84315)
		case .Brown: return UIColor(hex: 0x4E342E)
		case .Grey: return UIColor(hex: 0x424242)
		case .BlueGrey: return UIColor(hex: 0x37474F)
		}
	}

	public var P900:UIColor {
		switch self {
		case .Red: return UIColor(hex: 0xB71C1C)
		case .Pink: return UIColor(hex: 0x880E4F)
		case .Purple: return UIColor(hex: 0x4A148C)
		case .DeepPurple: return UIColor(hex: 0x311B92)
		case .Indigo: return UIColor(hex: 0x1A237E)
		case .Blue: return UIColor(hex: 0x0D47A1)
		case .LightBlue: return UIColor(hex: 0x01579B)
		case .Cyan: return UIColor(hex: 0x006064)
		case .Teal: return UIColor(hex: 0x004D40)
		case .Green: return UIColor(hex: 0x1B5E20)
		case .LightGreen: return UIColor(hex: 0x33691E)
		case .Lime: return UIColor(hex: 0x827717)
		case .Yellow: return UIColor(hex: 0xF57F17)
		case .Amber: return UIColor(hex: 0xFF6F00)
		case .Orange: return UIColor(hex: 0xE65100)
		case .DeepOrange: return UIColor(hex: 0xBF360C)
		case .Brown: return UIColor(hex: 0x3E2723)
		case .Grey: return UIColor(hex: 0x212121)
		case .BlueGrey: return UIColor(hex: 0x263238)
		}
	}

	public var A100:UIColor? {
		switch self {
		case .Red: return UIColor(hex: 0xFF8A80)
		case .Pink: return UIColor(hex: 0xFF80AB)
		case .Purple: return UIColor(hex: 0xEA80FC)
		case .DeepPurple: return UIColor(hex: 0xB388FF)
		case .Indigo: return UIColor(hex: 0x8C9EFF)
		case .Blue: return UIColor(hex: 0x82B1FF)
		case .LightBlue: return UIColor(hex: 0x80D8FF)
		case .Cyan: return UIColor(hex: 0x84FFFF)
		case .Teal: return UIColor(hex: 0xA7FFEB)
		case .Green: return UIColor(hex: 0xB9F6CA)
		case .LightGreen: return UIColor(hex: 0xCCFF90)
		case .Lime: return UIColor(hex: 0xF4FF81)
		case .Yellow: return UIColor(hex: 0xFFFF8D)
		case .Amber: return UIColor(hex: 0xFFE57F)
		case .Orange: return UIColor(hex: 0xFFD180)
		case .DeepOrange: return UIColor(hex: 0xFF9E80)
		case .Brown: return nil
		case .Grey: return nil
		case .BlueGrey: return nil
		}
	}

	public var A200:UIColor? {
		switch self {
		case .Red: return UIColor(hex: 0xFF5252)
		case .Pink: return UIColor(hex: 0xFF4081)
		case .Purple: return UIColor(hex: 0xE040FB)
		case .DeepPurple: return UIColor(hex: 0x7C4DFF)
		case .Indigo: return UIColor(hex: 0x536DFE)
		case .Blue: return UIColor(hex: 0x448AFF)
		case .LightBlue: return UIColor(hex: 0x40C4FF)
		case .Cyan: return UIColor(hex: 0x18FFFF)
		case .Teal: return UIColor(hex: 0x64FFDA)
		case .Green: return UIColor(hex: 0x69F0AE)
		case .LightGreen: return UIColor(hex: 0xB2FF59)
		case .Lime: return UIColor(hex: 0xEEFF41)
		case .Yellow: return UIColor(hex: 0xFFFF00)
		case .Amber: return UIColor(hex: 0xFFD740)
		case .Orange: return UIColor(hex: 0xFFAB40)
		case .DeepOrange: return UIColor(hex: 0xFF6E40)
		case .Brown: return nil
		case .Grey: return nil
		case .BlueGrey: return nil
		}
	}

	public var A400:UIColor? {
		switch self {
		case .Red: return UIColor(hex: 0xFF1744)
		case .Pink: return UIColor(hex: 0xF50057)
		case .Purple: return UIColor(hex: 0xD500F9)
		case .DeepPurple: return UIColor(hex: 0x651FFF)
		case .Indigo: return UIColor(hex: 0x3D5AFE)
		case .Blue: return UIColor(hex: 0x2979FF)
		case .LightBlue: return UIColor(hex: 0x00B0FF)
		case .Cyan: return UIColor(hex: 0x00E5FF)
		case .Teal: return UIColor(hex: 0x1DE9B6)
		case .Green: return UIColor(hex: 0x00E676)
		case .LightGreen: return UIColor(hex: 0x76FF03)
		case .Lime: return UIColor(hex: 0xC6FF00)
		case .Yellow: return UIColor(hex: 0xFFEA00)
		case .Amber: return UIColor(hex: 0xFFC400)
		case .Orange: return UIColor(hex: 0xFF9100)
		case .DeepOrange: return UIColor(hex: 0xFF3D00)
		case .Brown: return nil
		case .Grey: return nil
		case .BlueGrey: return nil
		}
	}

	public var A700:UIColor? {
		switch self {
		case .Red: return UIColor(hex: 0xD50000)
		case .Pink: return UIColor(hex: 0xC51162)
		case .Purple: return UIColor(hex: 0xAA00FF)
		case .DeepPurple: return UIColor(hex: 0x6200EA)
		case .Indigo: return UIColor(hex: 0x304FFE)
		case .Blue: return UIColor(hex: 0x2962FF)
		case .LightBlue: return UIColor(hex: 0x0091EA)
		case .Cyan: return UIColor(hex: 0x00B8D4)
		case .Teal: return UIColor(hex: 0x00BFA5)
		case .Green: return UIColor(hex: 0x00C853)
		case .LightGreen: return UIColor(hex: 0x64DD17)
		case .Lime: return UIColor(hex: 0xAEEA00)
		case .Yellow: return UIColor(hex: 0xFFD600)
		case .Amber: return UIColor(hex: 0xFFAB00)
		case .Orange: return UIColor(hex: 0xFF6D00)
		case .DeepOrange: return UIColor(hex: 0xDD2C00)
		case .Brown: return nil
		case .Grey: return nil
		case .BlueGrey: return nil
		}
	}

	public var Main:UIColor {
		return self.P500
	}
}
// -------------------------------------------------------------------------------------------------------------------------------------

// -------------------------------------------------------------------------------------------------------------------------------------
/*
 Alpha values for primay, secondary and hint text.
 */
public let MDDarkTextPrimaryAlpha:CGFloat = 0.87
public let MDDarkTextSecondaryAlpha:CGFloat = 0.54
public let MDDarkTextHintAlpha:CGFloat = 0.38

public let MDLightTextPrimaryAlpha:CGFloat = 1.0
public let MDLightTextSecondaryAlpha:CGFloat = 0.70
public let MDLightTextHintAlpha:CGFloat = 0.30
// -------------------------------------------------------------------------------------------------------------------------------------
