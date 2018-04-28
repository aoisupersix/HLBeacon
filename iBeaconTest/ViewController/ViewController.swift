//
//  ViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/14.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    private var hLabUsers: [HLabUserData] = []
    private var slackUsers: [SlackUserData] = []
    private var isCompleteHLabConnection: Bool = true
    private var isCompleteSlackConnection: Bool = true
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    
    var uiUpdateTimer: Timer? = nil
    
    ///SlackAPIを叩いてhLabManagerユーザリストを取得します
    private func getHLabUsers() {
        isCompleteHLabConnection = false
        let url = URL(string: "https://script.googleusercontent.com/macros/echo?user_content_key=0ZdlaBPLV4NfQ-CI8N8NFRL49Bo3NEb5_F6vMCfwlIKXQ6Tlc3xePryegjzYP0EoVq3Ao933LJ4b-eEG-pFs9jCImyr7cHx2m5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnC7KzRAiUJKJsxOht5H96T6k7rwNRtxGwVrHKo0vZt2a-aICPhaGXBXRGDC86Rjg9kqhI51p3q1_&lib=MjdNaf7H1FgzgxVIaR9gEUj8SyHr1OfNd")
        var request = URLRequest(url: url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, err in
            if err != nil {
                print("HLAB-USERS-GET: Failed")
                return;
            }
            print("HLAB-USERS-GET: Success")
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print(json)
                for member in json as! NSArray {
                    let m = member as! NSDictionary
                    let id = m["id"] as! Int64
                    let name = m["name"] as! String
                    let status = m["status"] as! Int64
                    self.hLabUsers.append(HLabUserData(id: id.description, name: name, status: status.description))
                }
                self.isCompleteHLabConnection = true
            } catch {
                print("JSON SerializeError")
            }
            }.resume()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getHLabUsers()
        getSlackUsers()
        updateStatus()
        uiUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateStatus), userInfo: nil, repeats: true)
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

