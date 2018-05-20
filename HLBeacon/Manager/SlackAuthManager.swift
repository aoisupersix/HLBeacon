//
//  SlackAuthManager.swift
//  HLBeacon
//
//  Created by aoisupersix on 2018/05/20.
//

import Foundation
import Alamofire
import SwiftyJSON
import SafariServices

/// Slackの認証処理を行うクラス
class SlackAuthManager {
    static let sharedInstance = SlackAuthManager()
    
    /// 認証を行うSafariのセッション(IOS11以降サポート)
    var session: SFAuthenticationSession? = nil
    
    /// SlackのOAuth2.0認証を行い、取得したアクセストークンをRealmUserDataに登録します
    func authSlack() {
        //認可コード取得
        let env = ProcessInfo.processInfo.environment
        let url = URL(string: SLACK_AUTHORIZE_URL + "?client_id=\(env["SLACK_CLIENT_ID"]!)&scope=users:write")!
        let callbackUrlScheme = "hl-beacon"
        
        session = SFAuthenticationSession(
            url: url,
            callbackURLScheme: callbackUrlScheme,
            completionHandler: {(callbackURL, error) in
                if error == nil {
                    //アクセストークン取得
                    let query = callbackURL?.query?.components(separatedBy: "=")
                    if query![0] == "code" {
                        let accessCode = query![1]
                        self.getAccessToken(code: accessCode)
                    }
                }
        })
        session?.start()

    }
    
    /// アクセストークンを取得してRealmUserDataに登録します。
    /// - parameter code: OAuth認可コード
    private func getAccessToken(code: String) {
        let env = ProcessInfo.processInfo.environment
        Alamofire.request( SLACK_OAUTH_URL + "?client_id=\(env["SLACK_CLIENT_ID"]!)&client_secret=\(env["SLACK_CLIENT_SECRET"]!)&code=\(code)").responseJSON{
            response in
            let json = JSON(response.result.value!)
            print("access_token:\(json["access_token"])")
            RealmUserDataManager().setData(slackAccessToken: json["access_token"].description, hId: nil, hIdentifier: nil)
        }
    }
}
