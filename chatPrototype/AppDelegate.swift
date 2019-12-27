//
//  AppDelegate.swift
//  chatPrototype
//
//  Created by Timur Kuashev on 03.12.2019.
//  Copyright © 2019 Timur Kuashev. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import GooglePlaces
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyBVTvU93ZrpjYOeVAzRVqO5oLpY7w0yXJc")
        GMSServices.provideAPIKey("AIzaSyBVTvU93ZrpjYOeVAzRVqO5oLpY7w0yXJc")

        self.window = UIWindow(frame: UIScreen.main.bounds)
        let nav1 = UINavigationController()
        
        // Autologin
        let startedViewController = (UserDefaults.standard.value(forKey: CustomPropertiesForUserDefaults.isSignIn) as? Bool) ==  true ? MainPageViewController(nibName: XibNameHelpers.mainPage, bundle: nil) : SignPage(nibName: XibNameHelpers.signPage, bundle: nil)
        
        nav1.viewControllers = [startedViewController]
        self.window?.rootViewController = nav1
        self.window?.makeKeyAndVisible()
        
        //get application instance ID
        InstanceID.instanceID().instanceID {
            (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                Database.database().reference().child(FirebaseTableNames.tokens).childByAutoId().setValue(["token": result.token])
            }
        }
        
        // Register the Push-notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            Database.database().reference().child(FirebaseTableNames.users).ref.updateChildValues([:])
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        guard let username = UserDefaults.standard.value(forKey: CustomPropertiesForUserDefaults.username) as? String, let id = FirebaseAuthService.getUserId() else {
            return
        }
        let data: Dictionary<String, String> = [
            "id": id,
            "status": "offline",
            "username": username
        ]
        Database.database().reference().child(FirebaseTableNames.users).child(id).setValue(data)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        let data: [String: String] = ["token": fcmToken]
        Database.database().reference().child(FirebaseTableNames.tokens).child(FirebaseAuthService.getUserId() ?? "Error, can't get user ID").setValue(data)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
}

