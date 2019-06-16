//
//  HistoryTableViewController.swift
//  NewsApp
//
//  Created by Wei Liang Tan on 16/6/19.
//  Copyright © 2019 Wei Liang Tan. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {

    var historyArray: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retrieveReadArticle()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.historyArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell

        // Configure the cell...
        let article = self.historyArray[indexPath.row]
        
        cell.titleLbl.text = article["title"] as? String

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.deleteHistory(self.historyArray[indexPath.row])
            self.historyArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
 

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if  segue.identifier == "showReadArticleContent",
            let destination = segue.destination as? ContentViewController,
            let selectedIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.article = self.historyArray[selectedIndex]
        }
    }
 
    
    //retrieve history
    func retrieveReadArticle() {
        guard let apppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = apppDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReadArticle")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "lastReadDate", ascending: false)]
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            let converted = self.convertToReadArticleArray(moArray: result)
            if converted.count > 0 {
                self.historyArray = converted
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Failed to retrieve. \(error), \(error.userInfo)")
        }
    }
    
    func convertToReadArticleArray(moArray: [NSManagedObject]) -> [[String: Any]] {
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
    
    func deleteHistory(_ article:[String: Any]) {
        guard let apppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = apppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReadArticle")
        fetchRequest.predicate = NSPredicate(format: "url = %@", article["url"] as! CVarArg )
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            let objectToDelete = result[0]
            managedContext.delete(objectToDelete)
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch let error as NSError {
            print("Failed to delete data. \(error), \(error.userInfo)")
        }
        
    }
    

}
