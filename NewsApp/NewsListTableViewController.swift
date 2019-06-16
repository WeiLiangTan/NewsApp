//
//  NewsListTableViewController.swift
//  NewsApp
//
//  Created by Wei Liang Tan on 15/6/19.
//  Copyright © 2019 Wei Liang Tan. All rights reserved.
//

import UIKit
import CoreData

class NewsListTableViewController: UITableViewController {
    
    @IBOutlet var loadingIndicatorFooter: UIView!
    
    var articleArray: [[String: Any]] = []
    var totalItems = 0
    var currentPage = 1
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshArticles), for: .valueChanged)
        
        self.tableView.tableFooterView = nil
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
        
        self.loadArticles(page: currentPage)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListCell", for: indexPath) as! NewsCell

        // Configure the cell...
        let article = self.articleArray[indexPath.row]
        
        cell.titleLabel?.text = article["title"] as? String
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.articleArray.count - 1 && self.articleArray.count < self.totalItems && !self.isLoading) {
            currentPage += 1
            self.loadArticles(page: currentPage)
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showArticleContent",
            let destination = segue.destination as? ContentViewController,
            let selectedIndex = tableView.indexPathForSelectedRow?.row
        {
            self.updateReadArticle(self.articleArray[selectedIndex])
            destination.article = self.articleArray[selectedIndex]
        }
    }
 
    
    // MARK: - Load Articles
    func loadArticles(page: NSInteger) {
//        https://newsapi.org/v2/top-headlines?country=sg&category=business&apiKey=104d7bd77d0b46f2802fef857710e84f&page=1
        let Url = "https://newsapi.org/v2/top-headlines?country=sg&category=business&apiKey=104d7bd77d0b46f2802fef857710e84f&page=\(page)"
        guard let serviceUrl = URL(string: Url) else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        self.isLoading = true
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            self.isLoading = false
            
            if let data = data {
                print("got data from  load news")
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    print("serialization of data from  load news")
                    print(json)
                    if let retrievedData = json as? [String: Any] {
                        let newItems = retrievedData["articles"] as! [[String : Any]]
                        self.totalItems = retrievedData["totalResults"] as! Int
                        
                        if page == 1 {
                            DispatchQueue.main.async {
                                self.saveArticles(newItems, reset: true)
                            }
                            self.articleArray = newItems
                        }
                        else {
                            DispatchQueue.main.async {
                                self.saveArticles(newItems, reset: false)
                            }
                            self.articleArray.append(contentsOf: newItems)
                        }
                    }
                } catch {
                    print("caught error while serializing data from  load news")
                    print(error)
                }
            }
            DispatchQueue.main.async {
                if (error != nil) {
                    self.retrieveArticle()
                }
                self.tableView.reloadData()
                if self.articleArray.count < self.totalItems {
                    self.tableView.tableFooterView = self.loadingIndicatorFooter
                } else {
                    self.tableView.tableFooterView = nil
                }
                self.refreshControl?.endRefreshing()
            }
        }.resume()
    }
    
    @objc func refreshArticles() {
        currentPage = 1;
        self.loadArticles(page: currentPage)
    }
    
    // Mark : Data
    
    func saveArticles(_ articles:[[String: Any]], reset:Bool) {
        guard let apppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = apppDelegate.persistentContainer.viewContext
        
        //remove all item
        
        if (reset) {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
            
            do {
                let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                for item in result {
                    managedContext.delete(item)
                }
            } catch let error as NSError {
                print("Failed to clear data before saving. \(error), \(error.userInfo)")
            }
        }
        
        //insert new item
        
        let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: managedContext)!
        
        for article in articles {
            let newArticle = NSManagedObject(entity: articleEntity, insertInto: managedContext)
            if let title = article["title"] as? String {
                newArticle.setValue(title, forKey: "title")
            }
            if let content = article["content"] as? String {
                newArticle.setValue(content, forKey: "content")
            }
            if let url = article["url"] as? String {
                newArticle.setValue(url, forKey: "url")
            }
            if let urlToImage = article["urlToImage"] as? String {
                newArticle.setValue(urlToImage, forKey: "urlToImage")
            }
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveArticle() {
        guard let apppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = apppDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            let converted = self.convertToDictionaryArray(moArray: result)
            if converted.count > 0 {
                self.articleArray = converted
            }
        } catch let error as NSError {
            print("Failed to retrieve. \(error), \(error.userInfo)")
        }
    }
    
    func convertToDictionaryArray(moArray: [NSManagedObject]) -> [[String: Any]] {
        var dictionaryArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
                
            }
            dictionaryArray.append(dict)
        }
        return dictionaryArray
    }

    //history
    func updateReadArticle(_ article: [String: Any]) {
        guard let apppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = apppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReadArticle")
        fetchRequest.predicate = NSPredicate(format: "url = %@", article["url"] as! CVarArg )
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if result.count != 0 {
                // update
                let managedObject = result[0]
                managedObject.setValue(Date(), forKey: "lastReadDate")
                
                try managedContext.save()
            } else {
                //insert new item
                
                let articleEntity = NSEntityDescription.entity(forEntityName: "ReadArticle", in: managedContext)!
                
                let newArticle = NSManagedObject(entity: articleEntity, insertInto: managedContext)
                if let title = article["title"] as? String {
                    newArticle.setValue(title, forKey: "title")
                }
                if let content = article["content"] as? String {
                    newArticle.setValue(content, forKey: "content")
                }
                if let url = article["url"] as? String {
                    newArticle.setValue(url, forKey: "url")
                }
                if let urlToImage = article["urlToImage"] as? String {
                    newArticle.setValue(urlToImage, forKey: "urlToImage")
                }
                newArticle.setValue(Date(), forKey: "lastReadDate")
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Failed to save. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Failed to clear data before saving. \(error), \(error.userInfo)")
        }
 
    }
}
