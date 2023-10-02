//
//  HelpDetailViewController.swift
//  vKalc
//
//  Created by Cis on 05/08/20.
//  Copyright © 2020 cis. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HelpDetailCell: UITableViewCell {
    
    @IBOutlet weak var labelQuestionAnswer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class HelpDetailViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var arrTopics:[searchedTopic] = []
    var data: Faq? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Answer"
    }
}

extension HelpDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpDetailCell", for: indexPath) as! HelpDetailCell
        if indexPath.row == 0 {
            cell.contentView.backgroundColor = .groupTableViewBackground
            cell.labelQuestionAnswer.textColor = .lightGray
            cell.labelQuestionAnswer.font = UIFont.systemFont(ofSize: 18.0)
            cell.labelQuestionAnswer.text = data?.question.replacingOccurrences(of: "\\n", with: "\n")
        }else{
            cell.contentView.backgroundColor = .white
            cell.labelQuestionAnswer.textColor = .black
            cell.labelQuestionAnswer.font = UIFont.systemFont(ofSize: 17.0)
            cell.labelQuestionAnswer.text = data?.answer.replacingOccurrences(of: "\\n", with: "\n")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
