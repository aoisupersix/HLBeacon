//
//  SlackApiManager.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import Foundation

/// SlackAPIとのやりとりを行うクラスです。
class SlackApiManager {
    
    /// クラスのインスタンス
    static let sharedInstance = SlackApiManager()
        
    func getUsers() -> [SlackUserData]? {
        let url = URL(string: "https://slack.com/api/users.list?token=")
        var request = URLRequest(url: url!)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        var users: [SlackUserData] = []
        
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
                for member in json["members"] as! NSArray {
                    let m = member as! NSDictionary
                    if (m["deleted"] as! Bool) == false {
                        let profile = m["profile"] as! NSDictionary
                        users.append(SlackUserData(
                            id: m["id"] as! String,
                            name: m["real_name"] as! String,
                            status: profile["status_text"] as! String,
                            imgPath: profile["image_192"] as! String)) //TODO: imageのサイズ判定
                    }
                }
            } catch {
                print("JSON SerializeError")
            }
        }.resume()
        return users
    }
}
