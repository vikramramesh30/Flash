//
//  SignInViewController.swift
//  vKalc
//
//  Created by cis on 12/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseDatabase
import AuthenticationServices

class SignInViewController: BaseViewController, GIDSignInDelegate{
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewBtnContainer: UIView!
    @IBOutlet weak var bg_view: UIView!
    @IBOutlet weak var btn_bgView: UIView!
    var isViewPresented:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.btn_bgView.layer.cornerRadius = 8//btn_bgView.frame.height/2
        if #available(iOS 13.0, *) {
            let btn = ASAuthorizationAppleIDButton()
            btn.frame = viewBtnContainer.frame
            btn.layer.cornerRadius = 8//btn.frame.height/2
            btn.addTarget(self, action: #selector(self.actionSignInwithApple), for: .touchUpInside)
            self.stackView.addArrangedSubview(btn)
            //self.viewBtnContainer.addSubview(btn)
        } else {
            // Fallback on earlier versions
        }
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if self.isViewPresented {
            LoadingIndicator.sharedInstance.showActivityIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                LoadingIndicator.sharedInstance.hideActivityIndicator()
            })
        } else {
            if UserDefaults.standard.value(forKey: "USERID") == nil {
                self.bg_view.isHidden = true
            } else {
                let homeVC = storyboard?.instantiateViewController(withIdentifier: "NewHomeViewController") as! NewHomeViewController
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        LoadingIndicator.sharedInstance.hideActivityIndicator()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        print(user.userID ?? "")
        if let uid = user.userID {
            UserDefaults.standard.set(uid, forKey: "USERID")
        }
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            let homeVC:NewHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewHomeViewController") as! NewHomeViewController
            self.isViewPresented = false
            LoadingIndicator.sharedInstance.hideActivityIndicator()
            self.navigationController?.pushViewController(homeVC, animated: true)
            print("sign in")
            
            
        }
        
    }
    
    @objc func actionSignInwithApple() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
        
    }
    @IBAction func action_signIn(_ sender: Any) {
        self.isViewPresented = true
        //LoadingIndicator.sharedInstance.showActivityIndicator()
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
}
extension SignInViewController: ASAuthorizationControllerDelegate {
    
    // ASAuthorizationControllerDelegate function for authorization failed
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // ASAuthorizationControllerDelegate function for successful authorization
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Create an account as per your requirement
            let appleId = appleIDCredential.user
            let id = appleId.replacingOccurrences(of: ".", with: "")
            let appleUserEmail = appleIDCredential.email
            let appleUserFirstName = appleIDCredential.fullName?.givenName
            UserDefaults.standard.set(id, forKey: "USERID")
            UserDefaults.standard.set(appleUserEmail, forKey: "EMAIL")
            UserDefaults.standard.set(appleUserFirstName, forKey: "NAME")
            let homeVC:NewHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewHomeViewController") as! NewHomeViewController
            self.isViewPresented = false
            LoadingIndicator.sharedInstance.hideActivityIndicator()
            self.navigationController?.pushViewController(homeVC, animated: true)
            print("sign in")
            
            //            let appleUserLastName = appleIDCredential.fullName?.familyName
            //
            //Write your code
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            let appleId = passwordCredential.user
            
            UserDefaults.standard.set(appleId, forKey: "USERID")
            let homeVC:NewHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewHomeViewController") as! NewHomeViewController
            self.isViewPresented = false
            LoadingIndicator.sharedInstance.hideActivityIndicator()
            self.navigationController?.pushViewController(homeVC, animated: true)
            print("sign in")
            //            let appleUsername = passwordCredential.user
            //            let applePassword = passwordCredential.password
            //Write your code
        }
    }
    
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    //For present window
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
