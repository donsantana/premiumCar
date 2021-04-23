//
//  PagoViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

protocol PagoYapaCellDelegate: class {
  func voucherSwitch(_ controller: PagoYapaViewCell, voucherSelected isSelected: Bool)
}

class PagoYapaViewCell: UITableViewCell {
  
  weak var delegate: PagoYapaCellDelegate?
  
  @IBOutlet weak var referenciaText: UITextField!
  @IBOutlet weak var formaPagoSwitch: UISegmentedControl!
  @IBOutlet weak var formaPagoImg: UIImageView!
  @IBOutlet weak var yapaValue: UILabel!
  @IBOutlet weak var pagarYapaSwitch: UISwitch!
  @IBOutlet weak var formaPagoSwitchWidth: NSLayoutConstraint!
  @IBOutlet weak var efectivoText: UILabel!
  
  func initContent(isCorporativo: Bool){
    self.formaPagoSwitch.customColor()
    self.referenciaText.setBottomBorder(borderColor: Customization.bottomBorderColor)
    pagarYapaSwitch.isEnabled = globalVariables.cliente.yapa > 0
    if globalVariables.cliente.empresa != ""{
      //self.formaPagoSwitch.insertSegment(withTitle: "Voucher", at: 2, animated: false)
      self.formaPagoSwitch.selectedSegmentIndex = 1
      self.formaPagoImg.image = UIImage(named: "voucherIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: true)
    }
    
    //self.efectivoText.font = CustomAppFont.subtitleFont
    
    
  }
  
  func updateVoucherOption(useVoucher: Bool){
    self.initContent(isCorporativo: useVoucher)
    self.formaPagoSwitch.isHidden = !useVoucher || globalVariables.cliente.empresa == ""
//    if useVoucher{
//      if globalVariables.cliente.empresa != ""{
//        //self.formaPagoSwitch.insertSegment(withTitle: "Voucher", at: 2, animated: false)
//      }
//    }else{
//      //self.formaPagoSwitch.removeSegment(at: 2, animated: false)
//    }
    self.yapaValue.text = ("Pagar con Yapa, $\(String(format: "%.2f", globalVariables.cliente.yapa))")
    self.formaPagoSwitchWidth.constant = CGFloat(70 * self.formaPagoSwitch.numberOfSegments)
  }
  
  @IBAction func didChanged(_ sender: Any) {
    switch self.formaPagoSwitch.selectedSegmentIndex {
    case 0:
      formaPagoImg.image = UIImage(named: "ofertaIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: false)
    case 1:
      self.formaPagoImg.image = UIImage(named: "voucherIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: true)
    case 2:
      self.formaPagoImg.image = UIImage(named: "tarjetaIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: false)
    default:
      break
    }
    
  }
}

extension PagoYapaViewCell{
  func voucherSwitch(_ controller: PagoYapaViewCell, voucherSelected isSelected: Bool){}
}

