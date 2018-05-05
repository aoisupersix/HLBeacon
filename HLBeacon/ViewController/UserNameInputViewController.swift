//
//  UserNameInputViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import UIKit

/// Slackのユーザ名入力ビューのViewController
class UserNameInputViewController: UIViewController {
    
    /// UserNameInputViewのテーブル
    @IBOutlet weak var tableView: UITableView!
    
    /// Slackのユーザ情報
    var slackUsers: [SlackUserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// 戻るボタン押下時にビューを遷移します
    @IBAction func BackView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
