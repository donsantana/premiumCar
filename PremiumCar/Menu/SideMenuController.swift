//
//  SideMenuController.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 11/25/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuController: UIViewController {
  
  var menuArray = [[MenuData(imagen: "nuevaSolicitud", title: "Nuevo viaje"),MenuData(imagen: "enProceso", title: "Viajes en proceso"),MenuData(imagen: "historial", title: "Historial de Viajes")],[MenuData(imagen: "callCenter", title: "Operadora"),MenuData(imagen: "terminos", title: "Términos y condiciones"),MenuData(imagen: "compartir", title: "Compartir app")],[MenuData(imagen: "salir2", title: "Salir")]]//,MenuData(imagen: "card", title: "Mis tarjetas")
  
  @IBOutlet weak var MenuView1: UIView!
  @IBOutlet weak var MenuTable: UITableView!
  @IBOutlet weak var NombreUsuario: UILabel!
  @IBOutlet weak var yapaText: UILabel!
  @IBOutlet weak var userProfilePhoto: UIImageView!
  @IBOutlet weak var userDataView: UIView!
  
  @IBOutlet weak var menuHeaderHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var yapaTextHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var yapaIcon: UIImageView!
  @IBOutlet weak var yapaTitle: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .white
    
    self.MenuTable.delegate = self
    self.MenuView1.backgroundColor = Customization.menuBackgroundColor
    self.MenuView1.layer.borderColor = Customization.menuTextColor.cgColor
    self.MenuView1.layer.borderWidth = 0.3
    self.MenuView1.layer.masksToBounds = false
    
    self.NombreUsuario.text = "¡Hola, \(globalVariables.cliente.nombreApellidos.uppercased())!"
    self.NombreUsuario.textColor = Customization.menuTextColor
    //self.NombreUsuario.font = CustomAppFont.subtitleFont
    globalVariables.cliente.cargarPhoto(imageView: self.userProfilePhoto)
    
    self.userDataView.backgroundColor = Customization.menuBackgroundColor
    self.yapaTitle.textColor = Customization.menuTextColor
    self.yapaIcon.addCustomTintColor(customColor: Customization.menuTextColor)
    
    self.menuHeaderHeightConstraint.constant = Responsive().heightFloatPercent(percent: 29)
    self.yapaTextHeightConstraint.constant = Responsive().heightFloatPercent(percent: 6)
    self.yapaText.addBorder(color: Customization.menuTextColor)
    self.yapaText.textColor = Customization.menuTextColor
    self.yapaText.text = "$\(globalVariables.cliente.yapa)"
    //self.yapaText.font = CustomAppFont.bigFont
    
    if !globalVariables.appConfig.yapa {
      NSLayoutConstraint(item: self.userDataView, attribute: .centerY, relatedBy: .equal, toItem: self.MenuTable, attribute: .top, multiplier: 1, constant: 5).isActive = true
    }
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showYapaView))
    //tapGesture.delegate = self
    self.yapaText.addGestureRecognizer(tapGesture)
  }
  
  //MASK:- FUNCTIONS
  @objc func showYapaView(){
    let vc = R.storyboard.main.yapaView()!
    self.navigationController?.show(vc, sender: nil)
  }
  
  @objc func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        globalVariables.socket.emit("data",datos)
        print(datos)
        //self.EnviarTimer(estado: 1, datos: datos)
      }else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      ErrorConexion()
    }
  }
  
  func ErrorConexion(){
    //self.CargarTelefonos()
    //AlertaSinConexion.isHidden = false
    
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func CloseAPP(){
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
      
    }
    print("closing app")
    let datos = "#SocketClose,\(globalVariables.cliente.id),# \n"
    EnviarSocket(datos)
    exit(3)
  }
  
  @IBAction func showProfile(_ sender: Any) {
    let vc = R.storyboard.main.perfil()!
    self.navigationController?.show(vc, sender: nil)
  }
}
