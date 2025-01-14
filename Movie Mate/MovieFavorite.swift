//
//  MovieFavorite.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.11.2024.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MovieFavorite: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let currentUser = Auth.auth().currentUser!
    var likeList = [Favories]()
    var likeId = String()
    var emptyMessageLabel: UILabel!
    let database = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        print("movie favorite vc view will appear çalıştı")
        likeMovieFetch(userId: currentUser.uid)
        favoriNumberFetch()
        navigationItem.title = "My Favorite Movie List"

    }
    
    
    func likeMovieFetch(userId:String){
        
        database.collection("movieLikes").whereField("userId", isEqualTo: userId).addSnapshotListener { (snapshot,error) in
            if error != nil {
                self.makeAlert(titleInput: "Hata", messageInput: error?.localizedDescription ?? "Hata", button: "TAMAM")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    let group = DispatchGroup()
                    self.likeList.removeAll(keepingCapacity: false)

                    for document in snapshot!.documents {
                        let data = document.data()
                        
                        let likeId = document.documentID
                        let movieId = data["movieId"] as? String ?? ""
                        let userId = data["userId"] as? String ?? ""
                        
                        group.enter()
                        self.database.collection("filmListesi").document(movieId).getDocument { document, error in
                            if let error = error {
                                print("Error \(error)")
                            } else {
                                let movieName = document?.data()?["movieName"] as? String ?? "No Movie Name"
                                let like = Favories(likeId: likeId, userId: userId, movieId: movieId, movieName: movieName)
                                print("Movie Name:\(movieName)")
                                self.likeList.append(like)
                            }
                            group.leave()
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    } // likeMovieFetch fonksiyon bitiş
    
    func favoriNumberFetch() {
      
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        emptyMessageLabel.text = "No Like Movie"
        emptyMessageLabel.textColor = .gray
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = UIFont.systemFont(ofSize: 20)
        tableView.backgroundView = emptyMessageLabel
       
        
        let query = database.collection("movieLikes").whereField("userId", isEqualTo: currentUser.uid)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    let sayi = querySnapshot.documents.count
                    if  sayi == 0 {
                        self.emptyMessageLabel.isHidden = false
                        print("liste boş: \(sayi)")
                        self.tableView.isHidden = true
                        
                    } else {
                        self.emptyMessageLabel.isHidden = true
                        print("liste boş değil")
                        self.tableView.isHidden = false
                    }
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indeks = sender as? Int
        let destinationVC = segue.destination as! MovieDetails
        destinationVC.favori = likeList[indeks!]
    }
    

    
    func Alert(titleInput:String,messageInput:String,button:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: button, style: .default) { UIAlertAction in
            self.alertTamam()
        }
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func alertTamam(){
        self.likeMovieFetch(userId: currentUser.uid)
    }
    

}
 
extension MovieFavorite: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let like = likeList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriCell", for: indexPath) as! MovieFavoriteTableViewCell
        cell.movieNameLabel.text = like.movieName
        cell.movieIdLabel.text = like.movieId
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "favoriToDetail", sender: indexPath.row)
    }
    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
//            (contextualAction, view, boolValue) in
//            
//            let like = self.likeList[indexPath.row]
//            
//            print("trailing: \(like.likeId)")
//            self.likeDelete(likeId: like.likeId)
//        }
//        
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//        
//        
//    }
    
    
}
