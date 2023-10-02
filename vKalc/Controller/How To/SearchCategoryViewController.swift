//
//  SearchCategoryViewController.swift
//  vKalc
//
//  Created by Cis on 01/09/20.
//  Copyright © 2020 cis. All rights reserved.
//

import UIKit

protocol SearchCategoryDelegate: class {
    func didSelectCategory(_ data: CategoryList)
}

class SearchCategoryCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure<T>(_ content: T) {
        guard let data = content as? CategoryList else { return }
        self.labelTitle.text = data.categoryName
    }
}

class SearchCategoryViewController: BaseViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: SearchCategoryDelegate?
    var arrayCategoryList: [CategoryList] = []
    var arrayFilterCategoryList: [CategoryList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Category"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arrayFilterCategoryList = self.arrayCategoryList
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
}

extension SearchCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayCategoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCategoryCell", for: indexPath) as! SearchCategoryCell
        cell.configure(arrayCategoryList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.didSelectCategory(arrayCategoryList[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchCategoryViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        arrayCategoryList = searchText.isEmpty ? arrayFilterCategoryList : arrayFilterCategoryList.filter{$0.categoryName.range(of: searchText, options: .caseInsensitive) != nil}
        self.tableView.reloadData()
        
       // let arrayCategoryList = searchText.isEmpty ? arrayFilterCategoryList : arrayFilterCategoryList.filter{$0.categoryName.range(of: searchText, options: .caseInsensitive) != nil}
       // self.tableView.reloadData()
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
