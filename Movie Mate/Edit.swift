//
//  Edit.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 8.01.2025.
//  //Kullanıcının izlediği filmleri, yaptığı yorumları, beğendiği filmleri listeleme ve silme sayfası

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class Edit: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let database = Firestore.firestore()

    var favoriList = [EditList]()
    var commentList = [EditList]()
    var watchedList = [EditList]()
    var activeList = [EditList]()

    let currentUser = Auth.auth().currentUser!


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        activeList = favoriList

        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        //activeList = favoriList
        likeFetch()
        commentsFetch()
        watchedFetch()
    }
    

    
    
     func likeFetch(){
         
         database.collection("movieLikes").whereField("userId", isEqualTo: currentUser.uid).addSnapshotListener { (snapshot,error) in
             if error != nil {
                 self.makeAlert(titleInput: "Hata", messageInput: error?.localizedDescription ?? "Hata", button: "TAMAM")
             } else {
                 if snapshot?.isEmpty != true && snapshot != nil {
                     let group = DispatchGroup()
                     self.favoriList.removeAll(keepingCapacity: false)

                     for document in snapshot!.documents {
                         let data = document.data()
                         
                         let likeId = document.documentID
                         let movieId = data["movieId"] as? String ?? ""
                         
                         group.enter()
                         self.database.collection("filmListesi").document(movieId).getDocument { document, error in
                             if let error = error {
                                 print("Error \(error)")
                             } else {
                                 let movieName = document?.data()?["movieName"] as? String ?? "No Movie Name"
                                 let like = EditList(name: movieName, id: likeId)
                                 print("Movie Name:\(movieName)")
                                 self.favoriList.append(like)
                                 
                                 // Aktif liste commentList ise tableView'ı güncelle
                                 if self.segmentControl.selectedSegmentIndex == 0 {
                                     self.activeList = self.favoriList
                                     self.tableView.reloadData()
                                 }
                             }
                             group.leave()
                             self.tableView.reloadData()
                         }
                     }
                     self.tableView.reloadData()
                 }
             }
         }
     } // like Fetch func end
    
    
    func commentsFetch(){
        
        database.collection("comments").whereField("userId", isEqualTo: currentUser.uid).addSnapshotListener { (snapshot,error) in
            if error != nil {
                self.makeAlert(titleInput: "Hata", messageInput: error?.localizedDescription ?? "Hata", button: "TAMAM")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    self.commentList.removeAll(keepingCapacity: false)

                    for document in snapshot!.documents {
                        let data = document.data()
                        
                        let commentId = document.documentID
                        //let movieId = data["movieId"] as? String ?? ""
                        let commentText = data["commentText"] as? String ?? ""
                        
                        let comment = EditList(name: commentText, id: commentId)
                        print("Comment Text:\(commentText)")
                        self.commentList.append(comment)
                      
                    }
                    self.tableView.reloadData()
                }
            }
        }
    } // comment fetch func end
    
    func watchedFetch(){
        
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
                        let movieId = data["movieId"] as? String ?? ""
                        
                        group.enter()
                        self.database.collection("filmListesi").document(movieId).getDocument { document, error in
                            if let error = error {
                                print("Error \(error)")
                            } else {
                                let movieName = document?.data()?["movieName"] as? String ?? "No Movie Name"
                                let watch = EditList(name: movieName, id: watchedId)
                                print("Movie Name:\(movieName)")
                                self.watchedList.append(watch)
                            }
                            group.leave()
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    } // watched fetch func end

    @IBAction func segmentControlButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            activeList = favoriList
        case 1:
            activeList = watchedList
        case 2:
            activeList = commentList
        default:
            break
        }
        tableView.reloadData() // Tabloyu güncelle
    }
    
    func deleteFromFirebase(item: EditList) {
        let collectionName: String
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            collectionName = "movieLikes"
        case 1:
            collectionName = "movieWatched"
        case 2:
            collectionName = "comments"
        default:
            return
        }
        
        database.collection(collectionName).document(item.id).delete { error in
            if let error = error {
                print("Silme işlemi başarısız: \(error.localizedDescription)")
            } else {
                print("Veri başarıyla silindi: \(item.name)")
            }
        }
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
        self.viewWillAppear(true)
    }
}

extension Edit: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let active = activeList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! EditTableViewCell
        cell.EditLabel.text = active.name
        cell.editLabelId.text = active.id
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 1. Silme işlemi için bir action oluştur
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            // 2. Silinecek öğeyi belirle
            let deletedItem = self.activeList[indexPath.row]
            
            // 3. Firebase'den sil (isteğe bağlı)
            self.deleteFromFirebase(item: deletedItem)
            
            // 4. Aktif listeden ve tableView'dan kaldır
            self.activeList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            self.tableView.reloadData()
            completionHandler(true)
        }
        
        // Aksiyonun görünümünü özelleştirme (isteğe bağlı)
        deleteAction.backgroundColor = .red
        
        // 6. Aksiyonları bir UISwipeActionsConfiguration içine ekle
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    
}
