//
//  ViewController.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/14.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    
    var uiUpdateTimer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateStatus()
        uiUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateStatus), userInfo: nil, repeats: true)
    }
    @IBAction func PerformTableViewTest(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowUserNameInputView", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateStatus() {
        if LocationManager.isEnterRegion {
            statusLabel.text = "在室"
            statusLabel.textColor = UIColor.blue
        }else {
            statusLabel.text = "外室"
            statusLabel.textColor = UIColor.darkGray
        }
        
        if LocationManager.rssi != nil {
            rssiLabel.text = "RSSI: \(LocationManager.rssi!)"
        }
    }


}

