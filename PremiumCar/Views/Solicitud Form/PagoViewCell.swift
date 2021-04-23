//
//  PagoViewCell.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/28/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

protocol PagoCellDelegate: class {
  func voucherSwitch(_ controller: PagoViewCell, voucherSelected isSelected: Bool)
}

class PagoViewCell: UITableViewCell {
  
  weak var delegate: PagoCellDelegate?
  
  @IBOutlet weak var referenciaText: UITextField!
  @IBOutlet weak var formaPagoSwitch: UISegmentedControl!
  @IBOutlet weak var formaPagoImg: UIImageView!
  @IBOutlet weak var formaPagoSwitchWidth: NSLayoutConstraint!
  @IBOutlet weak var efectivoText: UILabel!
  
  func initContent(isCorporativo: Bool){
    self.formaPagoSwitch.customColor()
    self.referenciaText.setBottomBorder(borderColor: Customization.bottomBorderColor)
    if globalVariables.cliente.empresa != ""{
      //self.formaPagoSwitch.insertSegment(withTitle: "Voucher", at: 2, animated: false)
      self.formaPagoSwitch.selectedSegmentIndex = 1
      self.formaPagoImg.image = UIImage(named: "voucherIcon")
      self.delegate?.voucherSwitch(self, voucherSelected: true)
    }
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

extension PagoViewCell{
  func voucherSwitch(_ controller: PagoViewCell, voucherSelected isSelected: Bool){}
}

