//
//  Alert.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 9.12.2024.
//

import Foundation
import UIKit

extension UIViewController {


    func makeAlert(titleInput: String, messageInput: String, button: String, handler: ((UIAlertAction) -> Void)? = nil) {
       
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let action = UIAlertAction(title: button, style: .default, handler: handler)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        }
    

  
    
    func makeAlertTwo(titleInput:String,messageInput:String,okButton:String,cancelButton:String,handler: ((UIAlertAction) -> Void)? = nil){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: okButton, style: .default, handler: handler)
        let cancelButton = UIAlertAction(title: cancelButton, style: .default, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}
