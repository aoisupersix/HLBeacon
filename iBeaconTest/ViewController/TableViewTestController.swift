//
//  TableViewTestController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import UIKit

class TableViewTestController: UIViewController {
    
    @IBOutlet var tableView: ExpandableTableView!
    var items:[[Int]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ダミー
        for i in 0 ..< 20 {
            items.append([])
            for j in 0 ..< 10 {
                items[i].append(j)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension TableViewTestController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !items.isEmpty {
            if self.tableView.sectionOpen != NSNotFound && section == self.tableView.sectionOpen {
                return items[section].count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! UserInfoTableViewCell
        cell.typeInfoLabel.text = "s,r:"
        cell.textField.text = "\((indexPath as NSIndexPath).section), \((indexPath as NSIndexPath).row)"        
        
        return cell
    }
}

extension TableViewTestController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView(tableView: self.tableView, section: section)
        headerView.backgroundColor = UIColor(
            red: CGFloat(arc4random_uniform(100)) / 100.0,
            green: CGFloat(arc4random_uniform(100)) / 100.0,
            blue: CGFloat(arc4random_uniform(100)) / 100.0,
            alpha: 1
        )
        let label = UILabel(frame: headerView.frame)
        label.text = "Section \(section), touch here!"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textColor = UIColor.white
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
