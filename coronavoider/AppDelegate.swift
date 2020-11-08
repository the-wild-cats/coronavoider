//
//  AppDelegate.swift
//  coronavoider
//
//  Created by Dimitrie-Toma Furdui on 07/11/2020.
//

import UIKit
import UserNotifications
import CoreLocation
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        UserDefaults.standard.dictionaryRepresentation().keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { didAllow, error in }
        
        self.locationManager.requestAlwaysAuthorization()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "loading")
        self.window?.makeKeyAndVisible()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let initialViewController: UIViewController
            if ["lat", "long", "radius"].map({ UserDefaults.standard.object(forKey: $0) != nil }).contains(false) {
                initialViewController = storyboard.instantiateViewController(identifier: "selectLocation")
            } else {
                initialViewController = storyboard.instantiateViewController(identifier: "main")
            }
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            UIView.transition(with: self.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {})
        }
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
}
