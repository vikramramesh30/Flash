//
//  Extension.swift
//  vKalc
//
//  Created by cis on 15/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setStatusBarColor(color:UIColor){
        if let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView {
            statusBar.backgroundColor = color
            
        } else {  }
    }
    func func_AlertWithTwoOption(message:String, optionOne:String, optionTwo:String, actionOne:@escaping ()->Void, actionTwo:@escaping ()->Void) {
        let alert = UIAlertController.init(title: "Flash", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: optionOne, style: .default, handler: { (action) in
            actionOne()
        }))
        alert.addAction(UIAlertAction.init(title: optionTwo, style: .default, handler: { (action) in
            actionTwo()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIColor {
    convenience init(r: CGFloat, g:CGFloat, b:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension UIView {
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect! ).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
extension Date {
    func currentTimeMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
}

extension DateFormatter {
    
    static var sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        // Add your formatter configuration here
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
        return dateFormatter
    }()
}
class CustomTextField: UITextField
{
    fileprivate let cancelButtonLength: CGFloat = 17
    fileprivate let padding: CGFloat = 5
    
    
    override init( frame: CGRect )
    {
        super.init( frame: frame )
        self.customLayout()
    }
    
    required init?( coder aDecoder: NSCoder )
    {
        super.init( coder: aDecoder )
        self.customLayout()
    }

    override func rightViewRect( forBounds bounds: CGRect ) -> CGRect
    {
        let x = bounds.size.width - self.cancelButtonLength - self.padding
        let y = ( bounds.size.height - self.cancelButtonLength ) / 2
        let rightBounds = CGRect( x: x, y: y, width: self.cancelButtonLength, height: self.cancelButtonLength )
        return rightBounds
    }
    
    fileprivate func customLayout()
    {
        // Set custom clear button on right side
        let clearButton = UIButton()
        clearButton.setImage( UIImage( named: "cancel" ), for: .normal )
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget( self, action: #selector( self.clearClicked ), for: .touchUpInside )
        self.rightView = clearButton
        self.clearButtonMode = .never
        self.rightViewMode = .whileEditing
    }
    
    @objc fileprivate func clearClicked( sender: UIButton )
    {
        self.text = ""
    }
}

class MessageWithSubject: NSObject, UIActivityItemSource {
    
    let subject:String
    let message:String
    
    init(subject: String, message: String) {
        self.subject = subject
        self.message = message
        
        super.init()
    }
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == . mail {
            return ""
        } else {
            return message
        }
    }
    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
            return subject
    }
}
