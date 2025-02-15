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
    @IBOutlet weak var userBiografi: UILabel!
    @IBOutlet weak var ProfilView: UIView!
    @IBOutlet weak var userWatchedCount: UILabel!
    
    @IBOutlet weak var followingLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var profileEdit: UIButton!
    var emptyMessageLabel: UILabel!
    
    var currentUser = Auth.auth().currentUser!
    
    let database = Firestore.firestore()
    var users_username = String()  //userdata için
    var watchedList = [Watched]()
    var movieName = String()
    var selectedUserId: String?
    
    //let girisYapanKullanici = self.currentUser.uid
    //let profilineBakilanKullanici = self.selectedUserId!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.title = users_username
        collectionView.delegate = self
        collectionView.dataSource = self
        movieDesign()
//        NSLayoutConstraint.activate([
//            userPhoto.heightAnchor.constraint(equalTo: ProfilView.heightAnchor, multiplier: 0.5),
//            userPhoto.widthAnchor.constraint(equalTo: userPhoto.heightAnchor),
//        ])
        userPhoto.layer.cornerRadius = CGRectGetWidth(self.userPhoto.frame)/2.0
        userPhoto.layer.masksToBounds = true
        let genislik = userPhoto.frame.size.width
        print("foto genislik:\(genislik)")


       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        
        if let user = selectedUserId {
            userData(id: user)
            followControl(CurrentUserID: currentUser.uid, VisitedUserID: user)

        } else {
            collectionView.reloadData()
            userData(id: currentUser.uid)
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
        if let title = (sender as AnyObject).currentTitle {
            switch title {
            case "Profile Edit":
                performSegue(withIdentifier: "toProfileEditing", sender: nil)
            case "Follow":
                following(CurrentUserID: currentUser.uid, VisitedUserID: selectedUserId!)
            case "Following":
                deleteFollow(CurrentUserID: currentUser.uid, VisitedUserID: selectedUserId!)
            default:
               print("Error")
            }
        }
    }
    func deleteFollow(CurrentUserID:String,VisitedUserID:String){
        let delete = database.collection("Follow")
        let query = delete.whereField("FollowerUserId", isEqualTo:CurrentUserID).whereField("FollowedUserId", isEqualTo: selectedUserId!)
        
        query.getDocuments { (snapshot, error) in
            
            // Iterate through documents and delete each
            for document in snapshot!.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting follow document: \(error.localizedDescription)")
                        self.makeAlert(titleInput: "ERROR", messageInput: "delete işlemi Error", button: "OK")
                    } else {

                        self.viewWillAppear(true)

                    }
                }
            }
        }
    }
  
    func followControl(CurrentUserID:String,VisitedUserID:String){
        // Belirli bir dökümanı kontrol etme
        let followRef = database.collection("Follow")
        let query = followRef.whereField("FollowerUserId", isEqualTo:CurrentUserID).whereField("FollowedUserId", isEqualTo: selectedUserId!)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.makeAlert(titleInput: "ERROR", messageInput: error.localizedDescription, button: "OK")
                return
            }
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Kullanıcının bu kişiyi daha önce takip ediyorsa
                self.profileEdit.setTitle("Following", for: .normal)
            }
        }
    }

    func following(CurrentUserID:String,VisitedUserID:String){
        
        // Belirli bir dökümanı kontrol etme
        let followRef = database.collection("Follow")
        let query = followRef.whereField("FollowerUserId", isEqualTo:CurrentUserID).whereField("FollowedUserId", isEqualTo: selectedUserId!)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.makeAlert(titleInput: "ERROR", messageInput: error.localizedDescription, button: "OK")
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Kullanıcının bu kişiyi daha önce takip ediyorsa
                self.profileEdit.setTitle("Following", for: .normal)
            } else {
                let newData = ["FollowerUserId": CurrentUserID,
                               "FollowedUserId": self.selectedUserId!,
                               "followDate": FieldValue.serverTimestamp()] as [String : Any]
                self.database.collection("Follow").addDocument(data: newData) { (error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                    self.profileEdit.setTitle("Following", for: .normal)
                    self.viewWillAppear(true)
                }
            }
            
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToDetail" {
            //  profil sayfasındaki filme tıklandığında filmin detaylarını görmek için movieDetails sayfasına butun index bilgilerini göndermek için
            if let indeks = sender as? Int {
                let gidilecekVC = segue.destination as! MovieDetails
                gidilecekVC.watch = watchedList[indeks]
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
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "profileToDetail", sender: indexPath.row)
    }
    
}
