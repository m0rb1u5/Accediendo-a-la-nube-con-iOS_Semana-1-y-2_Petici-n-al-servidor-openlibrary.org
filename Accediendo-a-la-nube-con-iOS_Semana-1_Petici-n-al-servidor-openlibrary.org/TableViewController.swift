//
//  TableViewController.swift
//  Accediendo-a-la-nube-con-iOS_Semana-1_Petici-n-al-servidor-openlibrary.org
//
//  Created by Juan Carlos Carbajal Ipenza on 11/11/16.
//  Copyright © 2016 Juan Carlos Carbajal Ipenza. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, MyDelegado {
    var libros: Array<Libro> = Array<Libro>()
    var contexto: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let libroEntidad = NSEntityDescription.entity(forEntityName: "LibroEntidad", in: self.contexto!)
        let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplate(forName: "peticionLibros")
        do {
            let librosEntidades: [Any]? = try self.contexto?.fetch(peticion!)
            for libroEntidad2 in librosEntidades! {
                let libro: Libro = Libro()
                let isbn = (libroEntidad2 as AnyObject).value(forKey: "isbn")
                if (isbn != nil) {
                    libro.isbn =  isbn as? String
                }
                let titulo = (libroEntidad2 as AnyObject).value(forKey: "titulo")
                if (titulo != nil) {
                    libro.titulo = titulo as? String
                }
                let cover = (libroEntidad2 as AnyObject).value(forKey: "cover")
                if (cover != nil) {
                    libro.cover = UIImage(data: cover as! Data)
                }
                let autores = (libroEntidad2 as AnyObject).value(forKey: "tiene")
                if (autores != nil) {
                    let autoresEntidades = autores as! Set<NSObject>
                    for autorEntidad in autoresEntidades {
                        libro.autores.append(autorEntidad.value(forKey: "nombre") as! String)
                    }
                }
                self.libros.append(libro)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func agregarLibro(libro: Libro) {
        let libroEntidad = NSEntityDescription.insertNewObject(forEntityName: "LibroEntidad", into: self.contexto!)
        if (libro.isbn != nil) {
            libroEntidad.setValue(libro.isbn!, forKey: "isbn")
        }
        if (libro.titulo != nil) {
            libroEntidad.setValue(libro.titulo!, forKey: "titulo")
        }
        if (libro.cover != nil) {
            libroEntidad.setValue(UIImageJPEGRepresentation(libro.cover!, 0.5), forKey: "cover")
        }
        libroEntidad.setValue(self.crearAutoresEntidades(autores: libro.autores), forKey: "tiene")
        do {
            try self.contexto?.save()
            self.libros.append(libro)
            self.tableView.reloadData()
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
    func crearAutoresEntidades(autores: Array<String>) -> Set<NSObject> {
        var entidades = Set<NSObject>()
        for autor in autores {
            let autorEntidad = NSEntityDescription.insertNewObject(forEntityName: "AutorEntidad", into: self.contexto!)
            autorEntidad.setValue(autor, forKey: "nombre")
            entidades.insert(autorEntidad)
        }
        return entidades
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.libros.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Celda", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.libros[indexPath.row].titulo
        if (self.libros[indexPath.row].cover != nil) {
            cell.imageView?.image = self.libros[indexPath.row].cover
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Eliminar"
    }
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            
            let libroEntidad = NSEntityDescription.entity(forEntityName: "LibroEntidad", in: self.contexto!)
            let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplate(withName: "peticionLibro", substitutionVariables: ["isbn": self.libros[indexPath.row].isbn!])
            do {
                let librosEntidades: [Any]? = try self.contexto?.fetch(peticion!)
                if ((librosEntidades?.count)! > 0) {
                    for libroEntidad2 in librosEntidades! {
                        self.contexto!.delete(libroEntidad2 as! NSManagedObject)
                        try self.contexto?.save()
                    }
                    self.libros.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                else {
                    let title = NSLocalizedString("Advertencia", comment: "")
                    let message = NSLocalizedString("Este libro no se encuentra en la base de datos.", comment: "")
                    let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { action in
                        NSLog("La alerta acaba de ocurrir.")
                    }
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
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
            
            tableView.endUpdates()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detalle" {
            let detalleLibro = segue.destination as! DetalleLibroController
            let indexPath = self.tableView.indexPathForSelectedRow
            detalleLibro.myAttributedText = self.libros[indexPath!.row].getAttributedText()
        }
        else if segue.identifier == "agregar" {
            let busquedaLibro = segue.destination as! ViewController
            busquedaLibro.delegado = self
        }
    }
}
