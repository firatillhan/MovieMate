//
//  MovieAIRecommendation.swift
//  Movie Mate
//
//  Created by Fırat İlhan on 10.01.2025.
//

import UIKit

class MovieAIRecommendation: UIViewController {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activity.startAnimating()
        }
    }
    


    @IBAction func RecommendationButton(_ sender: Any) {
    }
    
    
}
