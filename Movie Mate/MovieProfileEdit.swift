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
         //eski durum. kullanıcının resmi firebase e kaydedilir.
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//                let storageReference = storage.reference()
//                let mediaFolder = storageReference.child("userPhotos")
//
//        if let data = userPhoto.image?.jpegData(compressionQuality: 0.99) {
//            let imageReference = mediaFolder.child("\(uid).jpg")
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpeg"
//            
//            imageReference.putData(data, metadata: metadata) { metadata, error in
//                if let error = error {
//                    print("Error uploading image: \(error.localizedDescription)")
//                    return
//                }
//                imageReference.downloadURL { url, error in
//                    if let error = error {
//                        print("Error getting download URL: \(error.localizedDescription)")
//                        return
//                    }
//                    if let imageURL = url?.absoluteString {
//                        guard let uid = Auth.auth().currentUser?.uid else { return }
//                        
//                        self.database.collection("users").document(uid).updateData([
//                            "userPhoto": imageURL
//                        ]) { error in
//                            if let error = error {
//                                print("Error saving image URL to Firestore: \(error.localizedDescription)")
//                            } else {
//                                self.makeAlert(titleInput: "Congratulations", messageInput: "Your profile picture has been updated.", button: "OK")
//                            }
//                        }
//                    }
//                }
//            }
//            
//        }
        
        
        //yeni durum resim swiftogreniyorum.com a url i firebase'e kaydedilir.
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if let imageData = userPhoto.image?.jpegData(compressionQuality: 0.9) {
            
            let url = URL(string: "https://swiftogreniyorum.com/MovieMateResimler/upload_user_photo.php")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            // multipart/form-data içeriği oluştur
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(uid).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body

            // API isteğini gönder
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    self.makeAlert(titleInput: "Upload error", messageInput: "Error \(error.localizedDescription)", button: "Tamam")

                    return
                }

                guard let data = data else {
                    print("No data received")
                    self.makeAlert(titleInput: "Error", messageInput: "No data received", button: "Tamam")

                    return
                }

                // JSON yanıtı ayrıştır
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool,
                       success == true,
                       let imageURL = json["url"] as? String {

                        print("Gelen resim URL: \(imageURL)")

                        // Firestore'a resmi kaydet
                        DispatchQueue.main.async {
                            self.database.collection("users").document(uid).updateData([
                                "userPhoto": imageURL
                            ]) { error in
                                if let error = error {
                                    print("Firestore hata: \(error.localizedDescription)")
                                    self.makeAlert(titleInput: "Hata", messageInput: "Firestore hata", button: "Tamam")

                                } else {
                                    self.makeAlert(titleInput: "Başarılı", messageInput: "Profil fotoğrafı güncellendi", button: "Tamam")
                                }
                            }
                        }

                    } else {
                        print("Yanıt formatı hatalı veya yükleme başarısız")
                    }
                } catch {
                    print("JSON çözümleme hatası: \(error.localizedDescription)")
                }

            }.resume()
        }


    } // bitiş
    
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
    
    
    
    @IBAction func favoriCommentWatchedEdit(_ sender: Any) {
        performSegue(withIdentifier: "edit", sender: nil)
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
                        self.makeAlert(titleInput: "ERROR", messageInput: error.localizedDescription, button: "OK")
                    } else {
                        self.makeAlert(titleInput: "Congratulations", messageInput: "Your profile has been updated", button: "OK")
                    }
                }
        }
    
    
    
    


    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
