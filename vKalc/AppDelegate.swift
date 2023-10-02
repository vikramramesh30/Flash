//
//  AppDelegate.swift
//  vKalc
//
//  Created by cis on 12/04/19.
//  Copyright © 2019 cis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // application.statusBarStyle = .lightContent
        let navigationBarAppearace = UINavigationBar.appearance()
        let image = #imageLiteral(resourceName: "Back-button") //put your image here
        let backButtonImage = image.withRenderingMode(.alwaysOriginal)
        navigationBarAppearace.backIndicatorImage = backButtonImage
        navigationBarAppearace.backIndicatorTransitionMaskImage = backButtonImage
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = UIColor(r: 25, g: 25, b: 25)
        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)
        GIDSignIn.sharedInstance().clientID = "170425485227-o14glgthnghug23frspobmb0onbtoq0r.apps.googleusercontent.com"//"554724093157-hr97gm9k7cosg9nrd74b0qsqp611oole.apps.googleusercontent.com"//
        
        ///
        GIDSignIn.sharedInstance().delegate = self
        FirebaseApp.configure()
       // Database.database().isPersistenceEnabled = true
//        let settings = FirestoreSettings()
//        //        settings.isPersistenceEnabled = false
//        //        db.settings = settings
//                
//                //Connect to database
//                db = Firestore.firestore()
        
        
        
        
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (Constants.userDefault.object(forKey: Constants.isWalkedThrough) != nil) {
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            let navigation = UINavigationController(rootViewController: signInVC)
            self.window?.rootViewController = navigation
        }else{
            let gettingStartedVC = storyboard.instantiateViewController(withIdentifier: "GettingStartedViewController") as! GettingStartedViewController
            gettingStartedVC.type = .start
            let navigation = UINavigationController(rootViewController: gettingStartedVC)
            self.window?.rootViewController = navigation
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
            // [START_EXCLUDE silent]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
            // [END_EXCLUDE]
        } else {
            // Perform any operations on signed in user here.
            _ = user.userID
            _ = user.authentication.idToken
            let fullName = user.profile.name
            _ = user.profile.givenName
            _ = user.profile.familyName
            _ = user.profile.email
            // [START_EXCLUDE]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: nil,
                userInfo: ["statusText": "Signed in user:\n\(String(describing: fullName))"])
            // [END_EXCLUDE]
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // [START_EXCLUDE]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
        // [END_EXCLUDE]
    }
}

//For CiS
//com.googleusercontent.apps.554724093157-hr97gm9k7cosg9nrd74b0qsqp611oole

//For Original
//com.googleusercontent.apps.170425485227-o14glgthnghug23frspobmb0onbtoq0r
