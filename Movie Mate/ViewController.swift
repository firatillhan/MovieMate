//
//  ViewController.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 30.11.2024.
//

import UIKit

class MovieList: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

//    func fetchMovies() {
//        let db = Firestore.firestore()
//        db.collection("movies").getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching documents: \(error)")
//            } else {
//                self.movies = snapshot?.documents.compactMap { document -> Movie? in
//                    let data = document.data()
//                    guard let title = data["title"] as? String,
//                          let posterUrl = data["posterUrl"] as? String else { return nil }
//                    return Movie(title: title, posterUrl: posterUrl)
//                } ?? []
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            }
//        }
//    }
