//
//  ViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/14.
//

import UIKit
import UserNotifications
import RealmSwift
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    @IBOutlet var slackAuthLabel: UILabel!
    @IBOutlet var hLabIdentifierLabel: UILabel!
    
    var uiUpdateTimer: Timer? = nil
    
    /// 確認アラートを表示します。
    /// - parameter title: アラートのタイトル
    /// - parameter message: アラートのメッセージ
    private func pushConfirmAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateStatusLabel(status: Int) {
        //TODO ステータスの処理
        if status == PresenseStatus.PRESENSE.rawValue {
            self.statusLabel.text = "在室"
            self.statusLabel.textColor = UIColor.blue
        }else if status == PresenseStatus.IN_CAMPUS.rawValue {
            self.statusLabel.text = "学内"
            self.statusLabel.textColor = UIColor.green
        }else {
            self.statusLabel.text = "外出"
            self.statusLabel.textColor = UIColor.darkGray
        }
    }
    
    private func setFirebaseEvent() {
        let rootRef = Database.database().reference()
        let memRef = rootRef.child("members")
        memRef.observe(.value, with: { (snap: DataSnapshot) in
            let data = RealmUserDataManager().getData()
            if data?.hId == nil {
                return
            }
            let members = snap.value as? NSArray ?? []
            for(idx, member) in members.enumerated() {
                if idx.description == data?.hId {
                    let m = member as? NSDictionary
                    print("updateStatus:id:\(idx)status:\(m!["status"] ?? "nil")")
                    self.updateStatusLabel(status: (m!["status"] as? Int)!)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Viewの再描画
        setFirebaseEvent()
        let userData = RealmUserDataManager().getData()
        slackAuthLabel.text = userData?.slackAccessToken != nil ? "Slack認証済み" : "Slack未認証"
        hLabIdentifierLabel.text = "HLabIdentifier: \(userData?.hIdentifier ?? "null")"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //遷移先の戻るボタンを有効化
        if segue.identifier == "ShowIdentifierInputView" {
            let identifierViewController = segue.destination as! IdentifierInputViewController
            identifierViewController.isEnabledDismissButton = true
        }
    }
        
    ///SlackのOAuth認証を行います
    @IBAction func PerformSlackAuth(_ sender: Any) {
        SlackAuthManager().authSlack()
    }
    ///IdentifierInputViewに遷移します。
    @IBAction func PerformIdentifierInputView(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowIdentifierInputView", sender: nil)
    }
    
    ///UIのラベルを更新します
    @objc func updateStatus() {
        if LocationManager.isEnterBeaconRegion {
            statusLabel.text = "在室"
            statusLabel.textColor = UIColor.blue
        }else if LocationManager.isEnterGeofenceRegion {
            statusLabel.text = "学内"
            statusLabel.textColor = UIColor.green
        }else {
            statusLabel.text = "外出"
            statusLabel.textColor = UIColor.darkGray
        }
        
        if LocationManager.rssi != nil {
            rssiLabel.text = "RSSI: \(LocationManager.rssi!)"
        }
    }
}

