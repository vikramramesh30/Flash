//
//  HomeView.swift
//  vKalc
//
//  Created by cis on 16/08/19.
//  Copyright © 2019 cis. All rights reserved.
//

import Foundation
import UIKit

class HomeView: UIView {
    
    @IBOutlet weak var btn_zoomImage: UIButton!
    @IBOutlet var bottomSpaceconstraint: NSLayoutConstraint!
    @IBOutlet weak var imgViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var img_doubleArrow: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.function_init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.function_init()
    }
    
    func function_init() {
        Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth ]
    }
}
