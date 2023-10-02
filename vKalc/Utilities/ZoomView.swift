//
//  ZoomView.swift
//  vKalc
//
//  Created by cis on 06/09/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
import ZoomableUIView

class ZoomableView:UIView {
    
}


extension ZoomableView:ZoomableUIView {
    func viewForZooming() -> UIView {
        return self
    }
    
    func optionsForZooming() -> ZoomableViewOptions {
        return ZoomableViewOptions.init(minZoom: 1, maxZoom: 3.5)
    }
}
