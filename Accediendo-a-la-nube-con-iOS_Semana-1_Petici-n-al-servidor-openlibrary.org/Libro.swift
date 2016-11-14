//
//  Libro.swift
//  Accediendo-a-la-nube-con-iOS_Semana-1_Petici-n-al-servidor-openlibrary.org
//
//  Created by Juan Carlos Carbajal Ipenza on 11/11/16.
//  Copyright © 2016 Juan Carlos Carbajal Ipenza. All rights reserved.
//

import Foundation
import UIKit

class Libro {
    var titulo: String?
    var autores: Array<String> = Array<String>()
    var cover: UIImage?
    
    init() {
        self.titulo = nil
        self.autores = Array<String>()
        self.cover = nil
    }
    init(titulo: String?, autores: Array<String>, cover: UIImage?) {
        self.titulo = titulo
        self.autores = autores
        self.cover = cover
    }
    func getAttributedText() -> NSMutableAttributedString {
        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
        let bodyFont = UIFont(descriptor: bodyFontDescriptor, size: 0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributedText = NSMutableAttributedString.init(string: "")
        
        if (self.titulo != nil) {
            let boldFontDescriptor = bodyFont.fontDescriptor.withSymbolicTraits(.traitBold)
            let boldFont = UIFont(descriptor: boldFontDescriptor!, size: 24.0)
            let agregarTitulo = NSMutableAttributedString.init(string: self.titulo! + "\n")
            agregarTitulo.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, agregarTitulo.length))
            agregarTitulo.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, agregarTitulo.length))
            agregarTitulo.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 80/255, green: 165/255, blue: 247/255, alpha: 1.0), range: NSMakeRange(0, agregarTitulo.length))
            attributedText.append(agregarTitulo)
        }
        if (!self.autores.isEmpty) {
            var texto_autores = "escrito por "
            texto_autores += self.autores[0]
            for index in 1..<self.autores.count {
                texto_autores += ", "
                texto_autores += self.autores[index]
            }
            texto_autores += "\n\n"
            let agregarNombre = NSMutableAttributedString.init(string: texto_autores)
            agregarNombre.addAttribute(NSFontAttributeName, value: bodyFont, range: NSMakeRange(0, agregarNombre.length))
            agregarNombre.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, agregarNombre.length))
            agregarNombre.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0), range: NSMakeRange(0, agregarNombre.length))
            attributedText.append(agregarNombre)
        }
        if (self.cover != nil) {
            let textAttachment = NSTextAttachment()
            let image = self.cover!
            textAttachment.image = image
            textAttachment.bounds = CGRect(origin: CGPoint.zero, size: (image.size))
            let textAttachmentString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: textAttachment))
            textAttachmentString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, textAttachmentString.length))
            attributedText.append(textAttachmentString)
        }
        return attributedText
    }
    func isEmpty() -> Bool {
        if (self.titulo == nil && self.autores.isEmpty && self.cover == nil) {
            return true
        }
        else {
            return false
        }
    }
}
