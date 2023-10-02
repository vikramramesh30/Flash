//
//  ImageSlider.swift
//  vKalc
//
//  Created by cis on 21/08/19.
//  Copyright © 2019 cis. All rights reserved.
//

import Foundation
import UIKit
class ImageSlider :UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollview: UIScrollView!
    private var minimumZoomScale:CGFloat = 1.0
    private var maximumZoomScale:CGFloat = 6.0
    var url = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(self.fuction_HandleTapGesture(_:)))
        gesture.numberOfTapsRequired = 2
        self.scrollview.addGestureRecognizer(gesture)
        self.scrollview.delegate = self
        self.scrollview.minimumZoomScale = minimumZoomScale
        self.scrollview.maximumZoomScale  = maximumZoomScale
        if let url = URL(string: url){
            imageView.pin_updateWithProgress = true
            imageView.pin_setImage(from: url)
        }
    }
   
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    @objc func fuction_HandleTapGesture(_ sender:UITapGestureRecognizer) {
        if self.scrollview.zoomScale == minimumZoomScale {
            self.scrollview.setZoomScale(maximumZoomScale, animated: true)
        } else {
            self.scrollview.setZoomScale(minimumZoomScale, animated: true)
        }
    }
    
    @IBAction func action_close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
