//
//  ViewController.swift
//  AppveloxTestApp
//
//  Created by Vladislav Barinov on 10.06.2020.
//  Copyright © 2020 Vladislav Barinov. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class ViewController: UIViewController {
    var newsArray = Array<News>()
    var newsForSegue: News?
    
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.hidesWhenStopped = true
        ai.startAnimating()
        ai.color = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        ai.translatesAutoresizingMaskIntoConstraints = false
        
        return ai
    }()
    
    let refreshControll = UIRefreshControl()
    
    let dateFormatter = DateFormatter()
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        getData {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        
        
        refreshControll.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        tableView.refreshControl = refreshControll
        
        
        
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        self.activityIndicator.startAnimating()
        self.newsArray.removeAll()
        self.tableView.reloadData()
        self.getData {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailVC" {
            let newsSecondVC = segue.destination as! DetailTableViewController
            if let news = newsForSegue {
                newsSecondVC.news = news
            }
        }
    }
    
    func getData(_ complition: @escaping () -> ()) {
        
        guard let url = URL(string: "https://www.vesti.ru/vesti.rss") else {
            return
        }
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        AF.request(url, method: .get, encoding: URLEncoding.default, headers: headers).responseString { (response) in
            switch response.result {
            case .success(let data):
                let xml =  SWXMLHash.parse(data)
                //               print(xml["rss"]["channel"]["item"])
                for item in xml["rss"]["channel"]["item"].all {
                    //    print(item["title"].element!.text)
                    let title = item["title"].element!.text
                    let pubDate = item["pubDate"].element!.text
                    let yandexFullText = item["yandex:full-text"].element!.text
                    let enclosureUrl = item["enclosure"][1].element?.attribute(by: "url")?.text
                    let news = News(title: title,
                                    link: nil,
                                    amplink: nil,
                                    description: nil,
                                    pubDate: self.convertDateFromTimestamp(pubDate),
                                    category: nil,
                                    enclosureUrl: enclosureUrl,
                                    yandexFullText: yandexFullText)
                    
                    self.newsArray.append(news)
                    
                    
                }
                
                complition()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
    }
    func convertDateFromTimestamp(_ timestamp: String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        if let date = dateFormatter.date(from: timestamp) {
            
            dateFormatter.dateFormat = "dd MMMM yyyy 'в' H:m"
            
            let dateString = dateFormatter.string(from: date)
            
            return dateString
            
        }
        
        return nil
    }
    
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsCell
        let news = newsArray[indexPath.row]
        cell.titleNews.text = news.title
        cell.dateNews.text = news.pubDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNews = newsArray[indexPath.row]
        newsForSegue = selectedNews
        
        performSegue(withIdentifier: "DetailVC", sender: self)
    }
    
}
