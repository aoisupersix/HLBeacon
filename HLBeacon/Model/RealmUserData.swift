//
//  RealmUserData.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/28.
//

import Foundation
import RealmSwift

class RealmUserData: Object {
    @objc dynamic var slackAccessToken: String = ""
    @objc dynamic var hId: String = ""
    @objc dynamic var hIdentifier: String = ""
}
