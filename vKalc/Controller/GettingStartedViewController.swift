//
//  GettingStartedViewController.swift
//  vKalc
//
//  Created by Cis on 05/08/20.
//  Copyright © 2020 cis. All rights reserved.
//

import UIKit
import AVFoundation

extension UIView {
    func addRoundedShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius / 2.0
        self.layer.shouldRasterize = true
        self.layer.masksToBounds = false
    }
}

struct Constants {
    static let isWalkedThrough = "isWalkedThrough"
    static let userDefault = UserDefaults.standard
    static let url = "yoursite.com"
    static let param = "status"
}

enum Walkthrough {
    case start
    case home
}

struct VideoInfo {
    let videoId: Int
    let videoName: String
    let viewName: UIView
}

enum Music {
    case mathQuestion
    case mathProblems
    case differentOptions
    case ocr
    
    var value: String {
        switch self {
        case .mathQuestion: return "Math Question"
        case .mathProblems: return "Math Problems"
        case .differentOptions: return "Different Options"
        case .ocr: return ""
        }
    }
}

class GettingStartedViewController: UIViewController {
    
    @IBOutlet weak var scrollViewContent: UIScrollView!
    @IBOutlet weak var viewFirst: UIView!
    @IBOutlet weak var viewSecond: UIView!
    @IBOutlet weak var viewThird: UIView!
    // @IBOutlet weak var viewFourth: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var buttonSkip: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    
    var type: Walkthrough = .start
    var array: [VideoInfo] = []
    var player : AVPlayer? = nil
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [buttonSkip, buttonNext].forEach{
            $0?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        }
        
        // self.viewFirst.addRoundedShadow(offset: CGSize(width: 0.0, height: 3.0), color: UIColor.green, radius: 8.0, opacity: 1.0)
        
        array = [
            VideoInfo(videoId: 1, videoName: Music.mathQuestion.value, viewName: viewFirst),
            VideoInfo(videoId: 2, videoName: Music.mathProblems.value, viewName: viewSecond),
            VideoInfo(videoId: 3, videoName: Music.differentOptions.value, viewName: viewThird)
            // VideoInfo(videoId: 4, videoName: Music.ocr.value, viewName: viewFourth)
        ]
        
        scrollViewContent.isPagingEnabled = true
        pageControl.numberOfPages = array.count
        scrollViewContent.contentInsetAdjustmentBehavior = .never
        self.buttonNext.setTitle("NEXT", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        abc(status: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.stopPlayer()
        }
    }
    
    deinit {
        print("\(self) deallocated successfully")
    }
    
    func stopPlayer() {
        if player != nil {
            self.player!.replaceCurrentItem(with: nil)
            self.player!.pause()
            self.player = nil //Assign nil to player destroy player object
            self.playerLayer.removeFromSuperlayer()
        }
    }
    
    private func playVideo(_ view: UIView, videoName: String, pageNumber: Int) {
        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: path))
        if player != nil {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = view.bounds
            //  playerLayer.videoGravity = .resizeAspectFill
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem, queue: .main) { [weak self](note) in
                guard let self = self else { return }
                // player.seek(to: CMTime.zero)
                DispatchQueue.main.async {
                    self.stopPlayer()
                    NotificationCenter.default.removeObserver(self)
                    self.abc(pageNumber + 1, status: 0)
                }
            }
            view.layer.addSublayer(playerLayer)
            player!.play()
        }
    }
    
    // MARK: - ---- Button Action ----
    
    @objc func buttonPressed(_ sender: UIButton) {
        if sender == buttonSkip {
            if type == .start {
                Constants.userDefault.set(true, forKey: Constants.isWalkedThrough)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else if sender == buttonNext {
            let page = scrollViewContent.contentOffset.x / scrollViewContent.frame.size.width
            let pageNumber = Int(page)
//            if pageNumber == 2 {
//                if type == .start {
//                    Constants.userDefault.set(true, forKey: Constants.isWalkedThrough)
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }else{
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }else{
                self.stopPlayer()
                self.abc(pageNumber + 1, status: 1)
//            }
        }
    }
    
    @IBAction func changePageControlPage(_ sender: AnyObject) {
//           let x = CGFloat(pageControl.currentPage) * scrollWalkThrough.frame.size.width
//           scrollWalkThrough.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
}

extension GettingStartedViewController : UIScrollViewDelegate {
    
    // MARK: - Scroll View Delegate
    // MARK: -
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.stopPlayer()
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        let pageNumber = Int(page)
        self.abc(pageNumber, status: 1)
    }
    
    func abc(_ pageNumber: Int = 0, status: Int) {
        //if pageNumber == 4 {
        
        if pageNumber == 3 {
            if self.type == .start {
                Constants.userDefault.set(true, forKey: Constants.isWalkedThrough)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            pageNumber == 2 ? self.buttonNext.setTitle("DONE", for: .normal) : self.buttonNext.setTitle("NEXT", for: .normal)
            let data = array[pageNumber]
            self.pageControl.currentPage = pageNumber
            if data.videoName != "" {
                self.scrollViewContent.contentOffset = CGPoint(x: (self.scrollViewContent.frame.size.width * CGFloat(pageNumber)), y: 0.0)
                self.playVideo(data.viewName, videoName: data.videoName, pageNumber: pageNumber)
            }
        }
    }
}
