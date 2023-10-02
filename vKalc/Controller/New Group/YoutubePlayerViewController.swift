//
//  YoutubePlayerViewController.swift
//  vKalc
//
//  Created by Cis on 07/08/20.
//  Copyright © 2020 cis. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class YoutubePlayerViewController: BaseViewController {
    
    @IBOutlet weak var videoPlayerView: YTPlayerView!
    var data: HowToList?
    var videoId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let dict = ["modestbranding" : 0,"controls" : 1 ,"autoplay" : 1,"playsinline" : 1,"autohide" : 1,"showinfo" : 0]
        let dict = ["playsinline" : 1]
        videoPlayerView.load(withVideoId: videoId ,playerVars: dict)
        videoPlayerView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayerView.stopVideo()
    }
    
    deinit {
        print("\(self) deallocated successfully!!!!")
    }
}

extension YoutubePlayerViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        videoPlayerView.playVideo()
    }
}
