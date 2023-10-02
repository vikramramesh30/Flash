//
//  NewHomeViewController.swift
//  vKalc
//
//  Created by cis on 16/08/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase
import Speech
import Alamofire
import AudioToolbox
import PINRemoteImage
import PINCache
import AVFoundation
import DropDown
import WebKit

class NewHomeViewController: BaseViewController , LanguageDelegate, UITextFieldDelegate,UITextViewDelegate, tableViewSelectonDelegate, AVAudioPlayerDelegate, UIScrollViewDelegate  {
    
    @IBOutlet weak var buttonGettingStarted: UIButton!
    @IBOutlet weak var buttonHowTo: UIButton!
    @IBOutlet var imgViewLogo: UIImageView!
    @IBOutlet weak var zoomableView: ZoomableView!
    @IBOutlet var txtView: UITextView!
    @IBOutlet weak var scrollViewResults: UIScrollView!
    @IBOutlet weak var lbl_msg:                 UILabel!
    @IBOutlet weak var stackView:               UIStackView!
    @IBOutlet weak var txt_field:               CustomTextField!
    @IBOutlet weak var btn_record:              CircleButton!
    @IBOutlet weak var buttonScan:              CircleButton!
    @IBOutlet weak var imgView_flag:            UIImageView!
    @IBOutlet weak var lbl_language:            UILabel!
    @IBOutlet weak var lbl_anchorView:          UILabel!
    @IBOutlet weak var img_view:                UIImageView!
    @IBOutlet weak var btn_share:               UIButton!
    @IBOutlet weak var img_viewMsg:             UIImageView!
    @IBOutlet weak var webViewDesmos:           WKWebView!
    @IBOutlet weak var viewDesmos:              UIView!
    @IBOutlet weak var viewDesmosHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgView_DesmosLogo:      UIImageView!
    @IBOutlet weak var viewSeparator:           UIView!
    
    //MARK: - Variables
    let recordSound = URL(fileURLWithPath: Bundle.main.path(forResource: "button_press", ofType: "caf")!)
    var pods: [Pod] = []
    var txt:String = ""
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var speechRecognitionTimeout: Timer?
    var audioPlayer:AVAudioPlayer!
    var pulsatingLayer: CAShapeLayer!
    var dropDownMenu =  DropDown()
    var arrMenu      = ["Getting Started", "How to...", "Help", "History", "Language", "Logout"]
    var lang:String  = "US-English (United States)"
    var isInsertEnabled:Bool = true
    var isRecording:Bool = true
    var isFirst:Bool = true
    var isButtonEnabled = false
    var isFinished:Bool = false
    var countCalled = 0
    var isWentInsideBlock:Bool = false
    var que:String      = ""
    var ans:String      = ""
    var titleStr:String = ""
    var imgName:String  = ""
    var scanner:String  = ""
    let formulaInfo = false
    var formulaValue = ""
    
    //MARK: - Timer
    private func restartSpeechTimeout() {
        if self.speechRecognitionTimeout != nil {
            speechRecognitionTimeout?.invalidate()}
        speechRecognitionTimeout = Timer.scheduledTimer(timeInterval:3, target: self, selector: #selector(didFinishTalk), userInfo: nil, repeats: false)
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgViewLogo.isHidden = true
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.title = "Flash"
        self.navigationController?.navigationBar.isHidden = false
        zoomableView.setZoomable(true)
        self.addMenuBtn()
        
        self.webViewDesmos.layer.cornerRadius = 1.0
        self.webViewDesmos.clipsToBounds = true
        self.webViewDesmos.layer.borderColor = UIColor.lightGray.cgColor
        self.webViewDesmos.layer.borderWidth = 0.7
        
        self.desmosView(isShow: false, data: [])
        
        [buttonGettingStarted, buttonHowTo].forEach{$0?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)}
        AVAudioSession.sharedInstance().requestRecordPermission({_ in
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.scrollViewResults.setContentOffset(.zero, animated: false)
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
    
    //MARK: - Helper Function
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
    
    func playSound() {
        do {
            let recordSound = URL(fileURLWithPath: Bundle.main.path(forResource: "button_press", ofType: "caf")!)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: recordSound)
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
    
    //MARK: - Button Action
    
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
    
    @IBAction func action_bgTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func action_share(_ sender: Any) {
        if self.stackView.isHidden == false {
            // let image = view_inputContainer.snapshot(of: view_inputContainer.bounds)
            // let message = MessageWithSubject(subject: "Flash - World's best Natural Language Graphing Calculator", message: "Flash - World's best Natural Language Graphing Calculator")
            // let itemsToShare:[Any] = [ message, image ]
            
            //let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            LoadingIndicator.sharedInstance.showActivityIndicator()
            let image = stackView.snapshot(of: stackView.bounds)
            // if ph
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            let imageShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
            activityViewController.setValue("Flash - World's best Natural Language Graphing Calculator", forKey: "subject")
            self.present(activityViewController, animated: true, completion: nil)
            LoadingIndicator.sharedInstance.hideActivityIndicator()
        }
    }
    
    @IBAction func action_recordVoice(_ sender: Any) {
        if isButtonEnabled {
            if self.stackView.arrangedSubviews.count > 0 {
                for view in stackView.arrangedSubviews {
                    view.removeFromSuperview()
                }
            }
            self.imgViewLogo.isHidden = true
            self.isRecording = true
            self.isWentInsideBlock = false
            self.isFinished = false
            self.countCalled = 0
            self.desmosView(isShow: false, data: [])
            self.playSound()
        } else {
            self.openSettings()
        }
    }
    
    @IBAction func buttonScanTapped(_ sender: Any) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func action_search(_ sender: Any) {
        if self.txtView.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0  >  0 {
            self.isInsertEnabled = true
            self.getResponse()
        }
        view.endEditing(true)
    }
    
    @IBAction func action_clearTextField(_ sender: Any) {
        self.txtView.text = ""
        self.txtView.becomeFirstResponder()
    }
    
    //MARK: - Button Targets
    @objc func zoomImageView (_ sender : UIButton) {
        if let accesssId = sender.accessibilityIdentifier {
            let arr = accesssId.components(separatedBy: ":")
            if arr.count > 0 {
                let vc =  ImageSlider.init(nibName: "ImageSlider", bundle: nil)
                let pod = self.pods[Int(arr[0]) ?? 0]
                if let img = pod.subpods![Int(arr[1]) ?? 0].img {
                    vc.url = img.src ?? ""
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func handleMenuBtn() {
        self.dropDownMenu.show()
    }
    
    @objc func didFinishTalk() {
        // if self.isFinished {
        if self.isWentInsideBlock {
            if countCalled > 0 {//!(self.isFinished) {
                self.stopEngine()
            } else {
                print("timer restarted")
                self.restartSpeechTimeout()
            }
        } else {
            if countCalled > 0 {
                self.stopEngine()
            } else {
                self.restartSpeechTimeout()
            }
        }
        self.countCalled = self.countCalled + 1
        
        //}
        //        else {
        
        //        }
    }
    
    func stopEngine() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = nil
        self.isRecording = false
        print("timer invalidated")
        //self.playSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            if self.txtView.text == "" {
                self.txtView.text = "No Speech Input"
            }
        })
    }
    
    //MARK : - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //  self.audioPlayer = AVAudioPlayer()
        if self.isRecording {
            self.startRecording()
            //self.updateContainerView()
            self.lbl_msg.text = ""
            self.img_viewMsg.image = nil
            self.updateButton(isEnabled: true)
        }
        self.audioPlayer.delegate = nil
        self.audioPlayer = nil
    }
    
    //MARK: - TextFieldDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Please try again" {
            textView.text = ""
        }
        if self.stackView.arrangedSubviews.count > 0 {
            for view in stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
        self.desmosView(isShow: false, data: [])
        self.imgViewLogo.isHidden = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            self.getResponse()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "Please try again" {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0  >  0 {
            self.isInsertEnabled = true
            //self.updateContainerView()
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
        self.txtView.text = que
        if self.stackView.arrangedSubviews.count > 0 {
            for view in stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
        }
        self.desmosView(isShow: false, data: [])
        self.isInsertEnabled = false
        self.getResponse()
    }
    
    //MARK: - Desmos Graph
    private func loadDesmosGrpah() {
        if let path = Bundle.main.url(forResource: "Desmos", withExtension: "html"){
            let myURLRequest:URLRequest = URLRequest(url: path)
            self.webViewDesmos.navigationDelegate = self
            self.webViewDesmos.load(myURLRequest)
        }
    }
    
    private func desmosView(isShow: Bool, data: [Pod]) {
        if isShow {
            self.viewDesmos.isHidden = false
            self.viewDesmosHeightConstraint.constant = 330.0
            self.viewSeparator.isHidden = false
            self.formulaValue = data[0].subpods![0].plaintext ?? ""
            self.imgView_DesmosLogo.isHidden = false
            self.loadDesmosGrpah()
        } else {
            self.viewDesmos.isHidden = true
            self.viewDesmosHeightConstraint.constant = 0.0
            self.viewSeparator.isHidden = true
            self.imgView_DesmosLogo.isHidden = true
            self.formulaValue = ""
        }
        self.view.layoutIfNeeded()
    }
}

extension NewHomeViewController {
    
    //MARK: - Open Setting App
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
    
    //MARK: - LogOut
    func logout(){
        let alert = UIAlertController.init(title: "Flash", message: "Do you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance()?.signOut()
                UserDefaults.standard.set(nil, forKey: "USERID")
                
                if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
                    for vc in viewControllers {
                        if vc.isKind(of: SignInViewController.self) {
                            self.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                }
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Define Menu
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
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GettingStartedViewController") as! GettingStartedViewController
                vc.type = .home
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowToViewController") as! HowToViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case 3:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
                vc.delegate = self
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
    
    //MARK: - Add Pulse
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
    
    //MARK: - Add Menu Button
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
    
    //MARK: - Update Button
    func updateButton(isEnabled:Bool) {
        if isEnabled{
            self.btn_record.isEnabled = false
            self.btn_record.backgroundColor = UIColor(r: 243, g: 63, b: 46)
            self.btn_record.isUserInteractionEnabled = false
            self.img_view.image = #imageLiteral(resourceName: "microphone-1")
            self.btn_record.layer.removePulses()
        } else {
            DispatchQueue.main.async {
                if self.txtView.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0  >  0 && self.txtView.text != "No Speech Input"{
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
}

extension NewHomeViewController {
    
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
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
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
            self.isWentInsideBlock = true
            self.txtView.textColor = .black
              self.restartSpeechTimeout()
            var isFinal = false  //8
            if result != nil {
                self.txtView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
                print(isFinal)
            }
            
            if error != nil || isFinal {  //10
                self.isFinished = isFinal
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                print("timer invalidated from block")
                self.speechRecognitionTimeout?.invalidate()
                self.updateButton(isEnabled: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
                    //DispatchQueue.main.async {
                    self.playSound()
                })
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
        txtView.text = ""
    }
}

extension NewHomeViewController {
    
    //MARK: - Database Method
    func insertData(que:String,ans:String,title:String,img:String,scanner:String)  {
        if let user = Auth.auth().currentUser {
            let date = Date()
            let dateString = DateFormatter.sharedDateFormatter.string(from: date)
            let timeStamp = Date().currentTimeMillis()
            let timestampStr = String(Date().currentTimeMillis())
            let id = UserDefaults.standard.value(forKey: "USERID") as! String
            let dbRef = Database.database().reference(fromURL: "https://vkalc-bc29a.firebaseio.com")//"https://chatapp-6e864.firebaseio.com")//
            let dataRef = dbRef.child("searchedTopic").child(id).child(timestampStr)
            let value = ["answer":ans, "date":dateString,"fullJSON":"","image":img,"question":que,"scannerVal":scanner,"time":timeStamp ?? 0,"title":title,"userEmail":user.email!,"userId":id,"userName":user.displayName!] as [String : Any]
            dataRef.updateChildValues(value, withCompletionBlock: {(err,ref) in
                if err != nil {
                    return
                }
                print("saved successfully")
                self.dismiss(animated: true, completion: nil)
            })
            
            
        } else if let userid = UserDefaults.standard.value(forKey: "USERID") as? String {
            let date = Date()
            let dateString = DateFormatter.sharedDateFormatter.string(from: date)
            let timeStamp = Date().currentTimeMillis()
            let timestampStr = String(Date().currentTimeMillis())
            let email = UserDefaults.standard.value(forKey: "EMAIL") as? String ?? ""
            let Name = UserDefaults.standard.value(forKey: "NAME") as? String ?? ""
            // let id = UserDefaults.standard.value(forKey: "USERID") as! String
            let dbRef = Database.database().reference(fromURL: "https://vkalc-bc29a.firebaseio.com")//"https://chatapp-6e864.firebaseio.com")//
            let dataRef = dbRef.child("searchedTopic").child(userid).child(timestampStr)
            let value = ["answer":ans, "date":dateString,"fullJSON":"","image":img,"question":que,"scannerVal":scanner,"time":timeStamp ?? 0,"title":title,"userEmail":email,"userId":userid,"userName":Name] as [String : Any]
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
        let url = "https://api.wolframalpha.com/v2/query?appid=299V6G-EUW85Y76WW"
        var txt = (self.txtView.text)!
        txt = txt.replacingOccurrences(of: "×", with: "x")
        txt = txt.replacingOccurrences(of: "Open Bracket", with: "(")
        txt = txt.replacingOccurrences(of: "Closed Bracket", with: ")")
        txt = txt.replacingOccurrences(of: "Open Parenthesis", with: "(")
        txt = txt.replacingOccurrences(of: "Closed Parenthesis", with: ")")
        
        let param = ["input":txt,
                     "format":"image,plaintext",
                     "output":"JSON"]
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.lbl_msg.text = ""
        self.img_viewMsg.image = nil
        
        WebService.sharedInstance.requestMultipart(url: url, param: param, decodingType: MainObject.self, Success: { [weak self] response in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            guard let self = self else { return }
            
            self.scrollViewResults.setContentOffset(.zero, animated: false)
            
            guard let res = response as? MainObject, let pods = res.queryresult?.pods else {
                self.refreshView()
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                return
            }
            
            if !pods.isEmpty {
                self.pods = pods
                // self.desmosView(isShow: true, data: pods)
                self.formulaValue = pods[0].subpods![0].plaintext ?? ""
                self.formulaValue = self.formulaValue.replacingOccurrences(of: "×", with: "x")
                self.loadDesmosGrpah()
                
                for i in 0...pods.count-1 {
                    self.imgViewLogo.isHidden = false
                    if i < 6 {
                        let pod = pods[i]
                        var count = 0
                        if pod.subpods!.count > 1 {
                            count = 1
                        } else {
                            count = 0
                        }
                        for j in 0...count {
                            let img = pod.subpods![j].img!
                            let viewHome:HomeView = HomeView()
                            if j == 0 {
                                viewHome.lblName.text = pod.title ?? ""
                                if count == 1 {
                                    viewHome.bottomSpaceconstraint.constant = 0
                                } else {
                                    viewHome.bottomSpaceconstraint.constant = 12
                                }
                                
                            } else {
                                viewHome.lblName.text = ""
                                viewHome.bottomSpaceconstraint.constant = 12
                            }
                            if pods[0].title == pod.title {
                                viewHome.img_doubleArrow.image = #imageLiteral(resourceName: "double-arrow")
                            } else {
                                viewHome.img_doubleArrow.image = nil
                            }
                            
                            if CGFloat(img.height ?? 0) >= self.view.frame.height / 1.5 {
                                viewHome.imgViewHeightConstraint.constant = self.view.frame.height / 1.5
                            } else {
                                viewHome.imgViewHeightConstraint.constant = CGFloat(img.height ?? 0)//+20)
                            }
                            if CGFloat(img.width ?? 0) >= self.view.frame.width {
                                viewHome.imgViewWidthConstraint.constant = self.view.frame.width
                            } else {
                                viewHome.imgViewWidthConstraint.constant = CGFloat(img.width ?? 0)//+60)
                            }
                            
                            if let url = URL(string: img.src ?? ""){
                                viewHome.imgView.pin_updateWithProgress = true
                                viewHome.imgView.pin_setImage(from: url)
                                //viewHome.btn_zoomImage.tag = i
                                viewHome.btn_zoomImage.accessibilityIdentifier = "\(i):\(j)"
                                viewHome.btn_zoomImage.addTarget(self, action: #selector(self.zoomImageView(_:)), for: .touchUpInside)
                            }
                            self.stackView.addArrangedSubview(viewHome)
                        }
                    } else {
                        break
                    }
                }
                
                if self.isInsertEnabled {
                    if pods.count > 1 {
                        self.ans = self.txtView.text//pods[1].subpods![0].plaintext ?? ""
                        let arr = self.ans.components(separatedBy: .whitespacesAndNewlines)
                        let ans_ = arr.joined(separator: " ")
                        print(ans_)
                        self.imgName = pods[0].subpods![0].img!.src!
                        self.que = pods[0].subpods![0].plaintext ?? ""
                        self.titleStr = pods[0].title ?? ""
                        self.scanner = pods[0].scanner ?? ""
                        self.insertData(que: ans_, ans: self.que, title: self.titleStr, img: self.imgName, scanner: self.scanner)}
                }
            }else{
                self.refreshView()
                LoadingIndicator.sharedInstance.hideActivityIndicator()
            }
            }, Error: { [weak self] message in
                LoadingIndicator.sharedInstance.hideActivityIndicator()
                guard let self = self else { return }
                //self.txt_field.text = "Please try again"
                self.refreshView()
        })
    }
    
    func refreshView() {
        self.lbl_msg.text = "Please try again"
        self.img_viewMsg.image = #imageLiteral(resourceName: "double-arrow")
        ans = ""
        imgName = ""
        que = self.txtView.text
        titleStr = ""
        scanner = ""
        self.insertData(que: que, ans: ans, title: titleStr, img: imgName, scanner: scanner)
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

extension NewHomeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if host.contains(Constants.url) {
                let dict = navigationAction.request.url?.queryParameters
                if dict?[Constants.param] == "1" {
                    self.imgView_DesmosLogo.isHidden = false
                    self.viewDesmos.isHidden = false
                    self.viewDesmosHeightConstraint.constant = 330.0
                    self.viewSeparator.isHidden = false
                }else if dict?[Constants.param] == "0" {
                    self.viewDesmos.isHidden = true
                    self.viewDesmosHeightConstraint.constant = 0.0
                    self.viewSeparator.isHidden = true
                    self.imgView_DesmosLogo.isHidden = true
                }
                self.formulaValue = ""
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // print("Finished navigating to url \(String(describing: webView.url))")
        
        webView.evaluateJavaScript("manageGraph(\(formulaInfo),'\(formulaValue)');") { (result, error) in
            if error == nil {
                print("success")
            } else {
                print("error in executing js = ", error as Any)
            }
        }
    }
}


//"FAQ" : {
//    "1" : {
//        "id" : "1",
//        "question" : "What is a Natural Language Calculator?",
//        "answer" : "Unlike all other calculators that requires users to key in all types of input to get results, a Natural Language Calculator is one that works by just talking in your natural language. For ex. instead of keying in "2 + 2" and then "=" for your answer, you just say "what is 2+2" and the result just pops up."
//    },
//    "2" : {
//        "id" : "2",
//        "question" : "Who owns Flash?",
//        "answer" : "Flash is developed by our company Neurogram LLC. We are based out of Princeton, NJ USA and our founder is also a high school Junior (XI grade) just like all the other students who use Flash."
//    },
//    "3" : {
//        "id" : "3",
//        "question" : "How much does Flash cost to use?",
//        "answer" : "Flash is FREE to use by anyone and there will be no ads to distract our valuable users. We believe that when students are focused on studying, there should be no distractions. Hence when students are using Flash, there will be no ads to distract."
//    },
//    "4" : {
//        "id" : "4",
//        "question" : "How will our personal data be used?",
//        "answer" : "The only data we will be collecting for our app is your pre-existing google login credentials. We aspire to collect no additional data nor plan to use your data for any purpose. We value and are committed to your privacy."
//    },
//    "5" : {
//        "id" : "5",
//        "question" : "How does Flash work?",
//        "answer" : "Flash works in 2 simple ways – 1) by natural language by tapping the microphone icon and 2) by taking a picture by taping the scan icon. \nIn both cases you don’t need to key in any input."
//    },
//    "6" : {
//        "id" : "6",
//        "question" : "What type of calculations can Flash do?",
//        "answer" : "Flash can perform simple to advanced math operations just with your natural language. For ex. it can perform all types of simple operations, algebra, geometry, trigonometry, calculus, statistics and probability types of operations."
//    },
//    "7" : {
//        "id" : "7",
//        "question" : "How accurate and reliable are the results from Flash?",
//        "answer" : "Flash results are reliable and accurate. Our user design includes an effective verification of your speech-text-conversion in the output results. This step ensures that your speech query is captured accurately for getting accurate results. However, sometimes not all speech queries, complex queries or unclear queries are not effectively translated. In such cases you can manually type in the request to perform the operation."
//    },
//    "8" : {
//        "id" : "8",
//        "question" : "Can we share results with our friends or teachers?",
//        "answer" : "You sure can. Flash results can be shared either via email or text message easily and quickly with others. Just click on the share icon and select how you want to share."
//    },
//    "9" : {
//        "id" : "9",
//        "question" : "Can we see all previous operations on Flash?",
//        "answer" : "You sure can. All operations are saved in "History". You can select any historical operation to modify or share it at any time."
//    },
//    "10" : {
//        "id" : "10",
//        "question" : "What if my math question is not correctly captured by Flash? \nHow do I edit to modify or correct my questions?",
//        "answer" : "You can manually edit your input in Flash at any time. Just select the "Edit" icon on the right of Input field to edit your question."
//    },
//    "11" : {
//        "id" : "11",
//        "question" : "Can Flash be used to take a picture of my math problem to get answers?",
//        "answer" : "Yes. Now Flash has OCR (Optical Character Recognition) feature. Simply tap the "Scan" icon to take a picture of your math problem and Flash will give you results."
//    },
//    "12" : {
//        "id" : "12",
//        "question" : "How to use scan?",
//        "answer" : "Point the viewfinder to scan a picture of your math problem and Flash will display results. You can make sure that a full picture is captured by adjusting the scan viewfinder."
//    },
//    "13" : {
//        "id" : "13",
//        "question" : "Why are multiple results being displayed?",
//        "answer" : "The results displayed in Flash are represented in different versions but the same. For ex. results for some problems, results are represented numerically, graphically, pictorially, and in different formats to facilitate better understanding for users."
//    },
//    "14" : {
//        "id" : "14",
//        "question" : "Is there a way for me to see how to use Flash?",
//        "answer" : "Yes. There is a "Welcome" screen when you download Flash that shows examples of how to use. There is a "How to" section that shows YouTube videos on using Flash. Finally, there is a "Help" screen that has several FAQ’s on how to use Flash. These screens can also be accessed from the menu list Getting Started, How to, and Help respectively at any time."
//    },
//    "15" : {
//        "id" : "15",
//        "question" : "Do I need internet connection to use Flash?",
//        "answer" : "Yes, to download and use Flash you need a working internet connection. We recommend you use it mostly using Wi-Fi to avoid all costs."
//    },
//    "16" : {
//        "id" : "16",
//        "question" : "Can I see detailed steps of the results?",
//        "answer" : "Currently we display only results for your math problems. We are seriously looking at showing detailed steps soon."
//    },
//    "17" : {
//        "id" : "17",
//        "question" : "How can I change the language on Flash?",
//        "answer" : "Tap on the menu icon to select language. Then select the English language of your choice."
//    },
//    "18" : {
//        "id" : "18",
//        "question" : "How do I contact Flash?",
//        "answer" : "You can reach us at support@neurogramai.com at any time."
//    }
//}
