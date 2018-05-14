//
//  IdentifierInputViewControlle.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/28.
//

import UIKit

/// HLab-Manager識別子入力ビューのViewController
class IdentifierInputViewController: UIViewController {
    
    /// IdentifierInputViewのテーブル
    @IBOutlet weak var tableView: UITableView!
    
    /// Hlabユーザ情報
    var hLabUsers: [HLabUserData] = []

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

/// IdentifierInputViewControllerのテーブル関係の処理
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
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
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
        
        //ビュー遷移
        self.dismiss(animated: true, completion: nil)
    }
}
