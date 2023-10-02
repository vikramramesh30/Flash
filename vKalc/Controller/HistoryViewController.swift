//
//  HistoryViewController.swift
//  vKalc
//
//  Created by cis on 25/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol tableViewSelectonDelegate {
    func didSelectedRow(que:String)
}

class HistoryViewController: BaseViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var arrTopics:[searchedTopic] = []
    var delegate:tableViewSelectonDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "History"
        // self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    func getData() {
        LoadingIndicator.sharedInstance.showActivityIndicator()
        let id = UserDefaults.standard.value(forKey: "USERID") as! String
        let ref = Database.database().reference(fromURL: "https://vkalc-bc29a.firebaseio.com")//"https://chatapp-6e864.firebaseio.com")//
        ref.child("searchedTopic").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? [String:Any]{
                for data in val {
                    self.arrTopics.append(searchedTopic(json: data.value as! [String : Any]))
                }
                self.arrTopics.sort {
                  //  print($0.realDate, $1.realDate)
                    return $0.realDate > $1.realDate
                }
                
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                self.tableView.reloadData()
            } else {
                LoadingIndicator.sharedInstance.hideActivityIndicator()
            }
            
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell_history", for: indexPath)
        let lblQuestion:UILabel = cell.contentView.viewWithTag(100) as! UILabel
        let lblDate:UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let topic = arrTopics[indexPath.row]
        lblQuestion.text = topic.question
        lblDate.text = topic.date
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = arrTopics[indexPath.row]
        self.delegate.didSelectedRow(que: topic.question)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
