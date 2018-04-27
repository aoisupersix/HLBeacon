//
//  ViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/14.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    private var users: [SlackUserData] = []
    private var isCompleteUsersConnection: Bool = true
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    
    var uiUpdateTimer: Timer? = nil
    
    private func getUsers() {
        isCompleteUsersConnection = false
        let url = URL(string: "https://slack.com/api/users.list?token=\(SLACK_API_TOKEN)")
        var request = URLRequest(url: url!)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, err in
            if err == nil {
                print("SLACK-USERS-GET: Success")
            }
            else {
                print("SLACK-USERS-GET: Failed")
                print("err:\(err!)")
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                print(json)
                for member in json["members"] as! NSArray {
                    let m = member as! NSDictionary
                    if (m["deleted"] as! Bool) == false {
                        let profile = m["profile"] as! NSDictionary
                        self.users.append(SlackUserData(
                            id: m["id"] as! String,
                            name: m["real_name"] as! String,
                            status: profile["status_text"] as! String,
                            imgPath: profile["image_192"] as! String)) //TODO: imageのサイズ判定
                    }
                }
                self.isCompleteUsersConnection = true
            } catch {
                print("JSON SerializeError")
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers()
        updateStatus()
        uiUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateStatus), userInfo: nil, repeats: true)
    }
    @IBAction func PerformTableViewTest(_ sender: Any) {
        if isCompleteUsersConnection {
            print(users)
            self.performSegue(withIdentifier: "ShowUserNameInputView", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateStatus() {
        if LocationManager.isEnterRegion {
            statusLabel.text = "在室"
            statusLabel.textColor = UIColor.blue
        }else {
            statusLabel.text = "外室"
            statusLabel.textColor = UIColor.darkGray
        }
        
        if LocationManager.rssi != nil {
            rssiLabel.text = "RSSI: \(LocationManager.rssi!)"
        }
    }
}

