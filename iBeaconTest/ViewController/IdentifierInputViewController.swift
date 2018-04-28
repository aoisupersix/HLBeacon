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
    
    //tableView各セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = hLabUsers[indexPath.row].name
        return cell
    }
}
