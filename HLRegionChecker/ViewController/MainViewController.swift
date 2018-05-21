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
    
    /// RealtimeDatabaseのメンバー更新ハンドル
    var membersUpdateEvent: DatabaseHandle? = nil
    
    /// ステータス情報
    var hLabstates: [HLabStatusData] = []
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    @IBOutlet var slackAuthLabel: UILabel!
    @IBOutlet var hLabIdentifierLabel: UILabel!
    
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
    
    /// ステータス表示のラベルを引数に与えられたステータスに応じて変更します。
    /// - parameter status: 更新するステータスID
    private func updateStatusLabel(status: Int) {
        //TODO ステータスの処理
        if status == PresenseStatus.PRESENSE.rawValue {
            self.statusLabel.text = "在室"
            self.statusLabel.textColor = UIColor.blue
        }else if status == PresenseStatus.IN_CAMPUS.rawValue {
            self.statusLabel.text = "学内"
            self.statusLabel.textColor = UIColor.orange
        }else {
            self.statusLabel.text = "帰宅"
            self.statusLabel.textColor = UIColor.darkGray
        }
    }
    
    /// RealtimeDatabaseの更新トリガーを追加します。
    private func setFirebaseEvent() {
        //ステータス情報の取得
        hLabstates = []
        let rootRef = Database.database().reference()
        rootRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let ref = snapshot.value as? NSDictionary
            let states = ref?["status"] as? NSArray ?? []
            for (idx, states) in states.enumerated() {
                let s = states as? NSDictionary
                let status = HLabStatusData(id: idx.description, name: s?["name"] as! String, color: s?["color"] as! String)
                self.hLabstates.append(status)
            }
        })
        
        //メンバー情報更新トリガー
        let memRef = rootRef.child("members")
        self.membersUpdateEvent = memRef.observe(.value, with: { (snap: DataSnapshot) in
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
    
    /// 引数に与えられたステータスにDBを更新します。
    /// - parameter stateId: DBのステータスID
    private func updateStatus(stateId: Int) {
        print("updateStatus:\(stateId)")
        
        let userData = RealmUserDataManager().getData()
        if userData?.slackAccessToken == nil || userData?.hId == nil {
            //ユーザ情報不足のため送信不可
            return
        }
        let childUpdates = ["status": stateId]
        let rootRef = Database.database().reference()
        let memRef = rootRef.child("members")
        memRef.child(userData!.hId).updateChildValues(childUpdates)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        //RealtimeDatabaseリスナーのデタッチ
        let rootRef = Database.database().reference()
        let memRef = rootRef.child("members")
        memRef.removeObserver(withHandle: membersUpdateEvent!)
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
        }else if segue.identifier == "ShowMenu" {
            segue.destination.preferredContentSize = CGSize(width: 200, height: 150)
            let popView = segue.destination.popoverPresentationController
            popView!.delegate = self
            let view = segue.destination as! PopoverMenuViewController
            view.delegate = self
        }
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension MainViewController: PopoverMenuViewDelegate {
    
    private func alertAction(action: UIAlertAction) {
        print(action.title ?? "nil")
    }
    
    func didTouchStatusSelfUpdateButton(sender: Any) {
        if hLabstates.count == 0 {
            return
        }
        
        //ステータスの手動更新アラートを表示
        let alert = UIAlertController(title: "ステータスの手動更新", message: "ステータスを手動で更新します。更新するステータスを選択してください", preferredStyle: UIAlertControllerStyle.actionSheet)

        //ステータス情報のボタンを取得
        for status in hLabstates {
            let statusAction: UIAlertAction = UIAlertAction(title: status.name, style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction!) -> Void in
                self.updateStatus(stateId: Int(status.id)!)
            })
            alert.addAction(statusAction)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("cancelAction")
        })
        
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// Slack再認証を行います
    func didTouchSlackAuthButton(sender: Any) {
        SlackAuthManager().authSlack()
    }
    
    /// ユーザ識別子選択ビューに遷移します
    func didTouchUserIdentifierButton(sender: Any) {
        self.performSegue(withIdentifier: "ShowIdentifierInputView", sender: nil)
    }
}
