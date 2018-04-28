//
//  UserNameInputViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import UIKit

class UserNameInputViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var slackUsers: [SlackUserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func BackView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension UserNameInputViewController: UITableViewDelegate, UITableViewDataSource {
    
    ///tableViewのセクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///tableViewのセクション行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slackUsers.count
    }
    
    ///tableView各セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.setCell(userData: slackUsers[indexPath.row])
        return cell
    }
    
    ///セルが選択された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択されたセルのユーザ情報を取得
        let selectedCell = tableView.cellForRow(at: indexPath) as! UserTableViewCell
        let userName = selectedCell.userNameLabel.text
        let selectedUser = slackUsers.filter({ $0.name == userName}).first
        
        //登録
        RealmUserDataManager().setData(slackId: selectedUser?.id)
        
        let alert = UIAlertController(title: "設定完了", message: "ステータスを変更するアカウントを\(userName!)に設定しました。", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: {
            [presentedViewController] () -> Void in
            presentedViewController?.viewWillAppear(true)
        })
    }
}
