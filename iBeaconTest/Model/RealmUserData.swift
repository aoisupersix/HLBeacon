//
//  RealmUserData.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/28.
//

import Foundation
import RealmSwift

class RealmUserData: Object {
    @objc dynamic var slackUserId: String = ""
    @objc dynamic var hId: Int = -1
    @objc dynamic var hIdentifier: String = ""
}
