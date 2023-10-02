//
//  TextViewPlaceholder.swift
//  vKalc
//
//  Created by cis on 27/09/19.
//  Copyright © 2019 cis. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class OODTextView:UITextView {
    private var originalText: String = ""
    
    @IBInspectable var placeholder: String = "" {
        didSet{
            updatePlaceHolder()
        }
    }
    
    private func updatePlaceHolder() {
        if self.text == "" || self.text == placeholder {
            self.text = placeholder
            self.textColor = UIColor.lightGray
            self.originalText = ""
        } else {
            self.textColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1)
            self.originalText = self.text
        }
        
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if text == placeholder {
            self.text = self.originalText
        }
        self.textColor = #colorLiteral(red: 0.1607843137, green: 0.1607843137, blue: 0.1607843137, alpha: 1)
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updatePlaceHolder()
        return result
    }
}
