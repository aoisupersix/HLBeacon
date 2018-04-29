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
    func getData() -> RealmUserData {
        let realm = try! Realm()
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        let data = realm.objects(RealmUserData.self)
        if data.count == 0 {
            //データ作成
            let dummy = RealmUserData()
            dummy.slackUserId = "-1"
            dummy.hId = "-1"
            dummy.hIdentifier = "null"
            addData(data: dummy)
            return dummy
        }
        return data.first!
    }
    
    /// ユーザ情報をRealmに登録します。
    /// 不要な引数は省略可能
    /// - parameter slackId: SlackのユーザID
    /// - parameter hId: HLabManagerのID(番地)
    /// - parameter hIdentifier: HLabMangerの識別子
    func setData(slackId: String? = nil, hId: String? = nil, hIdentifier: String? = nil) {
        if slackId == nil && hId == nil && hIdentifier == nil {
            return
        }
        //データを取得して書き換え
        let data = getData()
        //削除
        let realm = try! Realm()
        try! realm.write() {
            if slackId != nil {
                data.slackUserId = slackId!
            }
            if hId != nil {
                data.hId = hId!
            }
            if hIdentifier != nil {
                data.hIdentifier = hIdentifier!
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
