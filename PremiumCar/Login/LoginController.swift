//
//  LoginController.swift
//  UnTaxi
//
//  Created by Done Santana on 26/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import SocketIO
import CoreLocation
import GoogleMobileAds
import LocalAuthentication

class LoginController: UIViewController, CLLocationManagerDelegate{
  
  var login = [String]()
  var solitudespdtes = [Solicitud]()
  var coreLocationManager: CLLocationManager!
  var EnviosCount = 0
  var emitTimer = Timer()
  // var conexion = CSocket()
  
  //    var ServersData = [String]()
  //    var ServerParser = XMLParser()
  //    var recordKey = ""
  //    let dictionaryKeys = ["ip","p"]
  
  var results = [[String: String]]()                // the whole array of dictionaries
  var currentDictionary = [String : String]()    // the current dictionary
  var currentValue: String = ""                   // the current value for one of the keys in the dictionary
  
  var socketIOManager: SocketManager! //SocketManager(socketURL: URL(string: "http://www.xoait.com:5803")!, config: [.log(true), .forcePolling(true)])
  
  var apiService = ApiService()
  var socketService = SocketService()
  
  let myContext = LAContext()
  
  //MARK:- VARIABLES INTERFAZ
  
  @IBOutlet weak var loginBackView: UIView!
  @IBOutlet weak var usuario: UITextField!
  @IBOutlet weak var clave: UITextField!
  
  @IBOutlet weak var autenticarBtn: UIButton!
  @IBOutlet weak var AutenticandoView: UIView!
  @IBOutlet weak var closeRecoverViewBtn: UIButton!
  @IBOutlet weak var closeNewPassViewBtn: UIButton!
  @IBOutlet weak var closeRegisterViewBtn: UIButton!
  
  
  @IBOutlet weak var DatosView: UIView!
  @IBOutlet weak var olvideClaveBtn: UIButton!
  @IBOutlet weak var claveRecoverView: UIView!
  @IBOutlet weak var movilClaveRecover: UITextField!
  @IBOutlet weak var RecuperarClaveBtn: UIButton!
  @IBOutlet weak var recoverDataView: UIView!
  @IBOutlet weak var showHideClaveBtn: UIButton!
  @IBOutlet weak var showHideRegistroBtn: UIButton!
  @IBOutlet weak var showHideConfirmClave: UIButton!
  
  
  @IBOutlet weak var RegistroView: UIView!
  @IBOutlet weak var nombreApText: UITextField!
  @IBOutlet weak var claveText: UITextField!
  @IBOutlet weak var confirmarClavText: UITextField!
  @IBOutlet weak var correoText: UITextField!
  @IBOutlet weak var telefonoText: UITextField!
  @IBOutlet weak var RecomendadoText: UITextField!
  @IBOutlet weak var RegistroBtn: UIButton!
  @IBOutlet weak var correoTextTop: NSLayoutConstraint!
  @IBOutlet weak var registerDataView: UIView!
  @IBOutlet weak var crearCuentaBtn: UIButton!
  
  //Recover Password
  @IBOutlet weak var NewPasswordView: UIView!
  @IBOutlet weak var codigoText: UITextField!
  @IBOutlet weak var newPasswordText: UITextField!
  @IBOutlet weak var passwordMatch: UITextField!
  @IBOutlet weak var crearNewPasswordText: UIButton!
  
  
  //CONSTRAINTS DEFINITION
  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
  
  @IBOutlet weak var creaUsuarioBottom: NSLayoutConstraint!
  @IBOutlet weak var nombreTextBottom: NSLayoutConstraint!
  @IBOutlet weak var telefonoTextBottom: NSLayoutConstraint!
  @IBOutlet weak var claveTextBottom: NSLayoutConstraint!
  @IBOutlet weak var recomendadoLabelTop: NSLayoutConstraint!
  @IBOutlet weak var recomendadoTextTop: NSLayoutConstraint!
  @IBOutlet weak var registrarTop: NSLayoutConstraint!
  @IBOutlet weak var movilClaveRecoverHeight: NSLayoutConstraint!
  @IBOutlet weak var loginDatosViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var newPasswordFormHeight: NSLayoutConstraint!
  
  @IBOutlet weak var showPoliticasBtn: UIButton!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    globalVariables.userDefaults = UserDefaults.standard
    
    self.coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    coreLocationManager.requestWhenInUseAuthorization()
    
    //telefonoText.delegate = self
    claveText.delegate = self
    correoText.delegate = self
    self.movilClaveRecover.delegate = self
    confirmarClavText.delegate = self
    clave.delegate = self
    self.RecomendadoText.delegate = self
    self.apiService.delegate = self
    self.socketService.delegate = self
    
    self.autenticarBtn.customBackgroundTitleColor(titleColor: Customization.buttonsTitleColor, backgroundColor: Customization.buttonActionColor)
    self.RecuperarClaveBtn.customBackgroundTitleColor(titleColor: Customization.buttonsTitleColor, backgroundColor: Customization.buttonActionColor)
    self.crearNewPasswordText.customBackgroundTitleColor(titleColor: Customization.buttonsTitleColor, backgroundColor: Customization.buttonActionColor)
    self.crearCuentaBtn.customBackgroundTitleColor(titleColor: Customization.buttonsTitleColor, backgroundColor: Customization.buttonActionColor)
    
    self.closeRecoverViewBtn.customImageColor(color: nil, backgroundColor: nil)
    self.closeRegisterViewBtn.customImageColor(color: nil, backgroundColor: nil)
    self.closeNewPassViewBtn.customImageColor(color: nil, backgroundColor: nil)
    self.showHideClaveBtn.customImageColor(color: nil, backgroundColor: nil)
    self.showHideRegistroBtn.customImageColor(color: nil, backgroundColor: nil)
    self.showHideConfirmClave.customImageColor(color: nil, backgroundColor: nil)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    
    self.DatosView.addGestureRecognizer(tapGesture)
    self.claveRecoverView.addGestureRecognizer(tapGesture)
    self.RegistroView.addGestureRecognizer(tapGesture)
    self.RegistroView.backgroundColor = Customization.primaryColor
    self.claveRecoverView.backgroundColor = Customization.primaryColor
    self.view.addGestureRecognizer(tapGesture)
 
    self.autenticarBtn.addShadow()
    self.RecuperarClaveBtn.addShadow()
    self.crearCuentaBtn.addShadow()
    self.crearNewPasswordText.addShadow()
    
    self.autenticarBtn.heightAnchor 
    self.loginDatosViewHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 30))
    self.newPasswordFormHeight.constant = 40
    
    self.clave.clearButtonMode = .never
    //Put Background image to View
    //self.loginBackView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    
    //Calculate the custom constraints
    if UIScreen.main.bounds.height < 736{
      self.textFieldHeight.constant = 40
    }else{
      self.textFieldHeight.constant = 45
    }
    
    let spaceBetween = (UIScreen.main.bounds.height - self.textFieldHeight.constant * 9) / 17
    
    self.claveTextBottom.constant = -spaceBetween
    self.telefonoTextBottom.constant = -spaceBetween
    self.nombreTextBottom.constant = -spaceBetween
    //self.creaUsuarioBottom.constant = -spaceBetween
    
    self.correoTextTop.constant = spaceBetween
    self.recomendadoLabelTop.constant = spaceBetween
    self.recomendadoTextTop.constant = 5
    self.registrarTop.constant = spaceBetween
    
    self.showPoliticasBtn.setTitleColor(Customization.secundaryColor, for: .normal)
    self.RegistroBtn.setTitleColor(Customization.secundaryColor, for: .normal)
    self.olvideClaveBtn.setTitleColor(Customization.secundaryColor, for: .normal)
    
    self.usuario.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.clave.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.telefonoText.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.nombreApText.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.claveText.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.confirmarClavText.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.correoText.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.movilClaveRecover.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    self.newPasswordText.customTextField(textColor: nil, backgroundColor: Customization.primaryColor)
    
    
    self.myContext.localizedCancelTitle = "Autenticar con Usuario/Clave"
    
    NSLayoutConstraint(item: self.codigoText, attribute: .bottom, relatedBy: .equal, toItem: self.newPasswordText, attribute: .top, multiplier: 1, constant: -spaceBetween).isActive = true
    
    NSLayoutConstraint(item: self.passwordMatch as Any, attribute: .top, relatedBy: .equal, toItem: self.newPasswordText, attribute: .bottom, multiplier: 1, constant: spaceBetween).isActive = true
    
    
    self.movilClaveRecoverHeight.constant = 40
    
    if CConexionInternet.isConnectedToNetwork() == true{
      print("login \(globalVariables.userDefaults.value(forKey: "accessToken"))")
      if globalVariables.userDefaults.value(forKey: "accessToken") != nil{
        //self.socketService.initLoginEventos()
        self.startSocketConnection()
      }else{
        self.AutenticandoView.isHidden = true
      }
    }else{
      ErrorConexion()
    }
    self.telefonoText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    //self.checkifBioAuth()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("HEREEEEE")
  }
  
  
  //MARK:- ACCIONES DE LOS BOTONES
  //LOGIN Y REGISTRO DE CLIENTE
  @IBAction func Autenticar(_ sender: AnyObject) {
    if !self.usuario.text!.isEmpty && !self.clave.text!.isEmpty{
      self.clave.endEditing(true)
      self.Login(user: self.usuario.text!, password: self.clave.text!)
      self.usuario.text?.removeAll()
      self.clave.text?.removeAll()
    }else{
      let alertaDos = UIAlertController (title: "Formulario incompleto", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.movilClaveRecover.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func OlvideClave(_ sender: AnyObject) {
    claveRecoverView.isHidden = false
    self.movilClaveRecover.becomeFirstResponder()
  }
  
  @IBAction func RecuperarClave(_ sender: AnyObject) {
    //"#Recuperarclave,numero de telefono,#"
    if !self.movilClaveRecover.text!.isEmpty{
      self.view.resignFirstResponder()
      apiService.recoverUserClaveAPI(url: GlobalConstants.passRecoverUrl, params: ["nombreusuario": movilClaveRecover.text!])
      globalVariables.userDefaults.set(movilClaveRecover.text, forKey: "nombreUsuario")
//      let recuperarDatos = "#Recuperarclave," + movilClaveRecover.text! + ",# \n"
//      EnviarSocket(recuperarDatos)
      //self.EnviarTimer(estado: 1, datos: recuperarDatos)
      movilClaveRecover.endEditing(true)
      movilClaveRecover.text?.removeAll()
    }else{
      let alertaDos = UIAlertController (title: "Recuperar clave", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.movilClaveRecover.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func createNewPassword(_ sender: Any) {
    if self.newPasswordText.text!.isEmpty || self.passwordMatch.text!.isEmpty || self.codigoText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Crear nueva clave", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in

      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }else{
    if self.newPasswordText.text == self.passwordMatch.text{
      self.createNewPassword(codigo: self.codigoText.text!, newPassword: self.newPasswordText.text!)
    }else{
      let alertaDos = UIAlertController (title: "Nueva clave", message: "Las nueva clave no coincide en ambos campos", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.RegistroView.isHidden = false
        self.nombreApText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
    }
   
  }
  
  @IBAction func closeNewPasswordView(_ sender: Any) {
    self.NewPasswordView.isHidden = true
  }
  
  @IBAction func CancelRecuperarclave(_ sender: AnyObject) {
    claveRecoverView.isHidden = true
    self.movilClaveRecover.endEditing(true)
    self.movilClaveRecover.text?.removeAll()
  }
  
  @IBAction func RegistrarCliente(_ sender: AnyObject) {
    self.usuario.resignFirstResponder()
    self.clave.resignFirstResponder()
    RegistroView.isHidden = false
    self.telefonoText.becomeFirstResponder()
    
  }
  @IBAction func EnviarRegistro(_ sender: AnyObject) {
    if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
      let alertaDos = UIAlertController (title: "Registro de usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.RegistroView.isHidden = false
        self.telefonoText.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      apiService.registerUserAPI(url: GlobalConstants.registerUrl, params: [
        "password": claveText.text!,
        "movil": telefonoText.text!,
        "nombreapellidos": nombreApText.text!,
        "email": correoText.text!,
        "so": "IOS",
        "recomendado": RecomendadoText.text!])
      
      self.AutenticandoView.isHidden = false
      RegistroView.resignFirstResponder()
    }
    
  }
  
  @IBAction func CancelarRegistro(_ sender: AnyObject) {
    RegistroView.endEditing(true)
    RegistroView.isHidden = true
    claveText.endEditing(true)
    confirmarClavText.endEditing(true)
    correoText.endEditing(true)
    nombreApText.text?.removeAll()
    telefonoText.text?.removeAll()
    claveText.text?.removeAll()
    confirmarClavText.text?.removeAll()
    correoText.text?.removeAll()
    RecomendadoText.text?.removeAll()
  }
  
  
  @IBAction func showHideClave(_ sender: Any) {
    if self.clave.isSecureTextEntry{
      self.showHideClaveBtn.setImage(UIImage(named: "hideClave"), for: .normal)
      self.clave.isSecureTextEntry = false
    }else{
      self.showHideClaveBtn.setImage(UIImage(named: "showClave"), for: .normal)
      self.clave.isSecureTextEntry = true
    }
  }
  
  @IBAction func showHideRegistroClave(_ sender: Any) {
    if self.claveText.isSecureTextEntry{
      self.showHideRegistroBtn.setImage(UIImage(named: "hideClave"), for: .normal)
      self.claveText.isSecureTextEntry = false
    }else{
      self.showHideRegistroBtn.setImage(UIImage(named: "showClave"), for: .normal)
      self.claveText.isSecureTextEntry = true
    }
  }
  
  @IBAction func showHideConfirmClave(_ sender: Any) {
    if self.confirmarClavText.isSecureTextEntry{
      self.showHideConfirmClave.setImage(UIImage(named: "hideClave"), for: .normal)
      self.confirmarClavText.isSecureTextEntry = false
    }else{
      self.showHideConfirmClave.setImage(UIImage(named: "showClave"), for: .normal)
      self.confirmarClavText.isSecureTextEntry = true
    }
  }
  @IBAction func showPoliticas(_ sender: Any) {
    UIApplication.shared.open(URL(string: "https://servicaren.xoaserver.com/cliente.html")!, options: [:], completionHandler: nil)
  }
}
