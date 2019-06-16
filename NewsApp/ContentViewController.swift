//
//  ContentViewController.swift
//  NewsApp
//
//  Created by Wei Liang Tan on 15/6/19.
//  Copyright © 2019 Wei Liang Tan. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    var article: [String: Any]?
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    @IBOutlet private weak var articleImg: UIImageView!
    @IBOutlet private weak var imgHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (article != nil) {
            self.titleLabel.text = article?["title"] as? String
            self.contentLabel.text = article?["content"] as? String
            
            DispatchQueue.global().async { [weak self] in
                if let imgUrlString = self?.article?["urlToImage"] as? String {
                    if let data = try? Data(contentsOf: URL(string: imgUrlString)!) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self?.articleImg.image = image
                                self?.imgHeightConstraint.constant=image.size.height/image.size.width*((self?.articleImg.frame.width)!)
                            }
                        }
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
