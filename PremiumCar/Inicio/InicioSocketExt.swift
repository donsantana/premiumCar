//
//  InicioControllerSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Mapbox

extension InicioController: SocketServiceDelegate{
  func socketResponse(_ controller: SocketService, cargarvehiculoscercanos result: [String : Any]) {
//    if (result["datos"] as! [Any]).count == 0 {
//      print(result)
//      let alertaDos = UIAlertController(title: "Solicitud de Taxi", message: "No hay taxis disponibles en este momento, espere unos minutos y vuelva a intentarlo.", preferredStyle: UIAlertController.Style.alert )
//      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
//        super.topMenu.isHidden = false
//        self.viewDidLoad()
//      }))
//      self.present(alertaDos, animated: true, completion: nil)
//    }else{
//      self.loadFormularioData()
//    }
    print(result)
    if (result["datos"] as! [Any]).count > 0 {
      let taxiList = result["datos"] as! [[String: Any]]
      var mapAnnotations: [MGLPointAnnotation] = [self.origenAnnotation]
      
      for taxi in taxiList{
        let taxiAnnotation = MGLPointAnnotation()
        taxiAnnotation.title = "taxi_libre"
        taxiAnnotation.coordinate = CLLocationCoordinate2D(latitude: taxi["lat"] as! Double,longitude: taxi["lng"] as! Double)
        mapAnnotations.append(taxiAnnotation)
      }
      self.showAnnotation(mapAnnotations)
    }
  }
  
  func socketResponse(_ controller: SocketService, solicitarservicio result: [String : Any]) {
    print(result)
    if (result["code"] as! Int) == 1 {
      let newSolicitud = result["datos"] as! [String: Any]
      //self.solicitudInProcess.text = String(newSolicitud["idsolicitud"] as! Int)
      //self.AlertaEsperaView.isHidden = false
      //self.CancelarSolicitudProceso.isHidden = false
      self.ConfirmaSolicitud(newSolicitud)
      //self.newOfertaText.text = self.ofertaDataCell.valorOfertaText.text
      //self.down25.isEnabled = false
    }else{
      print("error de solicitud \(result["msg"])")
    }
    
  }
  
  func socketResponse(_ controller: SocketService, cancelarservicio result: [String : Any]) {
    if (result["code"] as! Int) == 1 {
      self.Inicio()
    }
  }
  
  func socketResponse(_ controller: SocketService, sinvehiculo result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if (solicitud != nil) {
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "No se encontó ningún taxi disponible para ejecutar su solicitud. Por favor inténtelo más tarde.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.CancelarSolicitud("",solicitud: solicitud!)
        self.Inicio()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, solicitudaceptada result: [String : Any]) {
    let newTaxi = Taxi(id: result["idtaxi"] as! Int, matricula: result["matriculataxi"] as! String, codigo: result["codigotaxi"] as! String, marca: result["marcataxi"] as! String,color: result["colortaxi"] as! String, lat: result["lattaxi"] as! Double, long: result["lngtaxi"] as! Double, conductor: Conductor(idConductor: result["idconductor"] as! Int, nombre: result["nombreapellidosconductor"] as! String, telefono:  result["telefonoconductor"] as! String, urlFoto: result["foto"] as! String, calificacion: result["calificacion"] as! Double, cantidadcalificaciones: result["cantidadcalificacion"] as! Int))
    
    globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}!.DatosTaxiConductor(taxi: newTaxi)
    
    DispatchQueue.main.async {
      let vc = R.storyboard.main.solDetalles()!
      vc.solicitudPendiente = globalVariables.solpendientes.first{$0.id == (result["idsolicitud"] as! Int)}
      self.navigationController?.show(vc, sender: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, serviciocancelado result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}
    if solicitud != nil{
      let alertaDos = UIAlertController (title: "Estado de Solicitud", message: "Solicitud cancelada por el conductor.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
        self.CancelarSolicitud("Conductor",solicitud: solicitud!)
        
        DispatchQueue.main.async {
          let vc = R.storyboard.main.inicioView()!
          self.navigationController?.show(vc, sender: nil)
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, ofertadelconductor result: [String : Any]) {
    let array = globalVariables.ofertasList.map{$0.id}
    if !array.contains(result["idsolicitud"] as! Int){
      let newOferta = Oferta(id: result["idsolicitud"] as! Int, idTaxi: result["idtaxi"] as! Int, idConductor: result["idconductor"] as! Int, codigo: result["codigotaxi"] as! String, nombreConductor: result["nombreapellidosconductor"] as! String, movilConductor: result["telefonoconductor"] as! String, lat: result["lattaxi"] as! Double, lng: result["lngtaxi"] as! Double, valorOferta: result["valoroferta"] as! Double, tiempoLLegada: result["tiempollegada"] as! Int, calificacion: result["calificacion"] as! Double, totalCalif: result["cantidadcalificacion"] as! Int, urlFoto: result["foto"] as! String, matricula: result["matriculataxi"] as! String, marca: result["marcataxi"] as! String, color: result["colortaxi"] as! String)

      globalVariables.ofertasList.append(newOferta)

      DispatchQueue.main.async {
        let vc = R.storyboard.main.ofertasView()
        vc?.solicitud = globalVariables.solpendientes.first{$0.id == newOferta.id}!
        self.navigationController?.show(vc!, sender: nil)
      }
    }
  }
  
  func socketResponse(_ controller: SocketService, taximetroiniciado result: [String : Any]) {
    let solicitud = globalVariables.solpendientes.first{$0.id == result["idsolicitud"] as! Int}!
    if solicitud != nil {
      //self.MensajeEspera.text = result
      //self.AlertaEsperaView.hidden = false
      let title = solicitud.tipoServicio == 2 ? "Taximetro Activado" : "Carrera Iniciada"
      let mensaje = solicitud.tipoServicio == 2 ? "El conductor ha iniciado el Taximetro " : "El conductor ha iniciado la carrera "
      let alertaDos = UIAlertController (title: title, message: "\(mensaje) a las: \(OurDate(stringDate: result["fechacambioestado"] as! String).timeToShow()).", preferredStyle: .alert)
          alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
            
          }))
          self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, subiroferta result: [String : Any]) {
    if result["code"] as! Int == 1{
      let alertaDos = UIAlertController (title: "Oferta Actualizada", message: "La oferta ha sido actualizada con éxito y enviada a los conductores disponibles. Esperamos que acepten su nueva oferta.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      let alertaDos = UIAlertController (title: "Oferta Cancelada", message: "La oferta ha sido cancelada por el conductor. Por favor", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        if globalVariables.solpendientes.count != 0{
          self.Inicio()
        }
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func socketResponse(_ controller: SocketService, msgVozConductor result: [String : Any]) {
    globalVariables.urlConductor = "\(GlobalConstants.urlHost)/\(result["audio"] as! String)"
    if UIApplication.shared.applicationState == .background {
      let localNotification = UILocalNotification()
      localNotification.alertAction = "Mensaje del Conductor"
      localNotification.alertBody = "Mensaje del Conductor. Abra la aplicación para escucharlo."
      localNotification.fireDate = Date(timeIntervalSinceNow: 4)
      UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    globalVariables.SMSVoz.ReproducirVozConductor(globalVariables.urlConductor)
  }
  
  func socketResponse(_ controller: SocketService, direccionespactadas result: [String : Any]) {
    if result["code"] as! Int == 1{
      let pactadasList = result["datos"] as! [[String: Any]]
      for direccionPactada in pactadasList{
        globalVariables.direccionesPactadas.append(DireccionesPactadas(data: direccionPactada))
      }
    }
    self.addressPicker.reloadAllComponents()
    self.destinoAddressPicker.reloadAllComponents()
  }
  
  func socketResponse(_ controller: SocketService, serviciocompletado result: [String : Any]) {
    if globalVariables.solpendientes.count > 0 {
      let solicitudCompletadaIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
      if solicitudCompletadaIndex >= 0{
        let solicitudCompletada = globalVariables.solpendientes.remove(at: solicitudCompletadaIndex)
        print(solicitudCompletada.valorOferta)
        DispatchQueue.main.async {
          let vc = R.storyboard.main.completadaView()!
          vc.solicitud = solicitudCompletada
          vc.importe = !(result["importe"] is NSNull) ? result["importe"] as! Double : solicitudCompletada.valorOferta
          self.navigationController?.show(vc, sender: nil)
        }
      }
    }
  }
  
  func socketResponse(_ controller: SocketService, taxiLLego result: [String : Any]) {
    let solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == result["idsolicitud"] as! Int}!
    let solicitud = globalVariables.solpendientes[solicitudIndex]
    if solicitudIndex >= 0{
      let alertaDos = UIAlertController (title: "Su Taxi ha llegado", message: "Su taxi \(solicitud.taxi.marca), color \(solicitud.taxi.color), matrícula \(solicitud.taxi.matricula) ha llegado al punto de recogida.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  
  func socketResponse(_ controller: SocketService, conectionError errorMessage: String) {
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
}
