//
//  Customization.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit

struct Customization {
  static var serverData: String!
  static var appName: String!
  static var nameShowed: String = "PremiumCar"
  static var logo: UIImage!
  static var primaryColor: UIColor = .white //#1f1f1f
  static var secundaryColor: UIColor = UIColor(red: 222/255, green: 11/255, blue: 19/255, alpha: 1)
  static var viewBackgroundColor: UIColor = UIColor(red: 7/255, green: 9/255, blue: 24/255, alpha: 1)
  static var lightTextColor: UIColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
  static var textColor: UIColor = UIColor.darkGray
  static var iconColor: UIColor = UIColor.lightGray
  static var buttonActionColor: UIColor = secundaryColor
  static var buttonsTitleColor = primaryColor
  static var menuBackgroundColor = primaryColor
  static var menuTextColor = textColor
  static var startColor = secundaryColor
  static var tabBorderColor = secundaryColor
  static var textFieldBackColor: UIColor = primaryColor
  static var customBlueColor: UIColor = UIColor(red: 14/255, green: 37/255, blue: 92/255, alpha: 1)
  static var bottomBorderColor: UIColor = textColor
  static var usaVoucher: Bool = true
}

struct CustomAppFont {
  static var appFontFamily = "Muli"
  static var appBoldFontFamily = "Muli-Bold"
  static var appMediumFontFamily = "Muli-MemiBold"
  static var bigFont = UIFont(name: appBoldFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 3.5))
  static var titleFont = UIFont(name: appBoldFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.2))
  static var inputTextFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.7))
  static var subtitleFont = UIFont(name: appMediumFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.0))
  static var buttonFont = UIFont(name: appMediumFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 2.0))
  static var normalFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.8))
  static var smallFont = UIFont(name: appFontFamily, size: globalVariables.responsive.heightFloatPercent(percent: 1.6))
}


