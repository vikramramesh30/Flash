//
//  HowToViewController.swift
//  vKalc
//
//  Created by Cis on 05/08/20.
//  Copyright © 2020 cis. All rights reserved.
//

import UIKit
import DropDown
import SDWebImage
import FirebaseFirestore

class HowToCell: UITableViewCell {
    
    @IBOutlet weak var labelVideoName: UILabel!
    @IBOutlet weak var imageViewVideo: UIImageView!
    @IBOutlet weak var buttonVideoPlay: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure<T>(_ content: T) {
        guard let data = content as? HowToList else { return }
        self.labelVideoName.text = data.video_name
        // self.labelDescription.text = data.description.replacingOccurrences(of: "\\n", with: "\n")
        
        if data.youtube_id != "" {
            imageViewVideo.sd_setImage(with: URL(string: "https://img.youtube.com/vi/\(data.youtube_id)/maxresdefault.jpg"), completed: nil)
        }else{
            imageViewVideo.image = nil
        }
    }
}

class HowToViewController: BaseViewController {
    
    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var buttonSelectCategory: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var dropDownMenu =  DropDown()
    var arrMenu : [CategoryList] = []
    var arrayTopicsList: [HowToList] = []
    var arrayFilterTopicsList: [HowToList] = []
    
    var howToListener: ListenerRegistration?
    var howToVideoListener: ListenerRegistration?
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "How to"
        
        //Connect to database
        db = Firestore.firestore()
        self.startListeningForHowTo()
        
        arrayFilterTopicsList = arrayTopicsList
        tableView.tableFooterView = UIView()
        
        buttonSelectCategory.layer.borderWidth = 0.8
        buttonSelectCategory.layer.borderColor = UIColor.darkGray.cgColor
        buttonSelectCategory.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    }
    
    private func startListeningForHowTo() {
        LoadingIndicator.sharedInstance.showActivityIndicator()
        
        howToListener = db.collection("how_to").addSnapshotListener({ (snapshot, error) in
            LoadingIndicator.sharedInstance.hideActivityIndicator()
            
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            self.arrMenu.removeAll()
            for howToDocuments in snapshot.documents {
                self.arrMenu.append(CategoryList(json: howToDocuments.data(), documentId: howToDocuments.documentID))
            }
            self.menuDropDown()
            self.arrMenu.swapAt(0, 3)
            if !self.arrMenu.isEmpty {
                for (index, item) in self.arrMenu.enumerated() {
                    if item.categoryId == 3 {
                        self.labelCategoryName.text = self.arrMenu[index].categoryName
                        self.startListeningForSelectedCategoryVideosList(documentId: self.arrMenu[index].documentId)
                        break
                    }
                }
            }
        })
    }
    
    private func stopListeningForHowTo() {
        howToListener?.remove()
        howToListener = nil
        howToVideoListener?.remove()
        howToVideoListener = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.menuDropDown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopListeningForHowTo()
        //        self.searchBar.text = ""
        //        self.searchBar.resignFirstResponder()
    }
    
    //MARK: - Button Action
    
    @objc func buttonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchCategoryViewController") as! SearchCategoryViewController
        vc.delegate = self
        vc.arrayCategoryList = self.arrMenu
        self.navigationController?.pushViewController(vc, animated: true)
        //self.dropDownMenu.show()
    }
    
    @objc func buttonVideoPlay(_ sender: UIButton) {
        self.playVideo(index: sender.tag)
    }
    
    //MARK: - Move to Player screen
    private func playVideo(index: Int) {
        let data = arrayTopicsList[index]
        if data.youtube_id != "" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "YoutubePlayerViewController") as! YoutubePlayerViewController
            vc.videoId = data.youtube_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK:- Define Menu
    func menuDropDown(){
        self.dropDownMenu.dataSource = arrMenu.map{($0.categoryName)}
        self.dropDownMenu.anchorView = self.labelCategoryName
        self.dropDownMenu.direction = .bottom
        self.dropDownMenu.width = self.labelCategoryName.frame.width
        self.dropDownMenu.backgroundColor = UIColor.white
        self.dropDownMenu.selectionAction = { [weak self](index: Int, item: String) in
            guard let self = self else { return }
          //  self.searchBar.text = ""
          //  self.searchBar.resignFirstResponder()
            self.labelCategoryName.text = item
            self.startListeningForSelectedCategoryVideosList(documentId: self.arrMenu[index].documentId)
        }
    }
    
    private func startListeningForSelectedCategoryVideosList(documentId: String) {
        LoadingIndicator.sharedInstance.showActivityIndicator()
        howToVideoListener = db.collection("youtube_video").whereField("categoryId_String", isEqualTo: "\(documentId)").addSnapshotListener({ (snapshot, error) in
            
            LoadingIndicator.sharedInstance.hideActivityIndicator()
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                return
            }
            self.arrayTopicsList.removeAll()
            self.arrayFilterTopicsList.removeAll()
            for howToDocuments in snapshot.documents {
                self.arrayTopicsList.append(HowToList(json: howToDocuments.data()))
            }
            self.arrayFilterTopicsList = self.arrayTopicsList
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    deinit {
        print("\(self) deallocated successfully!!!!")
    }
}

extension HowToViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayTopicsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HowToCell", for: indexPath) as! HowToCell
        cell.configure(arrayTopicsList[indexPath.row])
        cell.buttonVideoPlay.tag = indexPath.row
        cell.buttonVideoPlay.addTarget(self, action: #selector(buttonVideoPlay(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   didEndDisplaying cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        // access the playing video of the cell and stop it
        
        //        if let videoCell = cell as? HowToCell, videoCell.videoURL != nil {
        //            ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
        //        }
        
        // guard let videoCell = cell as? HowToCell else { return }
        //videoCell.webViewVideo.stopLoading()
        //videoCell.playerView.stopVideo()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.playVideo(index: indexPath.row)
        /*
         if let cell = tableView.cellForRow(at: indexPath) as? HowToCell {
         let item = arrayTopicsList[indexPath.row]
         let playerVars = ["playsinline": 0] // 0: will play video in fullscreen
         if item.videoLink != nil && item.videoLink != "" {
         cell.playerView.load(withVideoId: item.videoLink ?? "", playerVars: playerVars)
         cell.playerView.playVideo()
         }
         } */
    }
}

extension HowToViewController: SearchCategoryDelegate {
    
    func didSelectCategory(_ data: CategoryList) {
        self.labelCategoryName.text = data.categoryName
        self.startListeningForSelectedCategoryVideosList(documentId: data.documentId)
    }
}

/*
extension HowToViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        arrayTopicsList = searchText.isEmpty ? arrayFilterTopicsList : arrayFilterTopicsList.filter{$0.video_name.range(of: searchText, options: .caseInsensitive) != nil || $0.created_date.range(of: searchText, options: .caseInsensitive) != nil}
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
*/

struct HowToList {
    var categoryId_String: String = ""
    var category_referenceIdPath: String = ""
    var created_date: String = ""
    var description: String = ""
    var video_name: String = ""
    var youtube_id: String = ""
    
    init(json:[String:Any]) {
        self.categoryId_String        = json["categoryId_String"] as? String ?? ""
        self.category_referenceIdPath = json["category_referenceIdPath"] as? String ?? ""
        self.created_date             = json["created_date"] as? String ?? ""
        self.description              = json["description"] as? String ?? ""
        self.video_name               = json["video_name"] as? String ?? ""
        self.youtube_id               = json["youtube_id"] as? String ?? ""
    }
}

struct CategoryList {
    var categoryId:Int          =   0
    var categoryName:String     =   ""
    var documentId: String = ""
    
    init(json:[String:Any], documentId: String) {
        self.categoryId         = json["category_id"] as? Int ?? 0
        self.categoryName       = json["category_name"] as? String ?? ""
        self.documentId = documentId
    }
}
