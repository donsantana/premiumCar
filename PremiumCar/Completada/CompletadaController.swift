//
//  CompletadaController.swift
//  UnTaxi
//
//  Created by Done Santana on 1/6/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import Foundation
import UIKit


class CompletadaController: BaseController, UITextFieldDelegate {
  var solicitud: Solicitud!
  var conductor = Conductor()
  var evaluacion: CEvaluacion!
  var importe: Double = 0.0
  var socketService = SocketService()
  var comentariosSelected: [String] = []
  
  @IBOutlet weak var origenIcon: UIImageView!
  @IBOutlet weak var completadaBack: UIView!
  @IBOutlet weak var comentarioText: UITextField!
  @IBOutlet weak var completadaView: UIView!
  @IBOutlet weak var conductorImage: UIImageView!
  @IBOutlet weak var conductorName: UILabel!
  @IBOutlet weak var importeText: UILabel!
  
  @IBOutlet weak var detallesView: UIView!
  @IBOutlet weak var evaluacionView: UIView!
  @IBOutlet weak var evaluarBtn: UIButton!
  
  @IBOutlet weak var PrimeraStart: UIButton!
  @IBOutlet weak var SegundaStar: UIButton!
  @IBOutlet weak var TerceraStar: UIButton!
  @IBOutlet weak var CuartaStar: UIButton!
  @IBOutlet weak var QuintaStar: UIButton!
  
  @IBOutlet weak var evaluacionTitleText: UILabel!
  @IBOutlet weak var evaluacionSubtitleText: UILabel!
  
  
  @IBOutlet weak var origenAddressText: UILabel!
  @IBOutlet weak var destinoAddressText: UILabel!
  @IBOutlet weak var efectivoText: UILabel!
  @IBOutlet weak var yapaIcon: UIImageView!
  @IBOutlet weak var yapaText: UILabel!
  
  @IBOutlet weak var comentariosCollection: UICollectionView!
  
  @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.comentariosCollection.delegate = self
    self.comentarioText.delegate = self
    
    self.comentarioText.setBottomBorder(borderColor: .gray)
    self.conductor = self.solicitud.taxi.conductor
    let url = URL(string:"\(GlobalConstants.urlHost)/\(self.conductor.urlFoto)")
    
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.sync() {
        self.conductorImage.image = UIImage(data: data)
      }
    }
    task.resume()
    self.topViewConstraint.constant = super.getTopMenuBottom()
    self.conductorName.text = conductor.nombreApellido
    //self.comentarioText.delegate = self
    self.evaluacion = CEvaluacion(botones: [PrimeraStart, SegundaStar,TerceraStar,CuartaStar,QuintaStar])
    self.importeText.addBorder(color: Customization.buttonActionColor)
    self.importeText.text = "$\(self.importe)"
    self.efectivoText.text = "$\(self.importe - solicitud.yapaimporte),Efectivo"
    self.yapaIcon.isHidden = !globalVariables.appConfig.yapa
    self.yapaText.isHidden = self.yapaIcon.isHidden
    self.yapaText.text = "$\(solicitud.yapaimporte),Yapa"
    
    self.origenAddressText.text = solicitud.dirOrigen
    self.destinoAddressText.text = solicitud.dirDestino
    
    self.evaluarBtn.customBackgroundTitleColor(titleColor: nil, backgroundColor: nil)
    self.origenIcon.addCustomTintColor(customColor: Customization.buttonActionColor)
  }
  
  func updateEvalucion(evaluation: Int){
    self.evaluacionView.isHidden = false
    self.evaluacion.EvaluarCarrera(evaluation)
    self.evaluacionTitleText.text = self.evaluacion.getTitle()
    self.evaluacionSubtitleText.text = self.evaluacion.getSubtilte()
    self.comentariosCollection.reloadData()
  }
  
  //ENVIAR EVALUACIÓN
  func EnviarEvaluacion(_ evaluacion: Int, comentario: String){
    if evaluacion != 0 {
      let datos = [
        "evaluacion": self.evaluacion.ptoEvaluacion,
        "comentario": comentario,
        "idsolicitud": self.solicitud.id,
        "idconductor": self.conductor.idConductor,
        ] as [String : Any]
      socketService.socketEmit("evaluarservicio", datos: datos)
      //self.socketEmit("evaluarservicio", datos: datos)
    }
    DispatchQueue.main.async {
      let vc = R.storyboard.main.inicioView()!
      self.navigationController?.show(vc, sender: nil)
    }
    
  }
  
//  func socketEmit(_ eventName: String, datos: [String: Any]){
//      if CConexionInternet.isConnectedToNetwork() == true{
//        if globalVariables.socket.status.active{
//          globalVariables.socket.emitWithAck(eventName, datos).timingOut(after: 3) {respond in
//            if respond[0] as! String == "OK"{
//              print(respond)
//            }else{
//              print("error en socket")
//            }
//          }
//        }else{
//          let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
//          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//            exit(0)
//          }))
//          self.present(alertaDos, animated: true, completion: nil)
//        }
//      }else{
//        ErrorConexion()
//      }
//    }
//
//  func ErrorConexion(){
//    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
//    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//      exit(0)
//    }))
//
//    self.present(alertaDos, animated: true, completion: nil)
//  }
  
  @IBAction func Star1(_ sender: AnyObject) {
    self.updateEvalucion(evaluation: 1)
  }
  @IBAction func Star2(_ sender: AnyObject) {
    self.updateEvalucion(evaluation: 2)
  }
  @IBAction func Star3(_ sender: AnyObject) {
    self.updateEvalucion(evaluation: 3)
  }
  @IBAction func Star4(_ sender: AnyObject) {
    self.updateEvalucion(evaluation: 4)
  }
  @IBAction func Star5(_ sender: AnyObject) {
    self.updateEvalucion(evaluation: 5)
  }
  
  override func homeBtnAction() {
    let vc = R.storyboard.main.inicioView()
    self.navigationController?.show(vc!, sender: nil)
  }
  
  //Enviar comentario
  @IBAction func AceptarEvalucion(_ sender: AnyObject) {
    if !comentarioText.text!.isEmpty{
      self.comentariosSelected.append(comentarioText.text!)
    }
    EnviarEvaluacion(self.evaluacion.ptoEvaluacion,comentario: self.comentariosSelected.joined(separator: ","))
  }
  
  //MARK:- TEXT DELEGATE ACTION
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    animateViewMoving(true, moveValue: 210,view: self.view)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    animateViewMoving(false, moveValue: 210,view: self.view)
  }
  
  func animateViewMoving (_ up:Bool, moveValue :CGFloat, view : UIView){
    let movementDuration:TimeInterval = 0.3
    let movement:CGFloat = ( up ? -moveValue : moveValue)
    UIView.beginAnimations( "animateView", context: nil)
    UIView.setAnimationBeginsFromCurrentState(true)
    UIView.setAnimationDuration(movementDuration)
    view.frame = view.frame.offsetBy(dx: 0,  dy: movement)
    UIView.commitAnimations()
  }
  
  
  
}
