//
//  LanguageViewController.swift
//  vKalc
//
//  Created by cis on 24/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
protocol LanguageDelegate {
    func hadleLanguageSelection(lang:String,country:String,flag:UIImage)
}

class LanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate:LanguageDelegate!
    var arrLang:[String] = ["US-English (United States)","IN-English (India)","AU-English (Australia)","CA-English (Canada)","GB-English (Great Britain)", "IE-English (Ireland)","NZ-English (Newzealand)","PH-English (Philippined)"
        ,"SG-English (Singapore)","ZA-English (South Africa)"]
    var arrCountryCode :[String] = ["en-US","en-IN","en-AU","en-CA","en-GB", "en-IE","en-NZ","en-PH","en-SG","en-ZA"]
    var arrFlag:[UIImage] = [#imageLiteral(resourceName: "united-states") , #imageLiteral(resourceName: "india") , #imageLiteral(resourceName: "australia"), #imageLiteral(resourceName: "canada"), #imageLiteral(resourceName: "united-kingdom"), #imageLiteral(resourceName: "ireland"), #imageLiteral(resourceName: "new-zealand"), #imageLiteral(resourceName: "philippines"), #imageLiteral(resourceName: "singapore"), #imageLiteral(resourceName: "south-africa")]
    var currentLang:String = "US-English (United States)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrLang.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell_lang", for: indexPath)
        let lbl:UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let img:UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        let lang = self.arrLang[indexPath.row]
        if lang == self.currentLang {
            img.image = #imageLiteral(resourceName: "radio")
        } else {
            img.image = #imageLiteral(resourceName: "circle")
        }
        lbl.text = lang
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func action_bgTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action_didSelect(_ sender: Any) {
        let buttonPosition:CGPoint = (sender as AnyObject).convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let lang = self.arrLang[indexPath!.row]
        self.currentLang = lang
        self.delegate.hadleLanguageSelection(lang: lang, country: self.arrCountryCode[indexPath!.row], flag: self.arrFlag[indexPath!.row])
        self.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}
//Ramesh Google Account
//neurogramai@gmail.com
//Neurogramai2004$
