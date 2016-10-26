//
//  ViewController.swift
//  Accediendo-a-la-nube-con-iOS_Semana-1_Petici-n-al-servidor-openlibrary.org
//
//  Created by Juan Carlos Carbajal Ipenza on 5/10/16.
//  Copyright © 2016 Juan Carlos Carbajal Ipenza. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var textView: UITextView!
    var pending: UIAlertController!
    var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
                        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
                        let bodyFont = UIFont(descriptor: bodyFontDescriptor, size: 0)
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        let attributedText = NSMutableAttributedString.init(string: "")
                        
                        DispatchQueue.main.async {
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
                            let titulo = dico2["title"] as! NSString as String + "\n"
                            let boldFontDescriptor = self.textView.font!.fontDescriptor.withSymbolicTraits(.traitBold)
                            let boldFont = UIFont(descriptor: boldFontDescriptor!, size: 24.0)
                            let agregarTitulo = NSMutableAttributedString.init(string: titulo)
                            agregarTitulo.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, agregarTitulo.length))
                            agregarTitulo.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, agregarTitulo.length))
                            agregarTitulo.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 80/255, green: 165/255, blue: 247/255, alpha: 1.0), range: NSMakeRange(0, agregarTitulo.length))
                            attributedText.append(agregarTitulo)
                        }
                    
                        if (dico2["authors"] != nil) {
                            let autores = dico2["authors"] as! NSArray as Array
                            let autor0 = autores[0] as! NSDictionary
                            if (autor0["name"] != nil) {
                                var texto_autores = "escrito por "
                                texto_autores += autor0["name"] as! NSString as String
                                for index in 1..<autores.count {
                                    let autor = autores[index] as! NSDictionary
                                    if (autor["name"] != nil) {
                                        texto_autores += ", "
                                        texto_autores += autor["name"] as! NSString as String
                                    }
                                }
                                texto_autores += "\n\n"
                                let agregarNombre = NSMutableAttributedString.init(string: texto_autores)
                                agregarNombre.addAttribute(NSFontAttributeName, value: bodyFont, range: NSMakeRange(0, agregarNombre.length))
                                agregarNombre.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, agregarNombre.length))
                                agregarNombre.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0), range: NSMakeRange(0, agregarNombre.length))
                                attributedText.append(agregarNombre)
                            }
                        }
                    
                        if (dico2["cover"] != nil) {
                            let portada = dico2["cover"] as! NSDictionary
                            if (portada["medium"] != nil) {
                                let medium = portada["medium"] as! NSString as String
                                if let checkedUrl = URL(string: medium) {
                                    let textAttachment = NSTextAttachment()
                                    let data = try? Data(contentsOf: checkedUrl)
                                    let image = UIImage(data: data!)
                                    textAttachment.image = image
                                    textAttachment.bounds = CGRect(origin: CGPoint.zero, size: (image?.size)!)
                                    let textAttachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: textAttachment))
                                    textAttachmentString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, textAttachmentString.length))
                                    attributedText.append(textAttachmentString)
                                }
                            }
                            else if (portada["small"] != nil) {
                                let small = portada["small"] as! NSString as String
                                if let checkedUrl = URL(string: small) {
                                    let textAttachment = NSTextAttachment()
                                    let data = try? Data(contentsOf: checkedUrl)
                                    let image = UIImage(data: data!)
                                    textAttachment.image = image
                                    textAttachment.bounds = CGRect(origin: CGPoint.zero, size: (image?.size)!)
                                    let textAttachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: textAttachment))
                                    textAttachmentString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, textAttachmentString.length))
                                    attributedText.append(textAttachmentString)
                                }
                            }
                            else if (portada["large"] != nil) {
                                let large = portada["large"] as! NSString as String
                                if let checkedUrl = URL(string: large) {
                                    let textAttachment = NSTextAttachment()
                                    let data = try? Data(contentsOf: checkedUrl)
                                    let image = UIImage(data: data!)
                                    textAttachment.image = image
                                    textAttachment.bounds = CGRect(origin: CGPoint.zero, size: (image?.size)!)
                                    let textAttachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: textAttachment))
                                    textAttachmentString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, textAttachmentString.length))
                                    attributedText.append(textAttachmentString)
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.indicator.stopAnimating()
                            self.dismiss(animated: true, completion: nil)
                            self.textView.attributedText = attributedText
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
                let e = error as! NSError
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
        textView.text = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }}
