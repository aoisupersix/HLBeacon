//
//  StatusData.swift
//  HLRegionChecker
//
//  Created by aoisupersix on 2018/05/21.
//

import Foundation

/// ステータス情報を格納するクラス
class HLabStatusData {
    let id: String
    let name: String
    let color: String
    
    init(id: String, name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
}
