//
//  SlackUserData.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/25.
//

import Foundation

/// Slackのユーザ情報を格納するクラス
class SlackUserData: HLabUserData {
    /// アバター画像のURL
    let imgPath: String
    
    init(id: String, name: String, status: String, imgPath: String) {
        self.imgPath = imgPath
        super.init(id: id, name: name, status: status)
    }
}
