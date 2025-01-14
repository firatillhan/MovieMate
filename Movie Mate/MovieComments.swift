//
//  MovieComments.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.12.2024.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SDWebImage

class MovieComments: UIViewController {
   
    var commentList = [Comments]()
    var movieId:String?
    var userId:String?
    var SelectedmovieName:String?
    var commentId = String()
    var emptyMessageLabel: UILabel!
    var database = Firestore.firestore()

    var formattedDate: String = ""
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("movie favorite vc view will appear çalıştı")
        commentsMovieFetch()
        commentNumberFetch()
        emptyLabel()
        navigationItem.title = "\(SelectedmovieName!)"

    }
    func emptyLabel(){
        emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        emptyMessageLabel.text = "No Comment"
        emptyMessageLabel.textColor = .gray
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = UIFont.systemFont(ofSize: 20)
        tableView.backgroundView = emptyMessageLabel
    }
    func commentNumberFetch() {
      
        //favori sayısı 0 ise ekrana henüz yemek tarifi beğenmediniz yazısı gelecek.
        
        let query = database.collection("comments").whereField("movieId", isEqualTo: movieId!)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    let sayi = querySnapshot.documents.count
                    if  sayi == 0 {
                        self.emptyMessageLabel.isHidden = false
                        print("liste boş: \(sayi)")
                        
                    } else {
                        self.emptyMessageLabel.isHidden = true
                        print("liste boş değil")
                    }
                }
            }
        }
        
    }
    
    func commentsMovieFetch(){
        
        database.collection("comments").whereField("movieId", isEqualTo: movieId!).addSnapshotListener { (snapshot,error) in
            if error != nil {
                self.makeAlert(titleInput: "Hata", messageInput: error?.localizedDescription ?? "Hata", button: "TAMAM")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    let group = DispatchGroup()
                    self.commentList.removeAll(keepingCapacity: false)

                    for document in snapshot!.documents {
                        let data = document.data()
                        
                        let commentId = document.documentID
                        print("comment id: \(commentId)")
                        let commentText = data["commentText"] as? String ?? ""                       
                        
                        if let commentDate = data["commentDate"] as? Timestamp {
                            // Timestamp'i Date'e dönüştür
                            let date = commentDate.dateValue()
                            // Date'i istediğin formatta yazdır
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            dateFormatter.timeStyle = .none
                            self.formattedDate = dateFormatter.string(from: date)
                            print("Tarih: \(self.formattedDate)")
                        }

                        let movieId = self.movieId
                        let userId = data["userId"] as? String ?? ""
            
                        group.enter()
                        self.database.collection("users").document(userId).getDocument { document, error in
                            if let error = error {
                                print("Error \(error)")
                            } else {
                                let username = document?.data()?["username"] as? String ?? "No Name"
                                let userPhoto = document?.data()?["userPhoto"] as? String ?? "No Name"

                                
                                let comment = Comments(commentId: commentId, commentText: commentText, userId: userId, commentDate: self.formattedDate, movieId: movieId!, userName: username, userPhoto: userPhoto)
                                //print("Movie Name:\(movieName)")
                                self.commentList.append(comment)
                            }
                            group.leave()
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    } //  fonksiyon bitiş
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otherUserProfile",
           let destinationVC = segue.destination as? MovieProfile,
           let selectedUserId = sender as? String {
            destinationVC.selectedUserId = selectedUserId
        }
    }

    

  
}

extension MovieComments: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = commentList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! MovieCommentsTableViewCell
        
        cell.userImage.sd_setImage(with: URL(string: comment.userPhoto))
        cell.commentDate.text = comment.commentDate
        cell.username.text = comment.userName
        cell.commentText.text = comment.commentText
        cell.userId.text = comment.userId
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = commentList[indexPath.row]
        print("yorum yapan kullanıcının id si: \(comment.userId)")
        self.performSegue(withIdentifier: "otherUserProfile", sender: comment.userId)
    }
    
    
}
