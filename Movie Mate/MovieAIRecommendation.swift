//
//  MovieAIRecommendation.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 10.01.2025.
//
//son versiyon
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MovieAIRecommendation: UIViewController {
    
    var IPadres = "172.20.10.3"


    @IBOutlet weak var tableView: UITableView!
    let currentUser = Auth.auth().currentUser!
    let database = Firestore.firestore()

    var onerilenFilmlerListesi = [Oneriler]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        userWatchedMovies(id: currentUser.uid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indeks = sender as? Int
        let destinationVC = segue.destination as! MovieDetails
        destinationVC.oneri = onerilenFilmlerListesi[indeks!]
    }
}
extension MovieAIRecommendation:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return onerilenFilmlerListesi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oneri = onerilenFilmlerListesi[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneriCell", for: indexPath) as! MovieAIRecommendationTableViewCell
        cell.movieNameLabel.text = oneri.oneriFilmName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "aiToDetail", sender: indexPath.row)
    }
    
    // izlenen filmleri çekmek -fonksiyon başlangıç
    func userWatchedMovies(id: String) {
        var movieNames: [String] = []
        let group = DispatchGroup()
        
        database.collection("movieWatched").whereField("userId", isEqualTo: id).getDocuments { (snapshot, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    let data = document.data()
                    let watched_movieId = data["movieId"] as? String ?? ""
                    
                    group.enter()
                    self.database.collection("filmListesi").document(watched_movieId).getDocument { document, error in
                        if let error = error {
                            print("ERROR: \(error.localizedDescription)")
                        } else if let movieData = document?.data() {
                            let movieName = movieData["movieName"] as? String ?? "No Movie Name"
                            movieNames.append(movieName)
                            print("İzlenen filmler: \(movieName)")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    if movieNames.isEmpty {
                        // Eğer izlenen film yoksa, öneri listesini temizle ve tableView'i boş göster
                        self.onerilenFilmlerListesi = []
                        self.tableView.reloadData()
                        self.updateEmptyState()
                        print("Kullanıcının izlediği film yok, öneri yapılmadı.")
                    } else {
                        self.sendWatchedMoviesToServer(watchedMovies: movieNames,IPadres: self.IPadres)
                    }
                }

            }
        }
    }
    // izlenen filmleri çekmek -fonksiyon bitiş
    
    
    func updateEmptyState() {
        if onerilenFilmlerListesi.isEmpty {
            let label = UILabel()
            label.text = "Henüz öneri yok"
            label.textAlignment = .center
            label.textColor = .gray
            label.font = UIFont.systemFont(ofSize: 16)
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }

    func sendWatchedMoviesToServer(watchedMovies: [String],IPadres:String) {
        print("to server fonksiyonu çalıştı. urlKey:\(IPadres)")
        guard let url = URL(string: "http://\(IPadres):5001/recommend") else {
            print("Geçersiz URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody: [String: Any] = ["watched_movies": watchedMovies]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            print("JSON oluşturulamadı: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.makeAlert(titleInput: "Bağlantı Hatası", messageInput: "Sunucuya bağlanılamadı. \nHata:\(error.localizedDescription)", button: "Tamam")
                }
                return
            }
            
            guard let data = data else {
                print("Yanıt verisi yok")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let recommended = json["recommended_movies"] as? [String] {
                    DispatchQueue.main.async {
                        self.onerilenFilmlerListesi = recommended.map { Oneriler(oneriFilmName: $0) }
                        self.tableView.reloadData() // TableView’ı yenile
                    }
                }
            } catch {
                print("Yanıt işlenemedi: \(error)")
            }
        }
        
        task.resume()
    }


    
}
