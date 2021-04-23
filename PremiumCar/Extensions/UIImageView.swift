//
//  UIImageView.swift
//  Servicaren
//
//  Created by Donelkys Santana on 3/12/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import UIKit


extension UIImageView{
  func addCustomTintColor(customColor: UIColor){
    self.image = self.image!.withRenderingMode(.alwaysTemplate)
    self.tintColor = customColor
  }
  
}
