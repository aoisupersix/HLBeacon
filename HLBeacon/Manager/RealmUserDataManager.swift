//
//  RealmUserDataManager.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/28.
//

import Foundation
import RealmSwift

///ユーザ情報を管理するクラス
class RealmUserDataManager {
    static let sharedInstance = RealmUserDataManager()
    
    /// ユーザ情報を取得します。
    /// ユーザ情報が存在しない場合はダミーのクラスを返します。(hIdが-1)
    /// - returns: 取得したユーザ情報
    func getData() -> RealmUserData? {
        let realm = try! Realm()
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        let data = realm.objects(RealmUserData.self)
        if data.count == 0 {
            //ダミー作成
            let dummy = RealmUserData()
            addData(data: dummy)
            return dummy
        }
        return data.first!
    }
    
    /// ユーザ情報をRealmに登録します。
    /// 不要な引数は省略可能
    /// - parameter slackAccessToken: Slackのアクセストークン
    /// - parameter hId: HLabManagerのID(番地)
    /// - parameter hIdentifier: HLabMangerの識別子
    func setData(slackAccessToken: String? = nil, hId: String? = nil, hIdentifier: String? = nil) {
        if slackAccessToken == nil && hId == nil && hIdentifier == nil {
            return
        }
        //データを取得して書き換え
        let data = getData()
        //削除
        let realm = try! Realm()
        try! realm.write() {
            if slackAccessToken != nil {
                data?.slackAccessToken = slackAccessToken!
            }
            if hId != nil {
                data?.hId = hId!
            }
            if hIdentifier != nil {
                data?.hIdentifier = hIdentifier!
            }
        }
    }
    
    /// ユーザ情報データをRealmに追加します。
    private func addData(data: RealmUserData) {
        let realm = try! Realm()
        try! realm.write() {
            realm.add(data)
        }
    }
}
