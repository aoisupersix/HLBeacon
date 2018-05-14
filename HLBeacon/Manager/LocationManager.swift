//
//  LocationManager.swift
//  HLBeacon
//
//  Created by aoisupersix on 2018/04/14.
//

import CoreLocation
import UserNotifications

/// 位置情報関連の処理を行うクラス
class LocationManager: CLLocationManager {
    
    /// 研究室ビーコン発信機のUUID
    static let BEACON_UUID = UUID(uuidString: "2F0B0D9B-B52C-47BF-B5B8-2BFBCE094653")!
    /// 研究室のビーコン識別子
    static let BEACON_IDENTIFIER = "tokyo.aoisupersix.beacon"
    
    /// 学内ジオフェンスの中心緯度経度
    static let GEOFENCE_COORDINATE = CLLocationCoordinate2DMake(35.626514, 139.279283)
    /// 学内ジオフェンスの識別子
    static let GEOFENCE_IDENTIFIER = "tokyo.aoisupersix.campus"

    /// LocationManagerのインスタンス
    private static let sharedInstance = LocationManager()
    
    /// 研究室のビーコン領域
    static let beaconRegion = CLBeaconRegion(proximityUUID: LocationManager.BEACON_UUID, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: LocationManager.BEACON_IDENTIFIER)
    /// 学内のジオフェンス領域
    static let moniteringRegion = CLCircularRegion.init(center: LocationManager.GEOFENCE_COORDINATE, radius: 400.0, identifier: LocationManager.GEOFENCE_IDENTIFIER)
    
    /// 研究室のビーコン領域に侵入しているかどうかを表すフラグ
    static var isEnterBeaconRegion = false
    /// 学内のジオフェンス領域に侵入しているかを表すフラグ
    static var isEnterGeofenceRegion = false
    /// 研究室ビーコン発信機からの信号受信強度
    static var rssi: Int?
    
    /// ユーザに位置情報利用の許可を確認します
    static func requestAlwaysAuthorization() {
        //バックグランドでも位置情報更新をチェックする
        sharedInstance.allowsBackgroundLocationUpdates = true
        sharedInstance.delegate = sharedInstance
        sharedInstance.requestAlwaysAuthorization()
    }
}

/// LocationManagerの通知関係の処理
extension LocationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //フォアグラウンドでも通知を受け取る
        completionHandler([.alert, .sound])
    }
}


/// LocationManagerの位置情報関係の処理
extension LocationManager: CLLocationManagerDelegate {
    
    /// 位置情報の観測が開始された際の処理
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Start monitoring for \(region.identifier)")
        manager.requestState(for: region)
    }
    
    /// 位置情報利用の認証状態が変わった際の処理
    /// 位置情報の観測を開始させます。
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            //iBeacon領域判定の有効化
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                LocationManager.beaconRegion.notifyEntryStateOnDisplay = false
                LocationManager.beaconRegion.notifyOnEntry = true
                LocationManager.beaconRegion.notifyOnExit = true
                manager.startMonitoring(for: LocationManager.beaconRegion)
            }
            //学内領域判定の有効化
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                manager.startMonitoring(for: LocationManager.moniteringRegion)
            }
        }
    }
    
    /// 領域に侵入した際の処理
    /// 研究室ビーコン領域であれば状態を在室に更新し、学内領域であれば状態を学内に更新します。
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //研究室領域の判定
        if region.identifier == LocationManager.BEACON_IDENTIFIER {
            print("Enter Beacon Region")
            if !LocationManager.isEnterBeaconRegion {
                //研究室領域に侵入
                LocationManager.isEnterBeaconRegion = true
                //sendStatus(status: PresenseStatus.PRESENSE)
                sendNotification(title: "研究室領域に侵入", body: "ステータスを「在室」に更新しました。")
            }
        //学内領域の判定
        } else if region.identifier == LocationManager.GEOFENCE_IDENTIFIER {
            print("Enter Geofence Region")
            if !LocationManager.isEnterBeaconRegion && !LocationManager.isEnterGeofenceRegion {
                //学内領域に侵入
                LocationManager.isEnterGeofenceRegion = true
                //sendStatus(status: PresenseStatus.IN_CAMPUS)
                sendNotification(title: "学内領域に侵入", body: "ステータスを「学内」に更新しました。")
            }
        }
    }
    
    /// 領域から離れた際の処理
    /// 研究室ビーコン領域からの退出であれば状態を学内に更新し、学内領域からの退出であれば状態を帰宅に更新します。
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //研究室領域の判定
        if region.identifier == LocationManager.BEACON_IDENTIFIER {
            print("Exit Beacon Region")
            if LocationManager.isEnterBeaconRegion {
                LocationManager.isEnterBeaconRegion = false
                //sendStatus(status: PresenseStatus.IN_CAMPUS)
                sendNotification(title: "研究室領域から退出", body: "ステータスを「学内」に更新しました。")
            }
        }else if region.identifier == LocationManager.GEOFENCE_IDENTIFIER {
            print("Exit GeoFence Region")
            if LocationManager.isEnterGeofenceRegion {
                LocationManager.isEnterGeofenceRegion = false
                //sendStatus(status: PresenseStatus.GOING_HOME)
                sendNotification(title: "学内領域から退出", body: "ステータスを「帰宅」に更新しました。")
            }
        }
    }
    
    /// ステータス情報を在室管理サーバに投げます。
    /// - parameter status: 更新するステータス値
    private func sendStatus(status: PresenseStatus) {
        let userData = RealmUserDataManager().getData()
        if userData.slackUserId == "-1" || userData.hId == "-1" {
            //ユーザ情報不足のため送信不可
            return
        }
        let url = URL(string: "https://script.google.com/macros/s/AKfycbwtEGgAOQ6LA3rcvsLcQFrrg8uVE1v5lkg8eNn40YjwAASTwmc/exec")
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let params: [[String: String]] = [[
            "id": userData.hId,
            "status": status.rawValue.description,
            "slackId": userData.slackUserId
            ]]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            URLSession.shared.dataTask(with: request) { data, response, err in
                if err != nil {
                    print("SLACK-USERS-GET: Failed")
                    return;
                }
                print("SLACK-USERS-GET: Success")
                print(data!)
                }.resume()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    /// ユーザにプッシュ通知を送信します。
    /// - parameter title: プッシュ通知のタイトル
    /// - parameter body: プッシュ通知の本文
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "LocationNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)

    }
}
