//
//  UserTableViewCell.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/27.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet var iconImage: AsyncImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    func setCell(userData: SlackUserData) {
        self.iconImage.loadImage(urlString: userData.imgPath)
        self.userNameLabel.text = userData.name
    }
}
