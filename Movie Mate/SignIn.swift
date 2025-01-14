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
        
        //Boş alana tıklandığında klavyenin kapanmasını sağlar.
        let gestureRecognizerKlavye = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                view.addGestureRecognizer(gestureRecognizerKlavye)
    }
    @objc func hideKeyboard() {
               view.endEditing(true)
       }
    @IBAction func SignInButton(_ sender: Any) {
        // Giriş yapma işlemi
        if emailText.text != nil && passwordText.text != nil {
             let email = emailText.text
             let password = passwordText.text
             
             Auth.auth().signIn(withEmail: email!, password: password!) { (autdata, error) in
                 if error != nil {
                     self.makeAlert(titleInput: "ERROR", messageInput: error?.localizedDescription ?? "ERROR", button: "OK")
                 } else {
                     self.performSegue(withIdentifier: "toAnasayfa", sender: nil)
                     
                 }
                 
             }
         } else {
             makeAlert(titleInput: "ERROR", messageInput: "Email/Password cannot be blank!!", button: "OK")
         }
    }
    
 

}
