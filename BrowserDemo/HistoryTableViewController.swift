//
//  HistoryTableViewController.swift
//  BrowserDemo
//
//  Created by wentilin on 15/6/3.
//  Copyright (c) 2015年 wentilin. All rights reserved.
//

import UIKit
import WebKit

protocol ShowWebsitDelegate {
    func showWebsit(requst: NSURLRequest);
}

class HistoryTableViewController: UITableViewController, HeaderViewDelegate {
    
    var datesOfHistory: [String]?
    
    var historyWithDate: NSMutableDictionary? = {
        () -> NSMutableDictionary? in
        if let data = (NSUserDefaults.standardUserDefaults().objectForKey("HistoryURLWithDate") as? NSMutableDictionary) {
            
            return NSMutableDictionary(dictionary: data)
        } else {
            return nil
        }
    }()
    
    var delegate: ShowWebsitDelegate?
    
    var isShowCellOfSection: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datesOfHistory = historyWithDate?.allKeys as? [String]
        isShowCellOfSection = NSMutableArray(capacity: datesOfHistory!.count)
        for _ in datesOfHistory! {
            isShowCellOfSection?.addObject(false)
        }
        
        let backButton = UIBarButtonItem(title: "<", style: UIBarButtonItemStyle.Plain, target: self, action: "backToWebView")
        self.navigationItem.leftBarButtonItem = backButton
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //清除tableview的白线
        clearCellLine()
        
        //编辑模式下允许多选
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells()
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for cell in cells {
            let cell: UITableViewCell = cell as! UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as! UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: nil, animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
    }
    
    func backToWebView() {
        NSUserDefaults.standardUserDefaults().setObject(historyWithDate, forKey: "HistoryURLWithDate")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let history = datesOfHistory {
            return history.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //根据对应的section的status返回行数
        if let status = isShowCellOfSection {
            if status.objectAtIndex(section) as! Bool == true {
                if let dates = datesOfHistory {
                    if let historyURLDictonary = historyWithDate?.objectForKey(dates[section]) as? NSDictionary {
                        print(historyURLDictonary.allKeys.count)
                        return historyURLDictonary.allKeys.count
                    }
                }
            }
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("HistoryCellIdentifier") as? UITableViewCell

        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "HistoryCellIdentifier")
        }
        
        if let dates = datesOfHistory {
            if let historyURLDictonary = historyWithDate?.objectForKey(dates[indexPath.section]) as? NSDictionary {
                cell!.textLabel?.text = historyURLDictonary.allKeys[indexPath.row] as? String
                cell!.detailTextLabel?.text = historyURLDictonary.allValues[indexPath.row] as? String
            }
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing == false {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let urlString = cell?.detailTextLabel?.text
            let url = NSURL(string: urlString!)
            let request = NSURLRequest(URL: url!)
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.delegate?.showWebsit(request)
            })
        } else {
            print("\(tableView.indexPathsForSelectedRows)")
        }
    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if let dates = datesOfHistory {
//            return dates[section]
//        } else {
//            return "no detail date"
//        }
//    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = HeaderView.headerView(tableView)
        headerView?.delegate = self
        headerView?.titleBtn?.tag = section
        if let date = datesOfHistory {
            headerView?.titleBtn?.setTitle(date[section], forState: UIControlState.Normal)
        }
        let status = isShowCellOfSection?.objectAtIndex(section) as! Bool
        if status == true {
            headerView?.titleBtn?.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        } else {
            headerView?.titleBtn?.imageView!.transform = CGAffineTransformMakeRotation(CGFloat(0))
        }
        return headerView
    }
    
    func reloadDataWhenClickHeaderButton(sender: UIButton) {
        if let status = isShowCellOfSection?.objectAtIndex(sender.tag) as? Bool {
            isShowCellOfSection?.replaceObjectAtIndex(sender.tag, withObject: !status)
        }
        
        self.tableView.reloadData()
        self.animateTable()
    }
    
    func clearCellLine() {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = footerView
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if let dates = datesOfHistory {
                if let historyURLDictonary = historyWithDate?.objectForKey(dates[indexPath.section]) as? NSMutableDictionary {
                    let mutableHistoryURL = NSMutableDictionary(dictionary: historyURLDictonary)
                    let key = mutableHistoryURL.allKeys[indexPath.row] as! String
                    mutableHistoryURL.removeObjectForKey(key)
                    
                    historyWithDate?.setObject(mutableHistoryURL, forKey: dates[indexPath.section])
                    
                    print(historyURLDictonary.allKeys.count)
                }
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
}
