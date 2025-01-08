//+
//  SignIn.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.11.2024.
//

import UIKit
import Firebase
import FirebaseAuth

class SignIn: UIViewController {
    
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        passwordText.isSecureTextEntry = true

        let gestureRecognizerKlavye = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                view.addGestureRecognizer(gestureRecognizerKlavye)
    }
    @objc func hideKeyboard() {
               view.endEditing(true)
       }
    @IBAction func SignInButton(_ sender: Any) {
        
        if emailText.text != nil && passwordText.text != nil {
             let email = emailText.text
             let password = passwordText.text
             
             Auth.auth().signIn(withEmail: email!, password: password!) { (autdata, error) in
                 if error != nil {
                     self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error", button: "Tamam")
                 } else {
                     self.performSegue(withIdentifier: "toAnasayfa", sender: nil)
                     
                 }
                 
             }
         } else {
             makeAlert(titleInput: "Hata", messageInput: "Email/Şifre boş olamaz!!", button: "Tamam")
         }
    }
    
 

}
