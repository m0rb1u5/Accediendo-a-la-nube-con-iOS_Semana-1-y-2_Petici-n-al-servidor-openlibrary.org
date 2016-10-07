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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBar.showsCancelButton = true
        let cancelButton = searchBar.value(forKey: "cancelButton") as! UIButton
        cancelButton.setTitle("Limpiar", for: .normal)
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
                let texto: NSString? = NSString(data: datos! as Data, encoding: String.Encoding.utf8.rawValue)
                DispatchQueue.main.async {
                    self.textView.text = texto! as String
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
    }
}

