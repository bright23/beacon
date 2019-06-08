//
//  ViewController.swift
//  BeaconDemo
//
//  Created by wata on 2015/10/06.
//  Copyright © 2015年 wataru All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var minor: UILabel!
    @IBOutlet weak var accuracy: UILabel!
    @IBOutlet weak var rssi: UILabel!
    
    //UUIDカラNSUUIDを作成 (本当はbeaconのUUID)
//    var proximityUUID: UUID!
//    var region: CLBeaconRegion!
    var manager: BeaconManager = BeaconManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        manager = CLLocationManager()
//        manager.delegate = self
////        e2c56db5-dffb-48d2-b060-d0f5a71096e0
//        proximityUUID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
//
//        region = CLBeaconRegion(proximityUUID:proximityUUID,identifier:"EstimoteRegion")
        
        /*
        位置情報サービスへの認証状態を取得する
        NotDetermined   --  アプリ起動後、位置情報サービスへのアクセスを許可するかまだ選択されていない状態
        Restricted      --  設定 > 一般 > 機能制限により位置情報サービスの利用が制限中
        Denied          --  ユーザーがこのアプリでの位置情報サービスへのアクセスを許可していない
        Authorized      --  位置情報サービスへのアクセスを許可している
        */
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            //iBeaconによる領域観測を開始する
            print("観測開始")
            self.status.text = "Starting Monitor"
        case .notDetermined:
            print("許可承認")
            self.status.text = "Starting Monitor"
            //デバイスに許可を促す
            manager.locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            //デバイスから拒否状態
            print("Restricted")
            self.status.text = "Restricted Monitor"
        }
    }

    //以下 CCLocationManagerデリゲートの実装---------------------------------------------->
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
    Parameters
    manager : The location manager object reporting the event.
    region  : The region that is being monitored.
    */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region)
        self.status.text = "Scanning..."
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
    Parameters
    manager :The location manager object reporting the event.
    state   :The state of the specified region. For a list of possible values, see the CLRegionState type.
    region  :The region whose state was determined.
    */
//    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
//        if (state == .inside) {
//            //領域内にはいったときに距離測定を開始
//            manager.startRangingBeacons(in: region)
//        }
//    }
    
    /*
    リージョン監視失敗（bluetoosの設定を切り替えたりフライトモードを入切すると失敗するので１秒ほどのdelayを入れて、再トライするなど処理を入れること）
    - (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
    Parameters
    manager : The location manager object reporting the event.
    region  : The region for which the error occurred.
    error   : An error object containing the error code that indicates why region monitoring failed.
    */
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("monitoringDidFailForRegion \(error)")
        self.status.text = "Error :("
    }
    
    /*
    - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
    Parameters
    manager : The location manager object that was unable to retrieve the location.
    error   : The error object containing the reason the location or heading could not be retrieved.
    */
    //通信失敗
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        self.status.text = "Possible Match"
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        reset()
    }
    
    /*
    beaconsを受信するデリゲートメソッド。複数あった場合はbeaconsに入る
    - (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
    Parameters
    manager : The location manager object reporting the event.
    beacons : An array of CLBeacon objects representing the beacons currently in range. You can use the information in these objects to determine the range of each beacon and its identifying information.
    region  : The region object containing the parameters that were used to locate the beacons
    */
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        print(beacons)
        
        if(beacons.count == 0) { return }
        //複数あった場合は一番先頭のものを処理する
        let beacon = beacons[0] 
        print(beacon.accuracy)
        /*
        beaconから取得できるデータ
        proximityUUID   :   regionの識別子
        major           :   識別子１
        minor           :   識別子２
        proximity       :   相対距離
        accuracy        :   精度
        rssi            :   電波強度
        */
        self.distance.text = "\(beacon.accuracy)"
        if (beacon.proximity == CLProximity.unknown) {
            self.distance.text = "Unknown Proximity"
            self.distance.textColor = UIColor.black
            reset()
            return
        } else if (beacon.proximity == CLProximity.immediate) {
            self.distance.textColor = UIColor.red
            
            if SingleAlert.sharedInstance.alertFlg == false {
                SingleAlert.sharedInstance.alertFlg = true
                let alertController = UIAlertController(title: "藤原呉服店です！", message: "今日は半額セールです！！", preferredStyle: .alert)
                let otherAction = UIAlertAction(title: "OK", style: .default) {
                    action in
//                    SingleAlert.sharedInstance.alertFlg = false
                }
//                let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
//                    action in
//                    println("Pushed CANCEL!")
//                }
                
                alertController.addAction(otherAction)
//                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
                
            }
            
            
        } else if (beacon.proximity == CLProximity.near) {
            self.distance.textColor = UIColor.green
            
        } else if (beacon.proximity == CLProximity.far) {
            
            self.distance.textColor = UIColor.blue
        }
        self.status.text   = "status::OK"
        self.uuid.text     = "udid" + beacon.proximityUUID.uuidString
        self.major.text    = "識別子1:::\(beacon.major)"
        self.minor.text    = "識別子2:::\(beacon.minor)"
        self.accuracy.text = "精度:::\(beacon.accuracy)"
        self.rssi.text     = "電波強度:::\(beacon.rssi)"
    }
    
    func reset(){
        self.status.text   = "none"
        self.uuid.text     = "none"
        self.major.text    = "none"
        self.minor.text    = "none"
        self.accuracy.text = "none"
        self.rssi.text     = "none"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendNoti() {
        
    }

    
    

}

