//
//  PopoverMenuViewController.swift
//  HLRegionChecker
//
//  Created by aoisupersix on 2018/05/20.
//

import UIKit

/// PopOverMenuViewのボタンクリック処理を委託するデリゲートです。
@objc protocol PopoverMenuViewDelegate {
    
    /// ステータス手動更新ボタンが押下された際に呼ばれます。
    /// - parameter sender: ボタンのオブジェクト
    @objc optional func didTouchStatusSelfUpdateButton(sender: Any)
    
    /// 設定ボタンが押下された際に呼ばれます。
    /// - parameter sender: ボタンのオブジェクト
    @objc optional func didTouchSettingButton(sender: Any)
}

class PopoverMenuViewController: UIViewController {
    /// 処理委託先のインスタンス
    weak var delegate: PopoverMenuViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func TouchSelfUpdateButton(_ sender: Any) {
        delegate?.didTouchStatusSelfUpdateButton!(sender: sender)
    }
    
    @IBAction func TouchSettingButton(_ sender: Any) {
        delegate?.didTouchSettingButton!(sender: sender)
    }
}
