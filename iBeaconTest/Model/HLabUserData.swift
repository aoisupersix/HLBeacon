//
//  hLabUserData.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/28.
//

import Foundation

///HLabのユーザ情報を格納するクラス
class HLabUserData {
    /// ID
    let id: String
    /// ユーザ名
    let name: String
    /// ステータステキスト
    let status: String
    
    init(id: String, name: String, status: String) {
        self.id = id
        self.name = name
        self.status = status
    }
}
