//
//  ViewController.swift
//  Accediendo-a-la-nube-con-iOS_Semana-1_Petici-n-al-servidor-openlibrary.org
//
//  Created by Juan Carlos Carbajal Ipenza on 5/10/16.
//  Copyright © 2016 Juan Carlos Carbajal Ipenza. All rights reserved.
//

import UIKit
import CoreData

protocol MyDelegado {
    func agregarLibro(libro: Libro)
}

class ViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textView: UITextView!
    var pending: UIAlertController!
    var indicator: UIActivityIndicatorView!
    var libro: Libro = Libro()
    var delegado: MyDelegado?
    var contexto: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        searchBar.showsCancelButton = true
        let cancelButton = searchBar.value(forKey: "cancelButton") as! UIButton
        cancelButton.setTitle("Limpiar", for: .normal)
        self.pending = UIAlertController(title: "Cargando", message: nil, preferredStyle: .alert)
        self.indicator = UIActivityIndicatorView(frame: pending.view.bounds)
        self.indicator.activityIndicatorViewStyle = .gray
        self.indicator.color = UIColor(red: 80/255, green: 165/255, blue: 247/255, alpha: 1.0)
        self.indicator.isUserInteractionEnabled = false
        self.indicator.hidesWhenStopped = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+searchBar.text!
        let url: NSURL? = NSURL(string: urls)
        
        let sesion: URLSession = URLSession.shared
        let bloque = { (datos: Data?, resp: URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            if (error == nil) {
                do {
                    let json = try JSONSerialization.jsonObject(with: datos! as Data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    let dico1 = json as! NSDictionary
                    if (dico1["ISBN:"+searchBar.text!] != nil) {
                        self.libro = Libro()
                        self.libro.isbn = searchBar.text!
                        DispatchQueue.main.async {
                            let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
                            let bodyFont = UIFont(descriptor: bodyFontDescriptor, size: 0)
                            self.textView.font = bodyFont
                            self.textView.textColor = UIColor.black
                            self.textView.backgroundColor = UIColor.white
                            self.textView.isScrollEnabled = true
                            self.textView.text = ""
                            
                            self.indicator.autoresizingMask = [.flexibleRightMargin, .flexibleHeight]
                            self.pending.view.addSubview(self.indicator)
                            self.indicator.startAnimating()
                            self.present(self.pending, animated: true, completion: nil)
                        }
                        
                        let dico2 = dico1["ISBN:"+searchBar.text!] as! NSDictionary
                    
                        if (dico2["title"] != nil) {
                            let titulo = dico2["title"] as! NSString as String
                            self.libro.titulo = titulo
                        }
                    
                        if (dico2["authors"] != nil) {
                            let autores = dico2["authors"] as! NSArray as Array
                            let autor0 = autores[0] as! NSDictionary
                            if (autor0["name"] != nil) {
                                let textAutor0 = autor0["name"] as! NSString as String
                                self.libro.autores.append(textAutor0)
                                for index in 1..<autores.count {
                                    let autor = autores[index] as! NSDictionary
                                    if (autor["name"] != nil) {
                                        let textAutor = autor["name"] as! NSString as String
                                        self.libro.autores.append(textAutor)
                                    }
                                }
                            }
                        }
                    
                        if (dico2["cover"] != nil) {
                            let portada = dico2["cover"] as! NSDictionary
                            if (portada["medium"] != nil) {
                                let medium = portada["medium"] as! NSString as String
                                if let checkedUrl = URL(string: medium) {
                                    let data = try? Data(contentsOf: checkedUrl)
                                    let image = UIImage(data: data!)
                                    self.libro.cover = image
                                }
                            }
                            else if (portada["small"] != nil) {
                                let small = portada["small"] as! NSString as String
                                if let checkedUrl = URL(string: small) {
                                    let data = try? Data(contentsOf: checkedUrl)
                                    let image = UIImage(data: data!)
                                    self.libro.cover = image
                                }
                            }
                            else if (portada["large"] != nil) {
                                let large = portada["large"] as! NSString as String
                                if let checkedUrl = URL(string: large) {
                                    let data = try? Data(contentsOf: checkedUrl)
                                    let image = UIImage(data: data!)
                                    self.libro.cover = image
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.indicator.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                            self.textView.attributedText = self.libro.getAttributedText()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            let title = NSLocalizedString("Advertencia", comment: "")
                            let message = NSLocalizedString("EL ISBN no existe, intente con otro.", comment: "")
                            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                                NSLog("La alerta acaba de ocurrir.")
                            }
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                catch let error as NSError {
                    DispatchQueue.main.async {
                        let title = NSLocalizedString("Error \(error.code)", comment: "")
                        let message = NSLocalizedString(error.localizedDescription, comment: "")
                        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                            NSLog("La alerta acaba de ocurrir.")
                        }
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else {
                let e = error! as NSError
                print(e)
                DispatchQueue.main.async {
                    let title = NSLocalizedString("Error \(e.code)", comment: "")
                    let message = NSLocalizedString(e.localizedDescription, comment: "")
                    let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                        NSLog("La alerta acaba de ocurrir.")
                    }
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        let dt: URLSessionDataTask = sesion.dataTask(with: url! as URL, completionHandler: bloque)
        dt.resume()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.libro = Libro()
        textView.text = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    @IBAction func cancelar(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func agregar(_ sender: UIBarButtonItem) {
        if let delegado = self.delegado {
            if !self.libro.isEmpty() {
                self.libro.isbn = self.libro.isbn?.replacingOccurrences(of: "-", with: "")
                
                let libroEntidad = NSEntityDescription.entity(forEntityName: "LibroEntidad", in: self.contexto!)
                let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplate(withName: "peticionLibro", substitutionVariables: ["isbn": self.libro.isbn!])
                do {
                    let libroEntidad2: [Any]? = try self.contexto?.fetch(peticion!)
                    if ((libroEntidad2?.count)! > 0) {
                        let title = NSLocalizedString("Advertencia", comment: "")
                        let message = NSLocalizedString("Este libro ya se encuentra en la lista.", comment: "")
                        let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                            NSLog("La alerta acaba de ocurrir.")
                        }
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        delegado.agregarLibro(libro: self.libro)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                catch let error as NSError {
                    let title = NSLocalizedString("Error \(error.code)", comment: "")
                    let message = NSLocalizedString(error.localizedDescription, comment: "")
                    let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                        NSLog("La alerta acaba de ocurrir.")
                    }
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else {
                let title = NSLocalizedString("Advertencia", comment: "")
                let message = NSLocalizedString("No se buscó algún libro, por lo tanto no se pudo agregar alguno.", comment: "")
                let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                    NSLog("La alerta acaba de ocurrir.")
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
