//
//  CustomSegue.swift
//  BrowserDemo
//
//  Created by wentilin on 15/6/3.
//  Copyright (c) 2015年 wentilin. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        if let navigationController = destinationViewController as? UINavigationController {
            UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: { () -> Void in
                //从源控制器转场到导航控制器
                self.sourceViewController.presentViewController(navigationController, animated: true, completion: {
                    let webController = self.sourceViewController as! ViewController
                    //获取导航控制器栈顶的视图控制器
                    let historyController = navigationController.topViewController as! HistoryTableViewController
                    //设置历史视图控制器的代理为网页控制器
                    historyController.delegate = webController
                    
                })
                }, completion: nil)
        }
    }
}
