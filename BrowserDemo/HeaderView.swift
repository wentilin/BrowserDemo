//
//  HeaderView.swift
//  BrowserDemo
//
//  Created by wentilin on 15/6/5.
//  Copyright (c) 2015年 wentilin. All rights reserved.
//

import UIKit

protocol HeaderViewDelegate {
    func reloadDataWhenClickHeaderButton(sender: UIButton);
}

class HeaderView: UITableViewHeaderFooterView {
    var titleBtn: UIButton?
    var isOpen: Bool = false
    var delegate: HeaderViewDelegate?
    
    class func headerView(tableView: UITableView) -> HeaderView? {
        let identifier = "HeaderView"
        var headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(identifier) as? HeaderView
        if headerView == nil {
            headerView = HeaderView(reuseIdentifier: identifier)
        }
        return headerView
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        titleBtn = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        titleBtn?.setImage(UIImage(named: "buddy_header_arrow"), forState: UIControlState.Normal)
        titleBtn?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        titleBtn?.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        titleBtn?.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        titleBtn?.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        titleBtn?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        titleBtn?.imageView?.clipsToBounds = true
        titleBtn?.addTarget(self, action: "triggerHistory", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(titleBtn!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleBtn?.frame = self.bounds
    }
    
    func triggerHistory() {
        isOpen = !isOpen
        self.delegate!.reloadDataWhenClickHeaderButton(titleBtn!)
    }
    
//    override func didMoveToSuperview() {
//        titleBtn?.imageView?.transform = self.isOpen ? CGAffineTransformMakeRotation(CGFloat(M_PI_2)) : CGAffineTransformMakeRotation(CGFloat(0))
//    }
}
