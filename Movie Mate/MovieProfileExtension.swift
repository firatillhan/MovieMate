//
//  MovieProfileExtension.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 10.01.2025.
//

import Foundation
import UIKit
import FirebaseAuth


extension MovieProfile {
    
   
    
    func movieDesign(){
        let tasarim :UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let genislik = self.collectionView.frame.size.width
    
        tasarim.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let hucreGenislik = (genislik-10)/3
        tasarim.itemSize = CGSize(width: hucreGenislik, height: hucreGenislik)
        tasarim.minimumInteritemSpacing = 5
        tasarim.minimumLineSpacing = 5
        collectionView.collectionViewLayout = tasarim
    }
    
   
    
    
    func userData(id:String) {
        print("User id: \(id)")
        if currentUser.uid != id {
            profileEdit.setTitle("Follow", for: .normal)
        } else {
            profileEdit.setTitle("Profile Edit", for: .normal)
        }
        
        database.collection("users").document(id).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                
                self.navigationController?.navigationBar.topItem?.title = data?["username"] as? String ?? ""
                let users_name = data?["name"] as? String ?? "no name"
                let users_surname = data?["surname"] as? String ?? "no surname"
                self.userNameAndSurname.text = "\(users_name) \(users_surname)"
                //self.userEmail.text = data?["userEmail"] as? String ?? ""
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
        
        database.collection("movieWatched").whereField("userId", isEqualTo: id).addSnapshotListener { (snapshot,error) in
            if error != nil {
                self.makeAlert(titleInput: "ERROR", messageInput: error?.localizedDescription ?? "ERROR", button: "OK")
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
                                print("ERROR \(error)")
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
        
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        emptyMessageLabel.text = "No Wached Movie"
        emptyMessageLabel.textColor = .gray
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = UIFont.systemFont(ofSize: 20)
        collectionView.backgroundView = emptyMessageLabel
        
        let sorgu = database.collection("movieWatched").whereField("userId", isEqualTo: id)
        
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
                        self.collectionView.isHidden = true
                                                
                    } else {
                        self.emptyMessageLabel.isHidden = true
                        let sayi = querySnapshot.documents.count
                        print("liste boş değil: \(sayi)")
                        self.userWatchedCount.text = "\(sayi)"
                        self.collectionView.isHidden = false

                    }
                }
            }
        }
        // Profili gösterilen kullanıcının takip ettiği kişi sayısı...
        let takipEdilen = database.collection("Follow").whereField("FollowerUserId", isEqualTo: id)

        takipEdilen.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    let sayi = querySnapshot.documents.count
                    self.followLabel.text = "\(sayi)"
                    
                }
            }
        }
        
        let takipci = database.collection("Follow").whereField("FollowedUserId", isEqualTo: id)

        takipci.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    let sayi = querySnapshot.documents.count
                    self.followersLabel.text = "\(sayi)"
                    
                }
            }
        }

        
        
    } //guest user data finish
    
    

    
} //extension bitiş
