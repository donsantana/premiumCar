//
//  PanicoController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 12/7/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit

class PanicoController: UIViewController {
  
  @IBOutlet weak var llamarBtn: UIButton!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var panicIcon: UIImageView!
  
  override func viewDidLoad() {
    self.contentView.addShadow()
    self.panicIcon.image = UIImage(named: "panicoBtn")?.withRenderingMode(.alwaysTemplate)
    self.panicIcon.layer.cornerRadius = self.panicIcon.frame.width/2
    self.panicIcon.backgroundColor = Customization.buttonActionColor.withAlphaComponent(0.5)
    self.panicIcon.tintColor = Customization.buttonsTitleColor
    self.llamarBtn.customBackgroundTitleColor(titleColor: nil, backgroundColor: nil)
  }
  
  @IBAction func closePanicoView(_ sender: Any) {
    self.removeContainer()
  }
  
  @IBAction func llamar911(_ sender: Any) {
    if let url = URL(string: "tel://911") {
      UIApplication.shared.open(url)
    }
    self.removeContainer()
  }
  
}
