//
//  UserNameInputViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import UIKit
import Alamofire
import SwiftyJSON
import SafariServices

/// Slackのユーザ名入力ビューのViewController
class UserNameInputViewController: UIViewController {
    
    /// UserNameInputViewのテーブル
    @IBOutlet weak var tableView: UITableView!
    
    /// Slackのユーザ情報
    var slackUsers: [SlackUserData] = []
    
    var session: SFAuthenticationSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //認可コード取得
        let env = ProcessInfo.processInfo.environment
        let url = URL(string: "https://slack.com/oauth/authorize?client_id=\(env["SLACK_CLIENT_ID"]!)&scope=users:write")!
        let callbackUrlScheme = "hl-beacon"

        session = SFAuthenticationSession(
            url: url,
            callbackURLScheme: callbackUrlScheme,
            completionHandler: {(callbackURL, error) in
                //アクセストークン取得
                let query = callbackURL?.query?.components(separatedBy: "=")
                if query![0] == "code" {
                    let accessCode = query![1]
                    self.getAccessToken(code: accessCode)
                }
        })
        session?.start()
    }
    
    private func getAccessToken(code: String) {
        let env = ProcessInfo.processInfo.environment
        Alamofire.request("https://slack.com/api/oauth.access?client_id=\(env["SLACK_CLIENT_ID"]!)&client_secret=\(env["SLACK_CLIENT_SECRET"]!)&code=\(code)").responseJSON{
            response in
            let json = JSON(response.result.value!)
            print("access_token:\(json["access_token"])")
        }
    }
    
    /// 戻るボタン押下時にビューを遷移します
    @IBAction func BackView(_ sender: Any) {

        //self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

/// UserNameInputViewControllerのテーブル関係の処理
extension UserNameInputViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// tableViewのセクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// tableViewのセクション行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slackUsers.count
    }
    
    /// tableView各セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.setCell(userData: slackUsers[indexPath.row])
        return cell
    }
    
    /// セルが選択された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択されたセルのユーザ情報を取得
        let selectedCell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        let userName = selectedCell.userNameLabel.text
        let selectedUser = slackUsers.filter({ $0.name == userName}).first
        
        //登録
        RealmUserDataManager().setData(slackId: selectedUser?.id)
        
        //ビュー遷移
        self.dismiss(animated: true, completion: nil)
    }
}
