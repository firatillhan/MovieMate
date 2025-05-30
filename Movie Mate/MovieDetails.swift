//
//  MovieDetails.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 18.12.2024.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class MovieDetails: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieScore: UIButton!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var movieDuration: UILabel!
    @IBOutlet weak var movieDirector: UILabel!
    @IBOutlet weak var movieStars: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
     
    @IBOutlet weak var commentsButtonLabel: UIButton!
    
    var movie:Movies?
    var favori:Favories?
    var oneri:Oneriler?
    var watch:Watched?
    var movieId = String()
    var oneriFilmName = String()
    var SmovieName = String()
    let storage = Storage.storage()
    var selectedImage: UIImage?
    
   
    
    let database = Firestore.firestore()
    

    let currentUser = Auth.auth().currentUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Köşe yarıçapı
        
        //commentButton.isEnabled = false
        
        if currentUser.email == "firatilhan@gmail.com" {
            updateButton.isHidden = false
            
            //resim seçmek için image view in tıklanabilirliğini aktif ediyoruz.
            movieImage.isUserInteractionEnabled = true
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectPicture))
            movieImage.addGestureRecognizer(gestureRecognizer)
        } else {
            updateButton.isHidden = true

        }
        
        //burası movie feed sayfasından gelen veriyi göstermek için...
        if let m = movie {
            movieId = m.movieId
            navigationItem.title = "\(m.movieGenre)"
            print("movie id \(movieId)")
            movieImage.sd_setImage(with: URL(string: m.movieImage))
            let score = m.movieRating
            movieScore.setTitle("\(score)/10", for: .normal)
            movieName.text = "\(m.movieName)"
            movieYear.text = "Year: \(m.movieYear)"
            movieDuration.text = "Time: \(m.movieRunTime)"
            movieDirector.text = "Director: \(m.movieDirector)"
            movieStars.text = "Stars: \(m.movieStars)"
            movieDescription.text = m.movieDescription
        }
        //movie favorite sayfasından gelen verileri göstermek için
        if let f = favori {
            movieId = f.movieId
            print("Movie ID: \(movieId)")
            movieFetch(movieId: movieId)
        }
        //profil sayfasından gelen veriyi göstermek için
        if let w = watch {
            movieId = w.movieId
            print("Movie ID: \(movieId)")
            movieFetch(movieId: movieId)
        }
        if let o = oneri {
            oneriFilmName = o.oneriFilmName
            print("Movie Name: \(oneriFilmName)")
            movieFetchByName(movieName: oneriFilmName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.movieImage.layer.cornerRadius = 10.0
        self.movieImage.layer.masksToBounds = true
        movieCommentsCountFetch()
    }
    
    
    
    
    
    func movieFetchByName(movieName:String){
        print("movie details sayfasında onerilenFilmler fonksiyonu çalıştı. movieName: \(movieName)'.")
        database.collection("filmListesi").whereField("movieName", isEqualTo: movieName).getDocuments { [self] snapshot, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("Film bulunamadı.")
                return
            }
            
            

            
            
            
            let document = documents.first!
            let data = document.data()
            let movieId = document.documentID // <<< BURADA movieId'yi çekiyoruz
            print("Movie ID: \(movieId)") // test için log
            // Movie ID’yi bir değişkene veya view’da bir yere ata
            self.movieId = movieId
            
            self.movieName.text = data["movieName"] as? String ?? ""
            let movieGenre = data["movieGenre"] as? String ?? ""
            navigationController?.navigationBar.topItem?.title = "\(movieGenre)"
            movieDescription.text = data["movieDescription"] as? String ?? ""
            let movieStars = data["movieStars"] as? String ?? ""
            self.movieStars.text = "Stars: \(movieStars)"
            let movieDirector = data["movieDirector"] as? String ?? ""
            self.movieDirector.text = "Director: \(movieDirector)"
            let movieRunTime = data["movieRunTime"] as? String ?? ""
            self.movieDuration.text = "Time: \(movieRunTime)"
            let movieYear = data["movieYear"] as? String ?? ""
            self.movieYear.text = "Year: \(movieYear)"
            let movieRating = data["movieRating"] as? String ?? ""
            movieScore.setTitle("\(movieRating)/10", for: .normal)
            if let movieImage = data["movieImage"] as? String,
               let url = URL(string: movieImage) {
                self.movieImage.sd_setImage(with: url, completed: nil)
            }
                
       
        }
    } // filmleri çek finish
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func movieFetch(movieId:String){
        print("movie details sayfasında movieFetch fonksiyonu çalıştı. MovieId: \(movieId)'.")
        database.collection("filmListesi").document(movieId).getDocument { [self] document, error in
            if let document = document, document.exists {
                let group = DispatchGroup()
                let data = document.data()
                self.movieName.text = data?["movieName"] as? String ?? ""
                let movieGenre = data?["movieGenre"] as? String ?? ""
                navigationController?.navigationBar.topItem?.title = "\(movieGenre)"
                movieDescription.text = data?["movieDescription"] as? String ?? ""
                let movieStars = data?["movieStars"] as? String ?? ""
                self.movieStars.text = "Stars: \(movieStars)"
                let movieDirector = data?["movieDirector"] as? String ?? ""
                self.movieDirector.text = "Director: \(movieDirector)"
                let movieRunTime = data?["movieRunTime"] as? String ?? ""
                self.movieDuration.text = "Time: \(movieRunTime)"
                let movieYear = data?["movieYear"] as? String ?? ""
                self.movieYear.text = "Year: \(movieYear)"
                let movieRating = data?["movieRating"] as? String ?? ""
                movieScore.setTitle("\(movieRating)/10", for: .normal)
                if let movieImage = document.data()?["movieImage"] as? String,
                   
                    let url = URL(string: movieImage) {
                    self.movieImage.sd_setImage(with: url, completed: nil)
                }
                group.enter()
            }
        }
    } // filmleri çek finish
    
    @objc func selectPicture() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let secilenResim = info[.originalImage] as? UIImage {
            movieImage.image = secilenResim
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateButton(_ sender: Any) {

        //film resmini swiftogreniyorum.com a kaydet
        
        if let data = movieImage.image?.jpegData(compressionQuality: 0.5) {
            var request = URLRequest(url: URL(string: "https://www.swiftogreniyorum.com/MovieMateResimler/upload.php")!)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            let uuid = UUID().uuidString
            let filename = "\(uuid).jpg"

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)

            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Upload error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data returned")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let imageUrl = json["url"] as? String {
                    print("Image uploaded, url: \(imageUrl)")
                    
                    // Firestore’a bu URL’yi kaydet
                    let movieImageUpdate = ["movieImage": imageUrl]
                    let database = Firestore.firestore()
                    
                    database.collection("filmListesi").document(self.movieId).updateData(movieImageUpdate) { error in
                        if let error = error {
                            print("Firestore update error: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.makeAlert(titleInput: "Congratulations", messageInput: "Updated", button: "OK") { _ in
                                    self.goBackButton()
                                }
                            }
                        }
                    }
                }
            }.resume()
        }

        
        

    }// button bitiş
    
    
    @IBAction func LikeAddButton(_ sender: Any) {
        let userId = currentUser.uid
        print("user Id: \(userId)")
        print("movieId: \(movieId)")
        
        // Belirli bir dökümanı kontrol etme
        let database = Firestore.firestore()
        let likesRef = database.collection("movieLikes")
        let query = likesRef.whereField("userId", isEqualTo:userId).whereField("movieId", isEqualTo: movieId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.makeAlert(titleInput: "ERROR", messageInput: error.localizedDescription, button: "OK")
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Kullanıcının bu filmi daha önce favorilere eklediğini belirten hata mesajı
                self.makeAlert(titleInput: "Error", messageInput: "This movie is already on your list.", button: "OK")
            } else {
                if userId != "" && self.movieId != ""{
                    let likeAdd : [String:Any] = [
                        "likeId": "",
                        "userId": userId,
                        "movieId": self.movieId
                    ]
                    let database = Firestore.firestore()
                    database.collection("movieLikes").addDocument(data: likeAdd) { error in
                        if let error = error {
                            print("Error \(error)")
                        } else {
                            self.makeAlert(titleInput: "Congratulations", messageInput: "The movie has been successfully added to your list", button: "OK")
                        }
                    }
                } else {
                    
                    self.makeAlert(titleInput: "ERROR", messageInput: "An unknown error occurred", button: "OK")
                    }
                }
            }
        
        
        
    }
    
    
    @IBAction func watchedAddButton(_ sender: Any) {
        let userId = currentUser.uid
        print("user Id: \(userId)")
        print("movieId: \(movieId)")
        
        // Belirli bir dökümanı kontrol etme
        let database = Firestore.firestore()
        let watchedRef = database.collection("movieWatched")
        let query = watchedRef.whereField("userId", isEqualTo:userId).whereField("movieId", isEqualTo: movieId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.makeAlert(titleInput: "ERROR", messageInput: error.localizedDescription, button: "OK")
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Kullanıcının bu filmi daha önce izlediği listeye eklediğini belirten hata mesajı
                self.makeAlert(titleInput: "Error", messageInput: "This movie is already on your list.", button: "OK")
            } else {
                if userId != "" && self.movieId != ""{
                    let watchedAdd : [String:Any] = [
                        "watchedId": "",
                        "userId": userId,
                        "watchedDate": FieldValue.serverTimestamp(),
                        "movieId": self.movieId
                    ]
                    let database = Firestore.firestore()
                    database.collection("movieWatched").addDocument(data: watchedAdd) { error in
                        if let error = error {
                            print("Error \(error)")
                        } else {
                            self.makeAlert(titleInput: "Congratulations", messageInput: "The movie has been successfully added to your list", button: "OK")
                        }
                    }
                } else {
                    
                    self.makeAlert(titleInput: "Error", messageInput: "An unknown error occurred", button: "OK")
                    }
                }
            }
        
    }
    
    
    @IBAction func commentAddButton(_ sender: Any) {
        print("MovieID\(movieId)")
        print("userId\(currentUser.uid)")
        
            // Alert controller oluşturuyoruz
            let alert = UIAlertController(title: "Write a review for this movie", message: nil, preferredStyle: .alert)
            
            // Alert'a bir text field ekliyoruz
            alert.addTextField { (textField) in
                textField.placeholder = "Comment Field"
            }
            
            // Gönder butonu ekliyoruz
            let sendAction = UIAlertAction(title: "Sender", style: .default) { [weak alert] (_) in
                if let comment = alert?.textFields?[0].text {
                    print("Comment: \(comment)")

                    let commentSave = ["commendId":"",
                                       "commentText": comment,
                                       "userId": self.currentUser.uid,
                                       "commentDate": FieldValue.serverTimestamp(),
                                       "movieId": self.movieId ] as [String : Any]
                    
                    let database = Firestore.firestore()
                    database.collection("comments").addDocument(data: commentSave, completion: { (error) in
                        if error != nil {
                            self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!", button: "OK")
                        } else {
                            self.makeAlert(titleInput: "Congratulations", messageInput: "Your comment's add", button: "OK") { UIAlertAction in
                                self.viewWillAppear(true)
                                self.okButton()
                            }
                        }
                    })
                } //comment
            } //send
   
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            alert.addAction(sendAction)
            alert.addAction(cancelAction)

            // Alert'ı gösteriyoruz
            self.present(alert, animated: true, completion: nil)

    } //button
    
    
    
    
    
    
    @IBAction func commentButton(_ sender: Any) {
        performSegue(withIdentifier: "toComment", sender: nil)
    
}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toComment" {
               if let destinationVC = segue.destination as? MovieComments {
                   // Filmin detaylarını Yorumlar sayfasına aktarıyoruz
                   destinationVC.movieId = movieId
                   destinationVC.SelectedmovieName = SmovieName
                   
                
               }
           }
       }
    
    
    @objc func okButton(){
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc func goBackButton(){
       // self.tabBarController?.selectedIndex = 0
        navigationController?.popViewController(animated: true)
    }
    
    
    //filme ait yorum sayısını veritabanından çekmek için
    func movieCommentsCountFetch() {
        let sorgu = database.collection("comments").whereField("movieId", isEqualTo: movieId)
        sorgu.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    let sayi = querySnapshot.documents.count
                    print("liste boş değil: \(sayi)")
                    self.commentsButtonLabel.setTitle("Comments (\(sayi))", for: .normal)
                }
            }
        }
    }
    
    



    
}


