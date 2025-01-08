//+
//  SignUp.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.11.2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SignUp: UIViewController {
    
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var password2Text: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        passwordText.isSecureTextEntry = true
//        password2Text.isSecureTextEntry = true

        let gestureRecognizerKlavye = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizerKlavye)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func signUpButton(_ sender: Any) {
        if passwordText.text != password2Text.text {
            makeAlert(titleInput: "Hata", messageInput: "Şifreler aynı değil", button: "Tamam")
            return
        } else {
            guard let username = usernameText.text, !username.isEmpty,
                  let email = emailText.text, !email.isEmpty,
                  let password = passwordText.text, !password.isEmpty,
                  let password2 = password2Text.text, !password2.isEmpty
            else {
                self.makeAlert(titleInput: "Hata", messageInput: "Lütfen Bütün alanları doldurunuz!!!", button: "TAMAM")
                return
            }
            
            let userRef = db.collection("users")
            let query = userRef.whereField("users", isEqualTo: username)
            query.getDocuments { (querySnap,error) in
                if let error = error {
                    print(error)
                    self.makeAlert(titleInput: "Hata", messageInput: "Bu kullanıcı adı daha önce alınmış", button: "Tamam")
                } else {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        
                        if let error = error {
                            self.makeAlert(titleInput: "Hata", messageInput: error.localizedDescription, button: "TAMAM")
                            return
                        }
                        guard let uid = authResult?.user.uid else { return }
                        self.db.collection("users").document(uid).setData([
                            "username": username,
                            "userId": "",
                            "name": "",
                            "surname": "",
                            "userEmail": email,
                            "userBiografi": "",
                            "userPhoto": ""
                        ]) { error in
                            if let error = error {
                                self.makeAlert(titleInput: "Hata", messageInput: error.localizedDescription, button: "TAMAM")
                            } else {
                                self.makeAlert(titleInput: "Tebrikler", messageInput: "Kayıt işleminiz tamamlanmıştır.", button: "TAMAM") { UIAlertAction in
                                    self.tamam()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func tamam() {
        print("Tamam buttona basıldı")
        self.performSegue(withIdentifier: "FirstTabBar", sender: nil)
    }
}
