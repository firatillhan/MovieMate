//
//  MovieProfileEdit.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 26.12.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MovieProfileEdit: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var userBiografiTextView: UITextView!
    
    let kullanici = Auth.auth().currentUser!
    let database = Firestore.firestore()
    let storage = Storage.storage()
    
    var username = String()
    var selectedImage: UIImage?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.title = "Your Profile Edit"
        userPhoto.layer.cornerRadius = userPhoto.frame.width / 2
        userPhoto.clipsToBounds = true
        
        let gestureRecognizerKlavye = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                view.addGestureRecognizer(gestureRecognizerKlavye)
        
        userPhoto.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resimSec))
        userPhoto.addGestureRecognizer(gestureRecognizer)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        userData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func userData(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        database.collection("users").document(userId).getDocument { document, error in
         
            if let document = document, document.exists {
                let data = document.data()
                self.navigationController?.navigationBar.topItem?.title = data?["username"] as? String ?? ""
                
                self.nameTextField.text = data?["name"] as? String ?? "no name"
                self.surnameTextField.text = data?["surname"] as? String ?? "no surname"
                
                self.userBiografiTextView.text = data?["userBiografi"] as? String ?? ""
                
                self.username = data?["username"] as? String ?? ""
                
                let userPhotoUrl = data?["userPhoto"] as? String ?? ""
                        
                if let photoUrl = URL(string: userPhotoUrl) {
                    self.userPhoto.sd_setImage(with: photoUrl)

                } else {
                    self.userPhoto.image = UIImage(named: "wallpaper")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func SaveImageButton(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
                let storageReference = storage.reference()
                let mediaFolder = storageReference.child("userPhotos")

                if let data = userPhoto.image?.jpegData(compressionQuality: 0.99) {
                    let imageReference = mediaFolder.child("\(uid).jpg")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"

                    imageReference.putData(data, metadata: metadata) { metadata, error in
                        if let error = error {
                            print("Error uploading image: \(error.localizedDescription)")
                            return
                        }
                        imageReference.downloadURL { url, error in
                            if let error = error {
                                print("Error getting download URL: \(error.localizedDescription)")
                                return
                            }
                            if let imageURL = url?.absoluteString {
                                guard let uid = Auth.auth().currentUser?.uid else { return }

                                self.database.collection("users").document(uid).updateData([
                                    "userPhoto": imageURL
                                ]) { error in
                                    if let error = error {
                                        print("Error saving image URL to Firestore: \(error.localizedDescription)")
                                    } else {
                                        self.makeAlert(titleInput: "Tebrikler", messageInput: "Profil resminiz güncellendi", button: "Tamam")
                                    }
                                }
                            }
                        }
                    }
                }
        
        
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
                let userData: [String: Any] = [
                    "name": nameTextField.text ?? "",
                    "surname": surnameTextField.text ?? "",
                    "userBiografi": userBiografiTextView.text ?? ""
                ]
                self.database.collection("users").document(uid).updateData(userData) { error in
                    if let error = error {
                        self.makeAlert(titleInput: "Hata", messageInput: error.localizedDescription, button: "TAMAM")
                    } else {
                        self.makeAlert(titleInput: "Tebrikler", messageInput: "Profiliniz Güncellendi", button: "Tamam")
                    }
                }
        }
    
    
    
    
    
    @objc func resimSec() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        userPhoto.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
