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
    
    /// Slack再認証ボタンが押下された際に呼ばれます。
    /// - parameter sender: ボタンのオブジェクト
    @objc optional func didTouchSlackAuthButton(sender: Any)
    
    /// ユーザ識別子選択ボタンが押下された際に呼ばれます。
    /// - parameter sender: ボタンのオブジェクト
    @objc optional func didTouchUserIdentifierButton(sender: Any)
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
        self.dismiss(animated: true, completion: nil)
        delegate?.didTouchStatusSelfUpdateButton!(sender: sender)
    }
    
    @IBAction func TouchSlackAuthButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.didTouchSlackAuthButton!(sender: sender)
    }
    
    @IBAction func TouchUserIdentifierButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.didTouchUserIdentifierButton!(sender: sender)
    }
    
}
