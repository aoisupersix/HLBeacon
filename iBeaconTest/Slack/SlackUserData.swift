//
//  SlackUserData.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import Foundation

/// Slackのユーザ情報を格納するクラス
class SlackUserData {
    /// ID
    let id: String
    /// ユーザ名
    let name: String
    /// ステータステキスト
    let status: String
    /// アバター画像のURL
    let imgPath: String
    
    init(id: String, name: String, status: String, imgPath: String) {
        self.id = id
        self.name = name
        self.status = status
        self.imgPath = imgPath
    }
}
