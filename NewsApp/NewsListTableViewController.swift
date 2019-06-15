//
//  NewsListTableViewController.swift
//  NewsApp
//
//  Created by Wei Liang Tan on 15/6/19.
//  Copyright © 2019 Wei Liang Tan. All rights reserved.
//

import UIKit

class NewsListTableViewController: UITableViewController {
    
    var articleArray: [[String: Any]] = []
    var totalItems = 0
    var currentPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
        
        self.loadArticles(page: currentPage)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListCell", for: indexPath) as! NewsCell

        // Configure the cell...
        let article = self.articleArray[indexPath.row]
        
        cell.titleLabel?.text = article["title"] as? String
        cell.detailLabel?.text = article["description"] as? String
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Load Articles
    func loadArticles(page: NSInteger) {
//        https://newsapi.org/v2/top-headlines?country=sg&category=business&apiKey=104d7bd77d0b46f2802fef857710e84f&page=1
        let Url = String(format: "https://newsapi.org/v2/top-headlines?country=sg&category=business&apiKey=104d7bd77d0b46f2802fef857710e84f&page=%@",page)
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print("got response from  load news")
                print(response)
            }
            if let data = data {
                print("got data from  load news")
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    print("serialization of data from  load news")
                    print(json)
                    if let retrievedData = json as? [String: Any] {
                        self.articleArray = retrievedData["articles"] as! [[String : Any]]
                        self.totalItems = retrievedData["totalResults"] as! Int
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("caught error while serializing data from  load news")
                    print(error)
                }
            }
        }.resume()
    }

}
