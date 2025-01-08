//+
//  MovieFeed.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.11.2024.
//

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage

class MovieFeed: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var movieList = [Movies]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieCVDesign()
        collectionView.delegate = self
        collectionView.dataSource = self
        movieFetch()
    }
    override func viewWillAppear(_ animated: Bool) {
        movieFetch()
        
    }
    @IBAction func movieAddButton(_ sender: Any) {
        performSegue(withIdentifier: "movieAdd", sender: nil)
    }
    
    func movieCVDesign() {
        let tasarim :UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let genislik = self.collectionView.frame.size.width
        
        tasarim.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        print("Genişlik: \(genislik)")
        let hucreGenislik = (genislik-10)/2
        tasarim.itemSize = CGSize(width: hucreGenislik, height: hucreGenislik*1.7)
        tasarim.minimumInteritemSpacing = 5
        tasarim.minimumLineSpacing = 5
        collectionView.collectionViewLayout = tasarim
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToDetail" {
            // İlk sayfa için hazırlık
            if let indeks = sender as? Int {
                let gidilecekVC = segue.destination as! MovieDetails
                gidilecekVC.movie = movieList[indeks]
            }
        } 
    }


    
    
    func movieFetch(){
        let db = Firestore.firestore()
        db.collection("filmListesi").order(by: "movieRating", descending: true).addSnapshotListener { (snapshot, error) in
           
            if let error = error {
                self.makeAlert(titleInput: "Hata", messageInput: error.localizedDescription, button: "TAMAM")
                print("Error: \(error)")
            }
            else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    self.movieList.removeAll(keepingCapacity: false)
                    for documentOne in snapshot!.documents {
                                                                                                                                        
                        let data = documentOne.data()
                        let movieId = documentOne.documentID
                        let movieName = data["movieName"] as? String ?? "No Movie Name"
                        let movieYear = data["movieYear"] as? String ?? ""
                        let movieImage = data["movieImage"] as? String ?? ""
                        let movieRunTime = data["movieRunTime"] as? String ?? ""
                        let movieDirector = data["movieDirector"] as? String ?? ""
                        let movieStars = data["movieStars"] as? String ?? ""
                        let movieGenre = data["movieGenre"] as? String ?? ""
                        let movieDescription = data["movieDescription"] as? String ?? ""
                        let movieRating = data["movieRating"] as? String ?? ""
                        
                        let movie = Movies(movieId: movieId, movieName: movieName, movieYear: movieYear, movieImage: movieImage, movieRunTime: movieRunTime, movieDirector: movieDirector, movieStars: movieStars, movieGenre: movieGenre, movieDescription: movieDescription, movieRating: movieRating)
                        
                        self.movieList.append(movie)
                    }
                    self.collectionView.reloadData()
                }
            }
            
        }
    } //fonksiyon bitiş
    }




extension MovieFeed: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = movieList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieFeedCollectionViewCollectionViewCell
      
        cell.movieImage.sd_setImage(with: URL(string: movie.movieImage))
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "feedToDetail", sender: indexPath.row)
        print("hücreye tıklandı")
    }
    
}
