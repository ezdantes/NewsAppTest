//
//  DetailTableViewController.swift
//  AppveloxTestApp
//
//  Created by Vladislav Barinov on 10.06.2020.
//  Copyright © 2020 Vladislav Barinov. All rights reserved.
//

import UIKit
import SDWebImage

class DetailTableViewController: UITableViewController {

        @IBOutlet weak var imageNews: UIImageView!
        
        @IBOutlet weak var fullText: UILabel!
        @IBOutlet weak var titleNews: UILabel!
        
        var news: News?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            titleNews.text = news?.title
            fullText.text = news?.yandexFullText
    
            guard let url = URL(string: news?.enclosureUrl ?? "") else { return }
            imageNews.sd_setImage(with: url, placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
        

      
    }
