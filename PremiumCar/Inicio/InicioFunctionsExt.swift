//
//  InicioFunctionsExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/20.
//  Copyright © 2020 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Mapbox

extension InicioController{
  //MARK:- FUNCIONES PROPIAS
  
  func appUpdateAvailable() -> Bool
  {
    let storeInfoURL: String = GlobalConstants.storeInfoURL
    var upgradeAvailable = false
    
    // Get the main bundle of the app so that we can determine the app's version number
    let bundle = Bundle.main
    if let infoDictionary = bundle.infoDictionary {
      // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
      let urlOnAppStore = URL(string: storeInfoURL)
      if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
        // Try to deserialize the JSON that we got
        if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as! Dictionary<String, Any>{
          // Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
          if let resultCount = lookupResults["resultCount"] as? Int {
            if resultCount == 1 {
              // Get the version number of the version in the App Store
              //self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
              if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
                // Get the version number of the current version
                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                  // Check if they are the same. If not, an upgrade is available.
                  if appStoreVersion > currentVersion {
                    upgradeAvailable = true
                  }
                }
              }
            }
          }
        }
      }
    }
    ///Volumes/Datos/Ecuador/Desarrollo/UnTaxi/UnTaxi/LocationManager.swift:635:31: Ambiguous use of 'indexOfObject'
    return upgradeAvailable
  }
  
  
  func initMapView(){
    mapView.setCenter(self.origenAnotacion.coordinate, zoomLevel: 15, animated: false)
    mapView.styleURL = MGLStyle.lightStyleURL
    self.origenIcono.image = UIImage(named: "origen")
    self.origenIcono.isHidden = true
    self.mapView.addAnnotation(self.origenAnotacion)
  }
  
  //RECONECT SOCKET
  @objc func Reconect(){
    if contador <= 5 {
      globalVariables.socket.connect()
      contador += 1
    }
    else{
      let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  func loadFormularioData(){
    self.formularioDataCellList.removeAll()
    self.formularioDataCellList.append(self.origenCell)
    
//    switch self.tipoSolicitudSwitch.selectedSegmentIndex {
//    case 0:
//      self.formularioDataCellList.append(self.destinoCell)
//      self.ofertaDataCell.initContent(precioInicial: 2.0)
//      self.formularioDataCellList.append(self.ofertaDataCell)
//      self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 80))
//    case 1:
//      self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent:65))
//    case 3:
//      
//    default:
//      <#code#>
//    }
    

    if self.tipoSolicitudSwitch.selectedSegmentIndex == 0 || self.tipoSolicitudSwitch.selectedSegmentIndex == 3{
      self.formularioDataCellList.append(self.destinoCell)
      if self.tipoSolicitudSwitch.selectedSegmentIndex == 0{
        self.ofertaDataCell.initContent(precioInicial: 2.0)
        self.formularioDataCellList.append(self.ofertaDataCell)
        self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 80))
      }
    }else{
      self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent:65))
      if globalVariables.cliente.idEmpresa != 0{
        self.formularioDataCellList.append(self.voucherCell)
        if self.isVoucherSelected{
          self.formularioDataCellList.append(self.destinoCell)
          self.formularioSolicitudHeight.constant = CGFloat(globalVariables.responsive.heightPercent(percent: 75))
        }
        self.tipoSolicitudSwitch.isHidden = false
    
      }
    }
    
    if self.tipoSolicitudSwitch.selectedSegmentIndex == 3{
      self.formularioDataCellList.append(self.pactadaCell)
    }
    
    self.formularioDataCellList.append(self.contactoCell)
    self.solicitudFormTable.reloadData()

  }
  
  func loadCallCenter(){
    self.socketEmit("telefonosdelcallcenter", datos: [:])
  }
  
  
  //FUNCTION ENVIO CON TIMER
  func EnviarTimer(estado: Int, datos: String){
    if estado == 1{
      self.EnviarSocket(datos)
      if !self.emitTimer.isValid{
        self.emitTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
      }
    }else{
      self.emitTimer.invalidate()
      self.EnviosCount = 0
    }
  }
  
  //FUNCIÓN ENVIAR AL SOCKET
  @objc func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active && self.EnviosCount <= 3{
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
  
  
  func socketEmit(_ eventName: String, datos: [String: Any]){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active{
        globalVariables.socket.emitWithAck(eventName, datos).timingOut(after: 3) {respond in
          if respond[0] as! String == "OK"{
            print(respond)
          }else{
            print("error en socket")
          }
        }
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
  
  @objc func EnviarSocket1(_ timer: Timer){
    if CConexionInternet.isConnectedToNetwork() == true{
      if globalVariables.socket.status.active && self.EnviosCount <= 3 {
        self.EnviosCount += 1
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        var datos = (userInfo["datos"] as! String)
        globalVariables.socket.emit("data",datos)
      }else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.EnviarTimer(estado: 0, datos: "Terminado")
          exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      ErrorConexion()
    }
  }
  
  //FUNCIONES ESCUCHAR SOCKET
  func ErrorConexion(){
    //self.CargarTelefonos()
    //AlertaSinConexion.isHidden = false
    
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func Inicio(){
    if self.mapView!.annotations != nil {
      mapView.removeAnnotations(self.mapView!.annotations!)
    }
    self.initMapView()
    self.view.endEditing(true)
    
    self.formularioSolicitud.isHidden = true
    self.SolicitarBtn.isHidden = false
    SolPendientesView.isHidden = true
    CancelarSolicitudProceso.isHidden = true
    AlertaEsperaView.isHidden = true
    self.tipoSolicitudSwitch.selectedSegmentIndex = 0
    super.topMenu.isHidden = false
    self.viewDidLoad()
  }
  
  
  //FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
  //devolver posicion de solicitud
  func BuscarPosSolicitudID(_ id : String)->Int{
    var temporal = 0
    var posicion = -1
    for solicitudpdt in globalVariables.solpendientes{
      if String(solicitudpdt.id) == id{
        posicion = temporal
      }
      temporal += 1
    }
    return posicion
  }
  
  //Respuesta de solicitud
  func ConfirmaSolicitud(_ newSolicitud : [String:Any]){
    //Trama IN: #Solicitud, ok, idsolicitud, fechahora
    globalVariables.solpendientes.last!.RegistrarFechaHora(Id: newSolicitud["idsolicitud"] as! Int, FechaHora: newSolicitud["fechahora"]  as! String)
  }
  
  //FUncion para mostrar los taxis
  func MostrarTaxi(_ temporal : [String]){
    //TRAMA IN: #Posicion,idtaxi,lattaxi,lngtaxi
    var i = 2
    var taxiscercanos = [MGLAnnotation]()
    while i  <= temporal.count - 6{
      let taxiTemp = MGLPointAnnotation()
      taxiTemp.coordinate = CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!)
      taxiTemp.title = temporal[i]
      taxiscercanos.append(taxiTemp)
      i += 6
    }
    DibujarIconos(taxiscercanos)
  }
  
  //CANCELAR SOLICITUDES
  func MostrarMotivoCancelacion(idSolicitud: Int){
    //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
    let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertController.Style.actionSheet)
    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
      
      self.CancelarSolicitudes(idSolicitud, motivo: "No necesito")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
      
      self.CancelarSolicitudes(idSolicitud, motivo: "Demora el servicio")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
      
      self.CancelarSolicitudes(idSolicitud, motivo: "Tarifa incorrecta")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
      
      self.CancelarSolicitudes(idSolicitud, motivo: "Vehículo en mal estado")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
      
      self.CancelarSolicitudes(idSolicitud, motivo: "Solo probaba el servicio")
      
    }))
    
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
    }))
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  func CancelarSolicitudes(_ idSolicitud: Int, motivo: String){
    //#Cancelarsolicitud, id, idTaxi, motivo, "# \n"
    //let temp = (globalVariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
    let solicitudIndex = globalVariables.solpendientes.firstIndex{$0.id == idSolicitud}!
    let datos = globalVariables.solpendientes[solicitudIndex].crearTramaCancelar(motivo: motivo)
    globalVariables.solpendientes.remove(at: solicitudIndex)
    if globalVariables.solpendientes.count == 0 {
      globalVariables.solicitudesproceso = false
    }
    if motivo != "Conductor"{
      self.socketEmit("cancelarservicio", datos: datos)
    }
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
  
  
  //FUNCION PARA DIBUJAR LAS ANOTACIONES
  
  func DibujarIconos(_ anotaciones: [MGLAnnotation]){
    if anotaciones.count == 1{
      self.mapView.addAnnotations([self.origenAnotacion,anotaciones[0]])
      //self.mapView.fitAll(in: self.mapView.annotations, andShow: true)
    }else{
      self.mapView.addAnnotations(anotaciones)
      //self.mapView.fitAll(in: anotaciones, andShow: true)
    }
  }
  
  
  //Validar los formularios
  func SoloLetras(name: String) -> Bool {
    // (1):
    let pat = "[0-9,.!@#$%^&*()_+-]"
    // (2):
    //let testStr = "x.wu@strath.ac.uk, ak123@hotmail.com     e1s59@oxford.ac.uk, ee123@cooleng.co.uk, a.khan@surrey.ac.uk"
    // (3):
    let regex = try! NSRegularExpression(pattern: pat, options: [])
    // (4):
    let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
    print(matches.count)
    if matches.count == 0{
      return true
    }else{
      return false
    }
  }
  
  @objc func ocultarMenu(){
    self.MenuView1.isHidden = true
    self.TransparenciaView.isHidden = true
    self.Inicio()
    super.topMenu.isHidden = false
  }
  
  //ADD FOOTER TO SOLICITDFORMTABLE
  func addEnvirSolictudBtn(){
    let enviarBtnView = UIView(frame: CGRect(x: 0, y: 0, width: self.SolicitudView.frame.width, height: 60))
    let button:UIButton = UIButton.init(frame: CGRect(x: 25, y: 10, width: self.SolicitudView.frame.width - 50, height: 40))
    button.backgroundColor = .darkText
    button.layer.cornerRadius = 5
    button.setTitleColor(Customization.buttonsTitleColor, for: .normal)
    button.setTitle("ENVIAR SOLICITUD", for: .normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
    button.addTarget(self, action: #selector(self.enviarSolicitud), for: .touchUpInside)
    
    //enviarBtnView.addSubview(separatorView)
    enviarBtnView.addSubview(button)
    self.solicitudFormTable.backgroundColor = .none
    self.solicitudFormTable.tableFooterView = enviarBtnView
  }
  
  func converAddressToCoord(address: String)->CLLocationCoordinate2D{
    var coordinates = self.origenAnotacion.coordinate
    var geocoder = CLGeocoder()
    if address != ""{
      geocoder.geocodeAddressString(address) {
        placemarks, error in
        let placemark = placemarks?.first
        coordinates = (placemark?.location!.coordinate)!
        //      let lat = placemark?.location?.coordinate.latitude
        //      let lon = placemark?.location?.coordinate.longitude
      }
    }
    return coordinates
    
  }
  
  func crearTramaSolicitud(_ nuevaSolicitud: Solicitud){
    //#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
    formularioSolicitud.isHidden = true
    origenIcono.isHidden = true
    globalVariables.solpendientes.append(nuevaSolicitud)
    
    self.socketEmit("solicitarservicio", datos: nuevaSolicitud.crearTrama())

    MensajeEspera.text = "Procesando..."
    self.AlertaEsperaView.isHidden = false
    self.origenCell.origenText.text?.removeAll()
    self.origenCell.referenciaText.text?.removeAll()
  }
  
  func crearSolicitudOferta(){
    //#SO,idcliente,nombreapellidos,movil,dirorigen,referencia,dirdestino,latorigen,lngorigen,ladestino,lngdestino,distanciaorigendestino,valor oferta,voucher,detalle oferta,fecha reserva,tipo transporte,#
    
    if !self.origenCell.origenText.text!.isEmpty{
      
      let nombreContactar = globalVariables.cliente.nombreApellidos
      
      let telefonoContactar = globalVariables.cliente.user
      
      let origen = self.cleanTextField(textfield: self.origenCell.origenText)
      
      let origenCoord = self.origenAnotacion.coordinate
      
      let referencia = !self.origenCell.referenciaText.text!.isEmpty ? self.cleanTextField(textfield: self.origenCell.referenciaText) : "No referencia"
      
      let destino =  self.tipoSolicitudSwitch.selectedSegmentIndex != 0 ? "" : self.cleanTextField(textfield: self.destinoCell.destinoText)
      
      let destinoCoord = self.converAddressToCoord(address: destino)
      
      let voucher = self.tipoSolicitudSwitch.selectedSegmentIndex != 0 && self.voucherCell.formaPagoSwitch.selectedSegmentIndex == 2 ? "1" : "0"
      
      let detalleOferta = !self.ofertaDataCell.detallesText.text!.isEmpty ? self.ofertaDataCell.detallesText.text! : "No detalles"
      
      let fechaReserva = ""
      
      let valorOferta = self.tipoSolicitudSwitch.selectedSegmentIndex == 0 ? self.ofertaDataCell.valorOferta : self.tipoSolicitudSwitch.selectedSegmentIndex == 3 ? pactadaCell.importe : 0.0
      
      mapView.removeAnnotations(mapView!.annotations!)
      
      let nuevaSolicitud = Solicitud()
      self.contactoCell.contactoNameText.text!.isEmpty ? nuevaSolicitud.DatosCliente(cliente: globalVariables.cliente!) : nuevaSolicitud.DatosOtroCliente(telefono: telefonoContactar!, nombre: nombreContactar!)
      nuevaSolicitud.DatosSolicitud(id: 0, fechaHora: "", dirOrigen: origen, referenciaOrigen: referencia, dirDestino: destino, latOrigen: origenCoord.latitude, lngOrigen: origenCoord.longitude, latDestino: destinoCoord.latitude, lngDestino: destinoCoord.longitude, valorOferta: valorOferta, detalleOferta: detalleOferta, fechaReserva: fechaReserva, useVoucher: voucher,tipoServicio: tipoSolicitudSwitch.selectedSegmentIndex + 1)
      
      if !self.contactoCell.telefonoText.text!.isEmpty{
        nuevaSolicitud.DatosOtroCliente(telefono: self.cleanTextField(textfield: self.contactoCell.telefonoText), nombre: self.cleanTextField(textfield: self.contactoCell.contactoNameText))
      }
      
      self.crearTramaSolicitud(nuevaSolicitud)
      view.endEditing(true)
      
    }else{
      let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe llegar todos los campos subrayados con una línea roja porque son requeridos.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        //self.origenCell.destinoText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @objc func enviarSolicitud(){
    if self.tipoSolicitudSwitch.selectedSegmentIndex == 0 {
      //if !(self.ofertaDataCell.ofertaText.text?.isEmpty)! && self.ofertaDataCell.ofertaTex != "0"{
      self.crearSolicitudOferta()
      //      }else{
      //        let alertaDos = UIAlertController (title: "Error en el formulario", message: "Por favor debe ofertar un valor $ por el servicio.", preferredStyle: UIAlertController.Style.alert)
      //        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      //          //self.origenCell.destinoText.becomeFirstResponder()
      //        }))
      //        self.present(alertaDos, animated: true, completion: nil)
      //      }
    }else{
      self.crearSolicitudOferta()
    }
  }
  
  func updateOfertaValue(value: Double){
    self.newOfertaText.text = "\((self.newOfertaText.text! as NSString).doubleValue + value)"
  }
  //MARK:- CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.keyboardHeight = keyboardSize.height
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    animateViewMoving(false, moveValue: 60, view: self.view)
  }
  
  @objc func textViewDidChange(_ textView: UITextView) {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.origenCell.referenciaText.resignFirstResponder()
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    //sender.cancelsTouchesInView = false
    self.SolicitudView.endEditing(true)
  }
  
  //  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
  //    if touch.view?.isDescendant(of: self.TablaDirecciones) == true {
  //      gestureRecognizer.cancelsTouchesInView = false
  //    }else{
  //      self.SolicitudView.endEditing(true)
  //    }
  //    return true
  //  }
  //
  func cleanTextField(textfield: UITextField)->String{
    var cleanedTextField = textfield.text?.uppercased()
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[\n]", with: "-",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    return cleanedTextField!.folding(options: .diacriticInsensitive, locale: .current)
  }
  
  //  func showFormularioSolicitud(){
  //    self.CargarFavoritas()
  //    self.TablaDirecciones.reloadData()
  //    self.origenIcono.isHidden = true
  //    self.origenAnotacion.coordinate = mapView.centerCoordinate
  //    coreLocationManager.stopUpdatingLocation()
  //    self.SolicitarBtn.isHidden = true
  //    self.origenCell.origenText.becomeFirstResponder()
  //    if globalVariables.cliente.empresa != "null"{
  //      self.VoucherView.isHidden = false
  //      self.VoucherEmpresaName.text = globalVariables.cliente.empresa
  //      NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.VoucherView, attribute:.bottom, multiplier: 1.0, constant:43.0).isActive = true
  //    }else{
  //      NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.ContactoView, attribute:.bottom, multiplier: 1.0, constant:10.0).isActive = true
  //
  //    }
  //    self.formularioSolicitud.isHidden = false
  //  }
  
  //Date picker functions
  //  @objc func dateChange( datePicker: UIDatePicker) {
  //    let dateFormatter = DateFormatter()
  //    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
  //    //self.reservaDate.text = dateFormatter.string(from: datePicker.date)
  //  }
  //
  @objc func dismissPicker() {
    view.endEditing(true)
  }
  
  //FUNCION DETERMINAR DIRECCIÓN A PARTIR DE COORDENADAS
  func direccionDeCoordenada(_ coordenada : CLLocationCoordinate2D, directionText : UITextField){
    let geocoder = CLGeocoder()
    var address = ""
    if CConexionInternet.isConnectedToNetwork() == true {
      let temporaLocation = CLLocation(latitude: coordenada.latitude, longitude: coordenada.longitude)
      CLGeocoder().reverseGeocodeLocation(temporaLocation, completionHandler: {(placemarks, error) -> Void in
        if error != nil {
          print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
          return
        }
        
        if (placemarks?.count)! > 0 {
          let placemark = (placemarks?.first)! as CLPlacemark
          
          if let name = placemark.addressDictionary?["Name"] as? String {
            address += name
          }
          
          //            if let locality = placemark.addressDictionary?["City"] as? String {
          //              address += " \(locality)"
          //            }
          //
          //          if let state = placemark.addressDictionary?["State"] as? String {
          //            address += " \(state)"
          //          }
          //
          //          if let country = placemark.country{
          //            address += " \(country)"
          //          }
          directionText.text = address
          //self.GeolocalizandoView.isHidden = true
        }
        else {
          directionText.text = "No disponible"
          //self.GeolocalizandoView.isHidden = true
        }
      })
      
    }else{
      ErrorConexion()
    }
  }
  
  func offSocketEventos(){
    globalVariables.socket.off("cargarvehiculoscercanos")
    globalVariables.socket.off("solicitarservicio")
    globalVariables.socket.off("cancelarservicio")
    globalVariables.socket.off("sinvehiculo")
    globalVariables.socket.off("solicitudaceptada")
    globalVariables.socket.off("serviciocancelado")
    globalVariables.socket.off("ofertadelconductor")
    globalVariables.socket.off("telefonosdelcallcenter")
    globalVariables.socket.off("taximetroiniciado")
    globalVariables.socket.off("subiroferta")
    globalVariables.socket.off("U")
    globalVariables.socket.off("voz")
    globalVariables.socket.off("direccionespactadas")
    globalVariables.socket.off("serviciocompletado")
  }
  
}
