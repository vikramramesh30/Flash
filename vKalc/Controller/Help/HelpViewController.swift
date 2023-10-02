//
//  HelpViewController.swift
//  vKalc
//
//  Created by Cis on 05/08/20.
//  Copyright © 2020 cis. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore

class HelpViewController: BaseViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var arrayHelpList: [Faq] = []
    var arrayFilterHelpList: [Faq] = []
    var faqListener: ListenerRegistration?
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.getData()
        
        //        let settings = FirestoreSettings()
        //        settings.isPersistenceEnabled = false
        //        db.settings = settings
        
        //Connect to database
        db = Firestore.firestore()
        startListeningForFAQ()
    }
    
    private func startListeningForFAQ() {
        LoadingIndicator.sharedInstance.showActivityIndicator()
        
        faqListener = db.collection("faq").addSnapshotListener({ (snapshot, error) in
            if let error = error {
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                return
            }
            self.arrayHelpList.removeAll()
            for faqDocuments in snapshot.documents {
                self.arrayHelpList.append(Faq(json: faqDocuments.data()))
            }
            
            LoadingIndicator.sharedInstance.hideActivityIndicator()
            self.arrayHelpList.sort(by: { $0.id < $1.id })
            self.arrayFilterHelpList = self.arrayHelpList
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    private func stopListeningForFAQ() {
        faqListener?.remove()
        faqListener = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Help"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopListeningForFAQ()
    }
    
    func getData() {
        
        //        let id = UserDefaults.standard.value(forKey: "USERID") as! String
        //        let ref = Database.database().reference(fromURL: "https://vkalc-bc29a.firebaseio.com")//"https://chatapp-6e864.firebaseio.com")//
        //        ref.child("searchedTopic").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
        //            if let val = snapshot.value as? [String:Any]{
        //                for data in val {
        //                    self.arrayHelpList.append(searchedTopic(json: data.value as! [String : Any]))
        //                }
        //                self.arrayHelpList.sort {
        //                    print($0.realDate, $1.realDate)
        //                    return $0.realDate > $1.realDate
        //                }
        //
        //                LoadingIndicator.sharedInstance.hideActivityIndicator()
        //                self.arrayFilterHelpList = self.arrayHelpList
        //                self.tableView.reloadData()
        //            } else {
        //                LoadingIndicator.sharedInstance.hideActivityIndicator()
        //            }
        //
        //        }, withCancel: nil)
    }
}

extension HelpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayHelpList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell_Help", for: indexPath)
        let lblQuestion:UILabel = cell.contentView.viewWithTag(100) as! UILabel
        let topic = arrayHelpList[indexPath.row]
        lblQuestion.text = "\(indexPath.row + 1). \(topic.question.replacingOccurrences(of: "\\n", with: "\n"))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HelpDetailViewController") as! HelpDetailViewController
        let topic = arrayHelpList[indexPath.row]
        vc.data = topic
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension HelpViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        arrayHelpList = searchText.isEmpty ? arrayFilterHelpList : arrayFilterHelpList.filter{$0.question.range(of: searchText, options: .caseInsensitive) != nil}
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
}
