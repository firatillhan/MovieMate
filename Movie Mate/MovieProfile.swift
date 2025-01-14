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
    
    @IBOutlet weak var profileEdit: UIButton!
    var emptyMessageLabel: UILabel!
    
    var currentUser = Auth.auth().currentUser!
    
    let database = Firestore.firestore()
    var users_username = String()  //userdata için
    var watchedList = [Watched]()
    var movieName = String()
    var selectedUserId: String?
    
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
        
        if let user = selectedUserId {
            userData(id: user)
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
        performSegue(withIdentifier: "toProfileEditing", sender: nil)
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
       // cell.movieImage.image = UIImage(named: "ImagePic")
        cell.movieIdLabel.text = w.movieId
       // print("movie id: \(w.movieId)")
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "profileToDetail", sender: indexPath.row)
    }
    
}
