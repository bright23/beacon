//
//  AppDelegate.swift
//  BeaconDemo
//
//  Created by wata on 2015/10/06.
//  Copyright © 2015年 wataru All rights reserved.
//

import UIKit
import UserNotifications

//https://dev.classmethod.jp/smartphone/iphone/ios-7-1-ibeacon/
class AppDelegate: UIResponder, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var backgroundTaskID : UIBackgroundTaskIdentifier = 0
//    typealias UIBackgroundTaskIdentifier = Int

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BeaconManager.shared.startMonitoring()
        return true
    }
    
    func setupNoti()  {
        // notification center (singleton)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // request to notify for user
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Allowed")
            } else {
                print("Didn't allowed")
            }
        }
    }
    
    // バックグラウンド遷移移行直前に呼ばれる
    func applicationWillResignActive(_ application: UIApplication) {
        self.backgroundTaskID = application.beginBackgroundTask(expirationHandler: {
            [weak self] in
            application.endBackgroundTask((self?.backgroundTaskID)!)
            self?.backgroundTaskID = UIBackgroundTaskInvalid
        })
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }

    
    func applicationDidEnterBackground(_ application: UIApplication) {
//        //ローカル通知
//        let notification = UILocalNotification()
//        notification.alertAction = "アプリを開く"
//        //通知の本文
//        notification.alertBody = "みっけ！"
//        notification.fireDate = Date(timeIntervalSinceNow:10)
//        //通知音
//        notification.soundName = UILocalNotificationDefaultSoundName
//        //アインコンバッジの数字
//        notification.applicationIconBadgeNumber = 1
//        //通知を識別するID
//        notification.userInfo = ["notifyID":"gohan"]
//        //通知をスケジューリング
//        application.scheduleLocalNotification(notification)
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

