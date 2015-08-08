//
//  ViewController.swift
//  BrowserDemo
//
//  Created by wentilin on 15/6/2.
//  Copyright (c) 2015年 wentilin. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, ShowWebsitDelegate, SaveDataDelegate, WKNavigationDelegate {

    var webView: WKWebView = WKWebView(frame: CGRectZero)
    
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var homeButton: UIBarButtonItem!
    
    var historyURLDictonary: NSMutableDictionary?
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    var historyWithDate: NSMutableDictionary = {
        () -> NSMutableDictionary in
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("HistoryURLWithDate") as? NSMutableDictionary {
            return NSMutableDictionary(dictionary: data)
        } else {
            return NSMutableDictionary()
        }
    }()
    
    var heightOfWebView: CGFloat?
    
    var panGesture: UIPanGestureRecognizer?

    @IBOutlet var backAndForwardGesture: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //问题出在这里《《《《《《《《《《《《《《《《《《《《《《《
//        if let data = NSUserDefaults.standardUserDefaults().objectForKey("HistoryURLWithDate") as? NSDictionary {
//            historyURLDictonary = NSMutableDictionary(dictionary: data)
//        } else {
//            historyWithDate = NSMutableDictionary()
//            println("there is not data in historyWithDate")
//        }
        
//        historyURLDictonary = NSMutableDictionary()
        webView.navigationDelegate = self
        self.view.insertSubview(webView, belowSubview: progressView)
        
        webView.allowsBackForwardNavigationGestures = true
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
      
        //监听网页加载进度条
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
       
        
        //默认首页
        let url = NSURL(string: "https://www.baidu.com")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
      
        barView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)
        
        //第一次加载视图时不能后退或前进
        backButton.enabled = false
        forwardButton.enabled = false
        
        //添加监听loading属性
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        
        //测试滚动方向
        panGesture = webView.scrollView.panGestureRecognizer
        panGesture!.addTarget(self, action: "pan")
        
        //设置代理
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveDelegate = self
        
        //添加滑动手势控制webView的前进后退
        backAndForwardGesture.addTarget(self, action: "backOrForward:")
        webView.addGestureRecognizer(backAndForwardGesture)
        
        heightOfWebView = webView.frame.size.height
    
    }
    
    //滚动画面响应事件
    func pan() {
        urlTextField.resignFirstResponder()
        
        //使用移动速度的正负值判断滚动方向
        let velocity = panGesture!.velocityInView(webView.scrollView)
        if velocity.y < 0 {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.toolBar.hidden = true
            self.webView.frame.origin.y = 44
            self.view.backgroundColor = UIColor(white: 0.9, alpha: 0.99)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.toolBar.hidden = false
            self.webView.frame.origin.y = 0
        }
    }
    
    //滑动画面响应事件
    func backOrForward(gesture: UISwipeGestureRecognizer) {
//        if gesture.direction == UISwipeGestureRecognizerDirection.Left {
//            self.webView.goBack()
//        }
//        if gesture.direction == UISwipeGestureRecognizerDirection.Right {
//            self.webView.goForward()
//        }
    }
    
    //手机旋转后barView宽度自动适应
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        barView.frame = CGRect(x: 0, y: 0, width: size.width, height: 30)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        urlTextField.textAlignment = NSTextAlignment.Left
        urlTextField.text = webView.URL?.absoluteString
        return true
    }
    
    //文本框输入完毕按下回车键后
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlTextField.resignFirstResponder()
        
        if urlTextField.text!.hasPrefix("http://") {
            webView.loadRequest(NSURLRequest(URL: NSURL(string: urlTextField.text!)!))
        } else {
            let urlString = "http://" + urlTextField.text!
            let url = NSURL(string: urlString)
            let request = NSURLRequest(URL: url!)
            webView.loadRequest(request)
            
            //println("\(urlString)")
        }
        return false
    }
    
    //监听网页加载loading属性的变化和进度属性
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "loading" {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
            
            //历史时间戳
            let dateOfHistory = DateOfHistory.getDate()
            
            //历史记录
            if let  url = historyWithDate.objectForKey(dateOfHistory) as? NSMutableDictionary {
                historyURLDictonary = NSMutableDictionary(dictionary: url)
            } else {
                historyURLDictonary = NSMutableDictionary()
            }
            
            
            if (webView.title != nil) && (webView.URL != nil) {
                historyURLDictonary!.setObject(webView.URL!.absoluteString!, forKey: webView.title!)
            }
            
            
            //存储带时间戳的历史记录
            historyWithDate.setObject(historyURLDictonary!, forKey: dateOfHistory)
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(historyWithDate, forKey: "HistoryURLWithDate")
            defaults.synchronize()
            
            //显示webView的标题
            urlTextField.textAlignment = NSTextAlignment.Center
            urlTextField.text = titleOfWebView()
        }
        
        if keyPath == "estimatedProgress" {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.progressView.setProgress(0.0, animated: false)
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        println("\(navigationAction.navigationType)")
        println("\(navigationAction.request.URL)")
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    
    @IBAction func reload(sender: UIBarButtonItem) {
        if let _ = webView.URL {
            let request = NSURLRequest(URL: webView.URL!)
            webView.loadRequest(request)
        } else {
            let alert = UIAlertView(title: "网络连接故障", message: "请检查网络", delegate: self, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    @IBAction func backToHome(sender: UIBarButtonItem) {
        let url = NSURL(string: "http://www.baidu.com")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "ShowHistory" {
//            let destinationController = segue.destinationViewController as! UITableViewController
//            UIView.animateWithDuration(1.0, delay: 0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
//                self.navigationController?.pushViewController(destinationController, animated: true)
//            }, completion: nil)
//        }
    }
    
    //实现代理方法
    func showWebsit(requst: NSURLRequest) {
        //println("\(requst)")
        self.webView.loadRequest(requst)
        
    }
    
    //实现程序退出时保存数据代理方法
    func save() {

            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(historyWithDate, forKey: "HistoryURLWithDate")
            defaults.synchronize()

        print("saving data...")
    }
    
    func titleOfWebView() -> String? {
        return webView.title
    }
}

