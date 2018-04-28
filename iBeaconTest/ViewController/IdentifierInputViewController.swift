//
//  IdentifierInputViewControlle.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/28.
//

import UIKit

class IdentifierInputViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var hLabUsers: [HLabUserData] = []

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

extension IdentifierInputViewController: UITableViewDelegate, UITableViewDataSource {
    ///tableViewのセクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///tableViewのセクション行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hLabUsers.count
    }
    
    ///tableView各セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = hLabUsers[indexPath.row].name
        return cell
    }
    
    ///セルが選択された際の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択されたセルのユーザ情報を取得
        let selectedCell = tableView.cellForRow(at: indexPath)
        let userName = selectedCell?.textLabel?.text
        let selectedUser = hLabUsers.filter({ $0.name == userName}).first
        
        //登録
        RealmUserDataManager().setData(slackId: nil, hId: selectedUser?.id, hIdentifier: selectedUser?.name)
    
        let alert = UIAlertController(title: "設定完了", message: "あなたのユーザ識別子を\(userName!)に設定しました。", preferredStyle: UIAlertControllerStyle.alert)
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
