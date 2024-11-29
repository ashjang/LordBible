//
//  AppDelegate.swift
//  Bible
//
//  Created by 장하림 on 2022/10/06.
//

import UIKit
import Firebase
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound]
        FirebaseApp.configure()
        UNUserNotificationCenter.current().requestAuthorization(options: options) { _, error in
            if let error = error {
                print("ERROR: notification authorization request \(error.localizedDescription)")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Usernotification didReceive: \(response)")
        completionHandler()
    }
    
//    func generateNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = wordAddress!
//        content.body = wordText!
//        content.sound = UNNotificationSound.default
//
//        var date = DateComponents()
//        date.hour = 8
//        date.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
//        let identifier = "morning Notification"
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { (error) in
//            if error != nil {
//                print(error?.localizedDescription)
//            }
//        }
//    }
}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//
//    func generateNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = todayWord.text!
//        content.body = todayWordText.text!
//        content.sound = UNNotificationSound.default
//
//        var date = DateComponents()
//        date.hour = 8
//        date.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
//        let identifier = "morning Notification"
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.add(request) { (error) in
//            if error != nil {
//                print(error?.localizedDescription)
//            }
//        }
//    }
//}
