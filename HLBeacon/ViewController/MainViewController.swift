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
    private var hLabUsers: [HLabUserData] = []
    private var slackUsers: [SlackUserData] = []
    private var isCompleteHLabConnection: Bool = true
    private var isCompleteSlackConnection: Bool = true
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    @IBOutlet var slackIdLabel: UILabel!
    @IBOutlet var hLabIdentifierLabel: UILabel!
    
    var uiUpdateTimer: Timer? = nil
    
    ///HLabManagerAPIを叩いてhLabManagerユーザリストを取得します
    private func getHLabUsers() {
        isCompleteHLabConnection = false
        
        self.hLabUsers = []
        
        //初期化処理
        let rootRef = Database.database().reference()
        rootRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let ref = snapshot.value as? NSDictionary
            //メンバーの取得
            let members = ref?["members"] as? NSArray ?? []
            for (idx, member) in members.enumerated() {
                let m = member as? NSDictionary
                let userData = HLabUserData(id: idx.description, name: m?["name"] as! String, status: (m?["status"] as! Int64).description)
                print("name:\(m?["name"] as! String),status:\((m?["status"] as! Int64).description)")
                self.hLabUsers.append(userData)
            }
        })
        
        isCompleteHLabConnection = true
    }
    
    ///SlackAPIを叩いてユーザリストを取得します
    private func getSlackUsers() {
        isCompleteSlackConnection = false
        let env = ProcessInfo.processInfo.environment
        let url = URL(string: "https://slack.com/api/users.list?token=\(env["SLACK_API_TOKEN"]!)")
        var request = URLRequest(url: url!)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, err in
            if err != nil {
                print("SLACK-USERS-GET: Failed")
                return;
            }
            print("SLACK-USERS-GET: Success")
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                print(json)
                if (json["ok"] as! Int) != 1 {
                    print("SLACK-USERS-GET: Failed. API ERROR")
                    return;
                }
                for member in json["members"] as! NSArray {
                    let m = member as! NSDictionary
                    if (m["deleted"] as! Bool) == false {
                        let profile = m["profile"] as! NSDictionary
                        self.slackUsers.append(SlackUserData(
                            id: m["id"] as! String,
                            name: m["real_name"] as! String,
                            status: profile["status_text"] as! String,
                            imgPath: profile["image_192"] as! String)) //TODO: imageのサイズ判定
                    }
                }
                self.isCompleteSlackConnection = true
            } catch {
                print("JSON SerializeError")
            }
            }.resume()
    }
    
    /// ステータス情報をHLManagerにプッシュします
    /// - parameter status: 0であれば外出,1であれば在室
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
            "status": status.description,
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getHLabUsers()
        getSlackUsers()
        updateStatus()
        uiUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.updateStatus), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Viewの再描画
        let userData = RealmUserDataManager().getData()
        slackIdLabel.text = "SlackId: \(userData.slackUserId)"
        hLabIdentifierLabel.text = "HLabIdentifier: \(userData.hIdentifier)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //users.listを遷移先に受け渡し
        if segue.identifier == "ShowUserNameInputView" {
            let userNameViewController = segue.destination as! UserNameInputViewController
            userNameViewController.slackUsers = sender as! [SlackUserData]
        }
        else if segue.identifier == "ShowIdentifierInputView" {
            let identifierInputViewController = segue.destination as! IdentifierInputViewController
            identifierInputViewController.hLabUsers = sender as! [HLabUserData]
        }
    }
    
    /// 外出ステータスをHLabManagerにプッシュします
    @IBAction func setStatusToOutRoom(_ sender: Any) {
        sendStatus(status: 0)
        pushConfirmAlert(title: "ステータス変更完了", message: "HLabManagerのステータスを外出に変更しました。")
    }
    
    /// 在室ステータスをHLabManagerにプッシュします
    @IBAction func setStatusToInRoom(_ sender: Any) {
        sendStatus(status: 1)
        pushConfirmAlert(title: "ステータス変更完了", message: "HLabManagerのステータスを在室に変更しました。")
    }
    
    ///UserNameInputViewに遷移します。
    @IBAction func PerformUsernameInputView(_ sender: Any) {
        if isCompleteSlackConnection {
            print(slackUsers)
            self.performSegue(withIdentifier: "ShowUserNameInputView", sender: slackUsers)
        }
    }
    ///IdentifierInputViewに遷移します。
    @IBAction func PerformIdentifierInputView(_ sender: Any) {
        if isCompleteHLabConnection {
            print(hLabUsers)
            self.performSegue(withIdentifier: "ShowIdentifierInputView", sender: hLabUsers)
        }
    }
    
    ///UIのラベルを更新します
    @objc func updateStatus() {
        if LocationManager.isEnterBeaconRegion {
            statusLabel.text = "在室"
            statusLabel.textColor = UIColor.blue
        }else {
            statusLabel.text = "外出"
            statusLabel.textColor = UIColor.darkGray
        }
        
        if LocationManager.rssi != nil {
            rssiLabel.text = "RSSI: \(LocationManager.rssi!)"
        }
    }
}

