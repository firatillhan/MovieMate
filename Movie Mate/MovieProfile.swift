//
//  MovieProfile.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.11.2024.
//

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage

class MovieProfile: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userNameAndSurname: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userBiografi: UILabel!
    @IBOutlet weak var userWatchedCount: UILabel!
    
    var emptyMessageLabel: UILabel!
    
    let currentUser = Auth.auth().currentUser!
    let database = Firestore.firestore()
    var users_username = String()  //userdata için

    var watchedList = [Watched]()
    var movieName = String()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userPhoto.layer.cornerRadius = CGRectGetWidth(self.userPhoto.frame) / 2
        userPhoto.layer.borderWidth = 2
        navigationController?.navigationBar.topItem?.title = users_username
        collectionView.delegate = self
        collectionView.dataSource = self
        movieDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emptyLabel()
        userData()
        movieWatchedCountFetch()
        watchedMovieFetch()
    }
    
    func emptyLabel(){
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        emptyMessageLabel.text = "No Wached Movie"
        emptyMessageLabel.textColor = .gray
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = UIFont.systemFont(ofSize: 20)
        collectionView.backgroundView = emptyMessageLabel
    }
    

    
    
    func userData(){
        guard let users_userId = Auth.auth().currentUser?.uid else { return }
        
        database.collection("users").document(users_userId).getDocument { document, error in
            
            if let document = document, document.exists {
                let data = document.data()
                self.navigationController?.navigationBar.topItem?.title = data?["username"] as? String ?? ""
                
                let users_name = data?["name"] as? String ?? "no name"
                let users_surname = data?["surname"] as? String ?? "no surname"
                self.userNameAndSurname.text = "\(users_name) \(users_surname)"
                
                self.userEmail.text = data?["userEmail"] as? String ?? ""
                self.userBiografi.text = data?["userBiografi"] as? String ?? ""
                
                self.users_username = data?["username"] as? String ?? ""
                
                let users_userPhotoUrl = data?["userPhoto"] as? String ?? ""
                
                if let photoUrl = URL(string: users_userPhotoUrl) {
                    self.userPhoto.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholder"))
                } else {
                    self.userPhoto.image = UIImage(named: "wallpaper")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    @IBAction func logOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logOut", sender: nil)
        } catch {
            
        }
    }
    
    @IBAction func profileEditButton(_ sender: Any) {
        performSegue(withIdentifier: "toProfileEditing", sender: nil)
    }
    
    
    
    
    func watchedMovieFetch(){
        
        database.collection("movieWatched").whereField("userId", isEqualTo: currentUser.uid).addSnapshotListener { (snapshot,error) in
            if error != nil {
                self.makeAlert(titleInput: "Hata", messageInput: error?.localizedDescription ?? "Hata", button: "TAMAM")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    let group = DispatchGroup()
                    self.watchedList.removeAll(keepingCapacity: false)

                    for document in snapshot!.documents {
                        let data = document.data()
                        
                        let watchedId = document.documentID
                        let watched_movieId = data["movieId"] as? String ?? ""
                        let userId = data["userId"] as? String ?? ""
                        let watchedDate = "_"
                        
                        group.enter()
                        self.database.collection("filmListesi").document(watched_movieId).getDocument { document, error in
                            if let error = error {
                                print("Error \(error)")
                            } else {
                                
                                self.movieName = document?.data()?["movieName"] as? String ?? "No Movie Name"
                                
                                let movieImage = document?.data()?["movieImage"] as? String ?? "No Movie Image"
                                

                                let watch = Watched(watchedId: watchedId, userId: userId, watchedDate: watchedDate, movieId: watched_movieId, movieImage: movieImage, movieName: self.movieName)
                                
                                self.watchedList.append(watch)
                            }
                            group.leave()
                            self.collectionView.reloadData()
                        }
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    } // fonksiyon bitiş
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToDetail" {
            //  hazırlık
            if let indeks = sender as? Int {
                let gidilecekVC = segue.destination as! MovieDetails
                gidilecekVC.watch = watchedList[indeks]
            }
            
        }
    }
    
    
    
    
    
    
   
}





extension MovieProfile{

    func movieDesign(){
        let tasarim :UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let genislik = self.collectionView.frame.size.width
        
        tasarim.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let hucreGenislik = (genislik-15)/3
        tasarim.itemSize = CGSize(width: hucreGenislik, height: hucreGenislik)
        tasarim.minimumInteritemSpacing = 5
        tasarim.minimumLineSpacing = 5
        collectionView.collectionViewLayout = tasarim
    }
    
    //Kullanıcının izlediği filmlerin sayısını veritabanından çekmek için
    func movieWatchedCountFetch() {
        let sorgu = database.collection("movieWatched").whereField("userId", isEqualTo: currentUser.uid)
        sorgu.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    if querySnapshot.documents.count == 0 {
                        self.emptyMessageLabel.isHidden = false
                        print("liste boş: \(querySnapshot.documents.count)")
                        let sayi = querySnapshot.documents.count
                        self.userWatchedCount.text = "\(sayi)"
                    } else {
                        self.emptyMessageLabel.isHidden = true
                        let sayi = querySnapshot.documents.count
                        print("liste boş değil: \(sayi)")
                        self.userWatchedCount.text = "\(sayi)"
                    }
                }
            }
        }
    }
}


extension MovieProfile: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchedList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let w = watchedList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! MovieProfileCollectionViewCell
        cell.movieImage.sd_setImage(with: URL(string: w.movieImage))
        cell.movieIdLabel.text = w.movieId
        print("movie id: \(w.movieId)")
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "profileToDetail", sender: indexPath.row)

    }
}
