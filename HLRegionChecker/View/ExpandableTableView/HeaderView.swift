//
//  HeaderView.swift
//  iBeaconTest
//
//  Created by aoisupersix on 2018/04/24.
//

import UIKit

protocol HeaderViewDelegate {
    func openedView(section: Int)
    func closedView(section: Int)
}

class HeaderView: UIView {
    
    var tableView: ExpandableTableView!
    var delegate: HeaderViewDelegate?
    var section = 0
    
    required init(tableView:ExpandableTableView, section:Int){
        
        guard let height = tableView.delegate?.tableView?(tableView, heightForHeaderInSection: section) else{
            fatalError("heightForHeaderInSectionを呼んでね。")
        }
        
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: height)
        super.init(frame: frame)
        
        self.tableView = tableView
        self.delegate = tableView
        self.section = section
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) は使わないでね。")
    }
    
    override func layoutSubviews() {
        
        let toggleButton = UIButton()
        
        toggleButton.addTarget(self,
                               action: #selector(HeaderView.toggle(sender:)),
                               for: .touchUpInside)
        
        toggleButton.backgroundColor = UIColor.clear
        toggleButton.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(toggleButton)
    }
    
    @objc func toggle(sender:AnyObject){
        
        if tableView.sectionOpen != section {
            delegate?.openedView(section: section)
        } else if tableView.sectionOpen != NSNotFound {
            delegate?.closedView(section: self.tableView!.sectionOpen)
        }
    }
}
