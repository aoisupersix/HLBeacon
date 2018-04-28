//
//  LocationManager.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/14.
//

import CoreLocation
import UserNotifications

///位置情報関連の処理を行うクラス
class LocationManager: CLLocationManager {
    
    static let BEACON_UUID = UUID(uuidString: "2F0B0D9B-B52C-47BF-B5B8-2BFBCE094653")!
    static let BEACON_IDENTIFIER = "tokyo.aoisupersix"

    private static let sharedInstance = LocationManager()
    
    static let beaconRegion = CLBeaconRegion(proximityUUID: LocationManager.BEACON_UUID, major: CLBeaconMajorValue(1), minor: CLBeaconMinorValue(1), identifier: LocationManager.BEACON_IDENTIFIER)
    static var isEnterRegion: Bool = false
    static var rssi: Int?
    
    static func requestAlwaysAuthorization() {
        //バックグランドでも位置情報更新をチェックする
        sharedInstance.allowsBackgroundLocationUpdates = true
        sharedInstance.delegate = sharedInstance
        sharedInstance.requestAlwaysAuthorization()
    }
}

extension LocationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //フォアグラウンドでも通知を受け取る
        completionHandler([.alert, .sound])
    }
}


extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Start monitoring for region")
        manager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                LocationManager.beaconRegion.notifyEntryStateOnDisplay = false
                LocationManager.beaconRegion.notifyOnEntry = true
                LocationManager.beaconRegion.notifyOnExit = true
                manager.startMonitoring(for: LocationManager.beaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if !LocationManager.isEnterRegion {
            print("Enter Region")
            LocationManager.isEnterRegion = true
            sendEnterNotify(title: "Enter Region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for b in beacons {
            if b.proximityUUID == LocationManager.BEACON_UUID {
                LocationManager.rssi = b.rssi
                print("RSSI:\(b.rssi),Proximity:\(b.proximity.rawValue)")
                //受信対象のBeacon
                if b.proximity == CLProximity.unknown && LocationManager.isEnterRegion {
                    print("Far Exit Region")
                    LocationManager.isEnterRegion = false
                    sendExitNotify(title: "Exit Far Distance Region")
                }else if !LocationManager.isEnterRegion {
                    print("Enter Near Region")
                    LocationManager.isEnterRegion = true
                    sendEnterNotify(title: "Enter Near Region")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case CLRegionState.inside:
            if !LocationManager.isEnterRegion {
                print("Inside Region")
                LocationManager.isEnterRegion = true
                sendEnterNotify(title: "Inside Region")
                //manager.startRangingBeacons(in: LocationManager.beaconRegion)
            }
            break
        case CLRegionState.outside:
            if LocationManager.isEnterRegion {
                print("Outside Region")
                LocationManager.isEnterRegion = false
                sendExitNotify(title: "Outside Region")
            }
            break
        case .unknown:
            if LocationManager.isEnterRegion {
                print("unknown")
                print("Unknown Region")
                LocationManager.isEnterRegion = false
                sendExitNotify(title: "Unknown Region")
            }
            break
        }
        requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit Region")
        LocationManager.isEnterRegion = false
        sendExitNotify(title: "Exit Region")
    }
    
    private func sendExitNotify(title: String) {
        sendStatus(status: 0)
        sendNotification(title: title, body: "家を出ました。")
    }
    
    private func sendEnterNotify(title: String) {
        sendStatus(status: 1)
        sendNotification(title: title, body: "家に帰ってきました。")
    }
    
    private func sendStatus(status: Int) {
        let userData = RealmUserDataManager().getData()
        if userData.slackUserId == "-1" || userData.hId == "-1" {
            //ユーザ情報不足
            return
        }
        let url = URL(string: "https://script.google.com/macros/s/AKfycbwtEGgAOQ6LA3rcvsLcQFrrg8uVE1v5lkg8eNn40YjwAASTwmc/exec")
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let params: [[String: String]] = [[
            "id": userData.hId,
            "status": status.description
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
