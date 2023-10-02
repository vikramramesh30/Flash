//
//  CircleButton.swift
//  Pulsar
//
//  Created by Vincent Esche on 2/6/15.
//  Copyright (c) 2015 Vincent Esche. All rights reserved.
//

import UIKit

class CircleButton: UIButton {
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.layer.cornerRadius = CircleButton.cornerRadiusForRect(self.bounds)
        self.applyTheme()
    }
    
    class func cornerRadiusForRect(_ rect: CGRect) -> CGFloat {
        return min(rect.width, rect.height) / 2.0
    }
}
extension UIButton {
    func applyTheme() {
        /*
         let fillColor = UIColor(white: 0.0, alpha: 0.25).cgColor
         let borderColor = UIColor(white: 1.0, alpha: 1.0).cgColor
         if let shapeLayer = self.layer as? CAShapeLayer {
         // shapeLayer.fillColor = fillColor
         // shapeLayer.strokeColor = borderColor
         //  shapeLayer.lineWidth = 3.0
         } else {
         //   layer.backgroundColor = fillColor
         //   layer.borderColor = borderColor
         //  layer.borderWidth = 3.0
         }
         */
    }
}
