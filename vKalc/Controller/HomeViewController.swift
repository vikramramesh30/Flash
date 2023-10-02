//
//  HomeViewController.swift
//  vKalc
//
//  Created by cis on 12/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase
import Speech
//import Kingfisher
import Alamofire
import AudioToolbox
import PINRemoteImage
import PINCache
//import SDWebImage
import DropDown

func colorsWithHalfOpacity(_ colors: [CGColor]) -> [CGColor] {
    return colors.map({ $0.copy(alpha: $0.alpha * 0.5)! })
}

class HomeViewController: BaseViewController, LanguageDelegate, UITextFieldDelegate, tableViewSelectonDelegate, AVAudioPlayerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var buttonGettingStarted: UIButton!
    @IBOutlet weak var buttonHowTo: UIButton!
    @IBOutlet weak var inputView_heightConstraint:  NSLayoutConstraint!
    @IBOutlet weak var lbl_msg: UILabel!
    @IBOutlet weak var resultView_heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberLine_heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultContainerView:     UIView!
    @IBOutlet weak var numberLineContainerView: UIView!
    @IBOutlet weak var inputContainerView:      UIView!
    @IBOutlet weak var view_inputContainer:     UIView!
    @IBOutlet weak var txt_field:               CustomTextField!
    @IBOutlet weak var btn_record:              CircleButton!
    @IBOutlet weak var imgView_flag:            UIImageView!
    @IBOutlet weak var lbl_language:            UILabel!
    @IBOutlet weak var lbl_anchorView:          UILabel!
    @IBOutlet weak var img_view:                UIImageView!
    @IBOutlet weak var btn_share:               UIButton!
    @IBOutlet weak var img_viewMsg: UIImageView!
    @IBOutlet weak var lbl_input:               UILabel!
    @IBOutlet weak var lbl_result:              UILabel!
    @IBOutlet weak var lbl_line:                UILabel!
    let recordSound = URL(fileURLWithPath: Bundle.main.path(forResource: "button_press", ofType: "caf")!)
    var audioPlayer = AVAudioPlayer()
    var pulsatingLayer: CAShapeLayer!
    var dropDownMenu =  DropDown()
    var arrMenu      = ["Getting Started", "How to...", "Help", "History", "Language", "Logout"]
    var lang:String  = "US-English (United States)"
    var imgView_line = UIImageView()
    var imgView_output = UIImageView()
    var imgView_graph = UIImageView()
    var imgView_input = UIImageView()
    var isInsertEnabled:Bool = true
    var isRecording:Bool = true
    var isFirst:Bool = true
    var isButtonEnabled = false
    static private let preferencePath = "App-Prefs:root"
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var speechRecognitionTimeout: Timer?
    
    private func restartSpeechTimeout() {
        if self.speechRecognitionTimeout != nil {
            speechRecognitionTimeout?.invalidate()}
        speechRecognitionTimeout = Timer.scheduledTimer(timeInterval:3, target: self, selector: #selector(didFinishTalk), userInfo: nil, repeats: false)
    }
    
    //MARK : - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.title = "Flash"
        self.navigationController?.navigationBar.isHidden = false
        self.view_inputContainer.isHidden = true
        self.addMenuBtn()
        btn_record.isEnabled = false
        self.numberLineContainerView.addSubview(imgView_line)
        self.inputContainerView.addSubview(imgView_input)
        self.resultContainerView.addSubview(imgView_output)
        self.resultContainerView.addSubview(imgView_graph)
        inputView_heightConstraint.constant = 0
        resultView_heightConstraint.constant = 0
        numberLine_heightConstraint.constant = 0
        [buttonGettingStarted, buttonHowTo].forEach{$0?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)}
        
        AVAudioSession.sharedInstance().requestRecordPermission({_ in
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.applicationDidBecomeActive()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.menuDropDown()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    @objc func applicationDidBecomeActive() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                self.isButtonEnabled = true
                
            case .denied:
                self.isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                self.isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                self.isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                // No need to request permission.
                self.isButtonEnabled = false
                print("N/A")
            }
            
            OperationQueue.main.addOperation() {
                self.btn_record.isEnabled = true
                self.btn_record.layer.removePulses()
                self.addRepeatingPulse()
                if self.isButtonEnabled {
                    AVAudioSession.sharedInstance().requestRecordPermission({status in
                        if status {
                            
                        } else {
                            self.openSettings()
                        }
                    })
                }
            }
        }
    }
    
    //MARK:- Speech Recognization
    func startRecording() {
        if #available(iOS 11.0, *) {
            self.audioEngine.isAutoShutdownEnabled = true
        } else {
            // Fallback on earlier versions
        }
        self.isInsertEnabled = true
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        self.restartSpeechTimeout()
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true,options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                self.txt_field.text = result?.bestTranscription.formattedString  //9
                self.restartSpeechTimeout()
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.speechRecognitionTimeout?.invalidate()
                self.updateButton(isEnabled: false)
                //                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                //                    self.playSound()
                //                })
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        txt_field.text = ""
    }
    
    func playSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: self.recordSound)
            audioPlayer.delegate = self
            if isFirst {
                audioPlayer.volume = 0.8
                self.isFirst = false
            } else {
                audioPlayer.volume = 4.0
            }
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - button Action
    
    @objc func buttonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == buttonGettingStarted {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GettingStartedViewController") as! GettingStartedViewController
            vc.type = .home
            self.navigationController?.pushViewController(vc, animated: true)
        }else if sender == buttonHowTo {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowToViewController") as! HowToViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func action_recordVoice(_ sender: Any) {
        if isButtonEnabled {
            self.isRecording = true
            self.playSound()
        } else {
            self.openSettings()
        }
    }
    
    @IBAction func actionShare(_ sender: Any) {
        if self.inputContainerView.isHidden == false && self.imgView_input.image != nil {
            // let image = view_inputContainer.snapshot(of: view_inputContainer.bounds)
            // let message = MessageWithSubject(subject: "Flash - World's best Natural Language Graphing Calculator", message: "Flash - World's best Natural Language Graphing Calculator")
            // let itemsToShare:[Any] = [ message, image ]
            
            //let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            LoadingIndicator.sharedInstance.showActivityIndicator()
            let image = view_inputContainer.snapshot(of: view_inputContainer.bounds)
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            let imageShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
            activityViewController.setValue("Flash - World's best Natural Language Graphing Calculator", forKey: "subject")
            self.present(activityViewController, animated: true, completion: nil)
            LoadingIndicator.sharedInstance.hideActivityIndicator()
        }
    }
    
    @IBAction func action_bgTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func didFinishTalk() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = nil
        self.isRecording = false
        self.playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            if self.txt_field.text == "" {
                self.txt_field.text = "No Speech Input"
            }
        })
    }
    
    @objc func handleMenuBtn() {
        self.dropDownMenu.show()
    }
    
    func logout(){
        let alert = UIAlertController.init(title: "Flash", message: "Do you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance()?.signOut()
                UserDefaults.standard.set(nil, forKey: "USERID")
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK : - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer = AVAudioPlayer()
        if self.isRecording {
            self.startRecording()
            self.updateContainerView()
            self.lbl_msg.text = ""
            self.img_viewMsg.image = nil
            self.updateButton(isEnabled: true)
        }
    }
    
    //MARK: - TextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "Please try again" {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0  >  0 {
            self.isInsertEnabled = true
            self.updateContainerView()
            self.getResponse()
        }
        view.endEditing(true)
        return true
    }
    
    //MARK: - Speech Delegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btn_record.isEnabled = true
        } else {
            btn_record.isEnabled = false
        }
    }
    
    //MARK: - Language Delegate
    func hadleLanguageSelection(lang:String,country:String,flag:UIImage) {
        self.lang = lang
        self.imgView_flag.image = flag
        self.lbl_language.text = lang
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: country))!
    }
    
    //MARK: - tableViewSelectionDelegate
    func didSelectedRow(que: String) {
        self.txt_field.text = que
        self.isInsertEnabled = false
        self.getResponse()
    }
    
    // MARK: - Class methods -
    func openSettings() {
        self.func_AlertWithTwoOption(message: "Please enable microphone usage and speech recognition services for this application in settings", optionOne: "Open Settings", optionTwo: "Cancel", actionOne: {
            if let bundleId = Bundle.main.bundleIdentifier{
                if #available(iOS 10.0, *) {
                    _ = URL(string: "\(UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!))&path=/\(bundleId)")
                } else {
                    _ = URL(string: "\(UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!))&path=/\(bundleId)")
                }
            }
        }, actionTwo: {
            
        })
    }
}

extension HomeViewController {
    //MARK: - UI Update
    
    func menuDropDown(){
        self.dropDownMenu.dataSource = arrMenu
        self.dropDownMenu.anchorView = self.lbl_anchorView
        self.dropDownMenu.direction = .bottom
        self.dropDownMenu.width = self.lbl_anchorView.frame.width
        // self.dropDownMenu.height = 160
        self.dropDownMenu.backgroundColor = UIColor.white
        self.dropDownMenu.selectionAction = { [weak self](index: Int, item: String) in
            guard let self = self else { return }
            switch index {
            case 0: break
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowToViewController") as! HowToViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
                self.updateContainerView()
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
                vc.delegate = self
                self.updateContainerView()
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LanguageViewController") as! LanguageViewController
                vc.currentLang = self.lang
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
            case 5:
                self.logout()
            default:
                break
            }
        }
    }
    
    func addRepeatingPulse() {
        let _ = self.btn_record.layer.addPulse { pulse in
            pulse.lineWidth = 0.0
            pulse.borderColors = [
                UIColor(r: 25, g: 25, b: 25).cgColor
            ]
            pulse.transformBefore = CATransform3DMakeScale(1, 1, 0.3)
            pulse.duration = 1.5
            pulse.repeatDelay = 0.0
            pulse.repeatCount = Int.max
            pulse.backgroundColors = colorsWithHalfOpacity(pulse.borderColors)
        }
    }
    
    func addMenuBtn()  {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleMenuBtn), for: .touchUpInside)
        button.sizeToFit()
        button.setImage(#imageLiteral(resourceName: "ellip"), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        var image = UIImage(named: "mike")
        image = image?.withRenderingMode(.alwaysOriginal)
        let btn = UIBarButtonItem(image: image, style:.plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = btn
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    func updateButton(isEnabled:Bool) {
        if isEnabled{
            self.btn_record.isEnabled = false
            self.btn_record.backgroundColor = UIColor(r: 243, g: 63, b: 46)
            self.btn_record.isUserInteractionEnabled = false
            self.img_view.image = #imageLiteral(resourceName: "microphone-1")
            self.btn_record.layer.removePulses()
        } else {
            DispatchQueue.main.async {
                if self.txt_field.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0  >  0 && self.txt_field.text != "No Speech Input"{
                    self.getResponse()
                }
            }
            self.btn_record.isUserInteractionEnabled = false
            self.btn_record.isEnabled = false
            self.btn_record.backgroundColor = UIColor(r: 67, g: 67, b: 67)
            self.img_view.image = #imageLiteral(resourceName: "mikeNew")
            self.addRepeatingPulse()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                self.btn_record.isUserInteractionEnabled = true
                self.btn_record.isEnabled = true
            })
            
        }
    }
    
    func updateContainerView() {
        self.imgView_line.image = nil
        self.imgView_output.image = nil
        self.imgView_input.image = nil
        self.imgView_graph.image = nil
        self.btn_share.isHidden = true
        self.lbl_result.text = ""
        self.lbl_input.text = ""
        self.lbl_line.text = ""
        self.view_inputContainer.isHidden = true
        inputView_heightConstraint.constant = 0
        resultView_heightConstraint.constant = 0
        numberLine_heightConstraint.constant = 0
    }
}

extension HomeViewController {
    
    //MARK: - Database Method
    func insertData(que:String,ans:String,title:String,img:String,scanner:String)  {
        
        if let user = Auth.auth().currentUser {
            let date = Date()
            let dateString = DateFormatter.sharedDateFormatter.string(from: date)
            let timeStamp: Int64? = Date().currentTimeMillis()
            let timestampStr = String(Date().currentTimeMillis())
            let id = UserDefaults.standard.value(forKey: "USERID") as! String
            let dbRef = Database.database().reference(fromURL: "https://vkalc-bc29a.firebaseio.com")//"https://chatapp-6e864.firebaseio.com/")//
            let dataRef = dbRef.child("searchedTopic").child(id).child(timestampStr)
            let value = ["answer":ans, "date":dateString,"fullJSON":"","image":img,"question":que,"scannerVal":scanner,"time":timeStamp as Any,"title":title,"userEmail":user.email!,"userId":id,"userName":user.displayName!] as [String : Any]
            dataRef.updateChildValues(value, withCompletionBlock: {(err,ref) in
                if err != nil {
                    return
                }
                print("saved successfully")
                self.dismiss(animated: true, completion: nil)
            })
        }
        self.isInsertEnabled = true
    }
    
    //MARK:- API Call
    func getResponse() {
        var que:String      = ""
        var ans:String      = ""
        var title:String    = ""
        var imgName:String  = ""
        var scanner:String  = ""
        
        let url = "https://api.wolframalpha.com/v2/query?appid=299V6G-EUW85Y76WW"
        var txt = (self.txt_field.text)!
        txt = txt.replacingOccurrences(of: "×", with: "x")
        txt = txt.replacingOccurrences(of: "Open Bracket", with: "(")
        txt = txt.replacingOccurrences(of: "Closed Bracket", with: ")")
        txt = txt.replacingOccurrences(of: "Open Parenthesis", with: "(")
        txt = txt.replacingOccurrences(of: "Closed Parenthesis", with: ")")

        let param = ["input":txt,
                     "format":"image,plaintext",
                     "output":"JSON"]
        
        //"appid":"299V6G-EUW85Y76WW"]
        // print("input",param)
        // LoadingIndicator.sharedInstance.showActivityIndicator()
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.lbl_msg.text = ""
        self.img_viewMsg.image = nil
        
        WebService.sharedInstance.requestMultipart(url: url, param: param, decodingType: MainObject.self, Success: { [weak self] response in
            UIApplication.shared.endIgnoringInteractionEvents()
            guard let self = self else { return }
            guard let res = response as? MainObject, let pods = res.queryresult?.pods else {
                //self.txt_field.text = "Please try again"
                self.lbl_msg.text = "Please try again"
                self.img_viewMsg.image = #imageLiteral(resourceName: "double-arrow")
                print("data no found")
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                return
            }
            if !pods.isEmpty {
                // if data_1.queryresult?.pods?.count ?? 0 > 0{
                let pod = pods[0]
                let img = pod.subpods![0].img!
                self.lbl_input.text = pod.title
                if let url = URL(string: img.src!){
                    var width:Int = 0
                    if CGFloat(img.width!) > self.inputContainerView.frame.width-20 {
                        width = Int(self.resultContainerView.frame.width)-45
                    } else {
                        width = img.width!
                    }
                    self.imgView_input.frame = CGRect(x: 0, y: 31, width: width, height: img.height!)
                    self.imgView_input.image = nil
                    self.imgView_input.pin_updateWithProgress = true
                    self.imgView_input.pin_setImage(from: url)//sd_setImage(with: url)//.kf.setImage(with: url)
                    self.imgView_input.contentMode = .scaleAspectFit
                    self.imgView_input.clipsToBounds = true
                    self.inputView_heightConstraint.constant = 30 + CGFloat(img.height!)
                    self.inputContainerView.isHidden = false
                    que = pod.subpods![0].plaintext ?? ""
                    imgName = img.src!
                    scanner = pod.scanner ?? ""
                    title = pod.title ?? ""
                }
                //  }
                if pods.count > 1 {
                    let pod = pods[1]
                    var width:Int = 0
                    var y:Int = 30
                    var height = 10
                    self.lbl_result.text = pod.title
                    
                    for i in 0...(pod.subpods?.count)!-1 {
                        
                        let img = pod.subpods![i].img!
                        if CGFloat(img.width!) > self.resultContainerView.frame.width {
                            width = Int(self.resultContainerView.frame.width)-20
                        } else {
                            width = img.width!
                        }
                        var imgView = UIImageView()
                        if i == 0 {
                            imgView = self.imgView_output
                        } else if i == 1 {
                            imgView = self.imgView_graph
                            
                        } else {
                            break
                        }
                        if let url = URL(string: img.src!){
                            var imgHeight = 0
                            if img.height! > 420 {
                                imgHeight = 420
                            } else {
                                imgHeight = img.height!}
                            imgView.frame = CGRect(x: 0, y: y, width: width, height: imgHeight)
                            imgView.image = nil
                            imgView.pin_updateWithProgress = true
                            imgView.pin_setImage(from: url)//sd_setImage(with: url)//kf.setImage(with: url)
                            imgView.contentMode = .scaleAspectFit
                            imgView.clipsToBounds = true
                            y = y + 15 + imgHeight
                            height = height + imgHeight
                        }
                    }
                    ans = pod.subpods![0].plaintext ?? ""
                    self.resultView_heightConstraint.constant = 30 + CGFloat(height)
                    self.resultContainerView.isHidden = false
                }
                if pods.count > 2 {
                    let pod = pods[2]
                    let img = pod.subpods![0].img!
                    self.lbl_line.text = pod.title
                    if let url = URL(string: img.src!){
                        var width:Int = 0
                        if CGFloat(img.width!) > self.numberLineContainerView.frame.width {
                            width = Int(self.numberLineContainerView.frame.width)-20
                        } else {
                            width = img.width!
                        }
                        self.imgView_line.frame = CGRect(x: 0, y: 31, width: width, height: img.height!)
                        self.imgView_line.image = nil
                        
                        self.imgView_line.pin_updateWithProgress = true
                        self.imgView_line.pin_setImage(from: url)//sd_setImage(with: url)//kf.setImage(with: url)
                        self.imgView_line.contentMode = .scaleAspectFit
                        self.imgView_line.clipsToBounds = true
                        self.numberLine_heightConstraint.constant = 40 + CGFloat(img.height!)
                        self.numberLineContainerView.isHidden = false
                    }
                }
                self.btn_share.isHidden = false
                self.view_inputContainer.isHidden = false
                if self.isInsertEnabled {
                    self.insertData(que: que, ans: ans, title: title, img: imgName, scanner: scanner)
                }
                let nextVc = self.storyboard?.instantiateViewController(withIdentifier: "NewHomeViewController") as! NewHomeViewController
                nextVc.txt = txt
                self.navigationController?.pushViewController(nextVc, animated: true)
            }else{
                //self.txt_field.text = "Please try again"
                self.lbl_msg.text = "Please try again"
                self.img_viewMsg.image = #imageLiteral(resourceName: "double-arrow")
                print("data no found")
            }
            }, Error: { [weak self] message in
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                guard let self = self else { return }
                //self.txt_field.text = "Please try again"
                self.lbl_msg.text = "Please try again"
                self.img_viewMsg.image = #imageLiteral(resourceName: "double-arrow")
        })
    }
}
