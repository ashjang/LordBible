//
//  SceneDelegate.swift
//  Bible
//
//  Created by 장하림 on 2022/10/06.
//

import UIKit
import FirebaseDatabase
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        
        triggerLocalNotificationMorning()
    }


}


extension SceneDelegate {
    
    private func triggerLocalNotificationMorning() {
        let content = UNMutableNotificationContent()
        let content2 = UNMutableNotificationContent()
        content.title = "Lord's Bible"
        content.sound = .default
        content2.title = "Lord's Bible"
        content2.sound = .default
        
        let date = Date()
        let month = Calendar.current.dateComponents([.month], from: date)
        let day = Calendar.current.dateComponents([.day], from: date)
//        let hour = Calendar.current.dateComponents([.hour], from: date)         // Int형
//        let minute = Calendar.current.dateComponents([.minute], from: date)     // Int형
        
        var dateComponentMorning = DateComponents()
        dateComponentMorning.hour = 8
        dateComponentMorning.minute = 30
        let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateComponentMorning, repeats: true)
        
        var dateComponentEvening = DateComponents()
        dateComponentEvening.hour = 22
        dateComponentEvening.minute = 0
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponentEvening, repeats: true)
        
        let ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("randomWord").child("KJV흠정역").child("\(month.month! - 1)").child("\(day.day!)").observe(.value) { [weak self] snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
            content.subtitle = "\((value["address"]! as! String).localized()) \(value["chapter"]!):\(value["verse"]!)"
            content.body = "\(value["word"]!)"
            content2.subtitle = "\((value["address"]! as! String).localized()) \(value["chapter"]!):\(value["verse"]!)"
            content2.body = "\(value["word"]!)"
            
            let sharedDefaults = UserDefaults(suiteName: "group.com.Harim.Lordwords")
            sharedDefaults?.setValue(content.subtitle, forKey: "smallWidgetAddress")
            sharedDefaults?.setValue(content.body, forKey: "smallWidgetWord")
            WidgetCenter.shared.reloadAllTimelines()
            
            let localRequestMorning = UNNotificationRequest(identifier: "morningAlarm", content: content, trigger: trigger1)
            let localRequestEvening = UNNotificationRequest(identifier: "eveningAlarm", content: content, trigger: trigger2)

            UNUserNotificationCenter.current().add(localRequestMorning) { (error) in
                if let error = error {
                    print("Error:", error.localizedDescription )
                } else {
                    NSLog("Notification scheduled")
                }
            }
            UNUserNotificationCenter.current().add(localRequestEvening) { (error) in
                if let error = error {
                    print("Error:", error.localizedDescription )
                } else {
                    NSLog("Notification scheduled")
                }
            }
        }
//        content.subtitle = "Good Morning ☀️"
//        content.body = 
//        content2.subtitle = "Good Night 🌝"
//        content2.body = "오늘 하루 수고 많았어요. 기도와 말씀으로 하루의 마무리를 지어보세요 :)"
        
//        let localRequestMorning = UNNotificationRequest(identifier: "morningAlarm", content: content, trigger: trigger1)
//        let localRequestEvening = UNNotificationRequest(identifier: "eveningAlarm", content: content2, trigger: trigger2)
//
//        UNUserNotificationCenter.current().add(localRequestMorning) { (error) in
//            if let error = error {
//                print("Error:", error.localizedDescription )
//            } else {
//                NSLog("Notification scheduled")
//            }
//        }
//        UNUserNotificationCenter.current().add(localRequestEvening) { (error) in
//            if let error = error {
//                print("Error:", error.localizedDescription )
//            } else {
//                NSLog("Notification scheduled")
//            }
//        }
    }
    
}
