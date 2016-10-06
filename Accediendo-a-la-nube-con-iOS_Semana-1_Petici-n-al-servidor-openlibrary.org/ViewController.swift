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
        let datos: NSData? = NSData(contentsOf: url! as URL)
        if (datos != nil) {
            let texto: NSString? = NSString(data: datos! as Data, encoding: String.Encoding.utf8.rawValue)
            self.textView.text = texto! as String
            searchBar.resignFirstResponder()
        }
        else {
            let title = NSLocalizedString("Alerta", comment: "")
            let message = NSLocalizedString("No se puede conectar al servidor.", comment: "")
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                NSLog("La alerta acaba de ocurrir.")
            }
            alertController.addAction(cancelAction)
            
            searchBar.resignFirstResponder()
            present(alertController, animated: true, completion: nil)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        textView.text = ""
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

