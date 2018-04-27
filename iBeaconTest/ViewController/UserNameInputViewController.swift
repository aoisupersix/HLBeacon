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
    
    //tableView各セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.setCell(userData: slackUsers[indexPath.row])
        return cell
    }
}
