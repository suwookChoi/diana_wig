//
//  customerController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/06/23.
//  Copyright © 2020 smartdev. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class CustomerController: UIViewController, WKUIDelegate
{
    @IBOutlet weak var webview: WKWebView!
    lazy var progressbar: UIProgressView = UIProgressView()
     
    @IBOutlet weak var progressView: UIProgressView!
    var commonController: CommonController = CommonController()
    var sqliteController: SQLiteController = SQLiteController()
    var cardData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(">>> CustomerController <<<")
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "menu")
        contentController.add(self, name: "logout")
        
        contentController.add(self, name: "customerList")
        contentController.add(self, name: "doneCustomer")
        contentController.add(self, name: "headerHtml")
        contentController.add(self, name: "close")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        
        webview = WKWebView(frame: view.frame, configuration: configuration)
        webview.uiDelegate = self
        view.addSubview(webview)

        // ProgressBar Start
        self.view.addSubview(self.progressbar)
        self.progressbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            self.progressbar.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.progressbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.progressbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
        ])

        progressbar = commonController.progressBarSetting(progressbar: progressbar)
        
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        // ProgressBar End
        
        let localFile = Bundle.main.path(forResource: "customer", ofType: "html") ?? ""
        let url = URL(fileURLWithPath: localFile)
        let request = URLRequest(url : url)
        webview.load(request)
    }
    
    // ProgressBar
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var alpha: Double = 1.0
        switch keyPath {
        case "estimatedProgress":
            alpha = alpha - self.webview.estimatedProgress
            if self.webview.estimatedProgress >= 0.8 {
//                UIView.animate(withDuration: 0.3, animations: { () in
//                    self.progressbar.alpha = 0.0
//                }, completion: { finished in
//                    self.progressbar.setProgress(0.0, animated: false)
//                })
                self.progressbar.isHidden = true
                self.progressbar.removeFromSuperview()
            } else {
                self.progressbar.isHidden = false
                self.progressbar.alpha = CGFloat(alpha)
                self.progressbar.setProgress(Float(self.webview.estimatedProgress), animated: true)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension CustomerController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        
        if message.name == "menu" {
            print(">>> CustomerController menu <<<")
            
            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            vc.menu(data: message.body as! String)
            self.presentingViewController?.dismiss(animated: true)
        } else if message.name == "customerList" {
            print(">>> CustomerController customerList <<<")
            
            let login_id = UserDefaults.standard.object(forKey: "SlpCode") != nil ? UserDefaults.standard.object(forKey: "SlpCode") as! Int : 0
            
            if commonController.connectedToNetwork() {
                print(">>> network - customerList : success <<<")
                let client = SQLClient.sharedInstance()!
                //            client.delegate = self
                client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                    client.execute("SELECT CardCode, CardName, Balance, Address FROM OCRD WHERE SlpCode = \(login_id)" , completion: { (_ results: ([Any]?)) in
                        guard (results != nil) else {
                            print("error >>>>>>>>>>>> customerList Select")
                            let funcName = "error()"
                            self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                            return
                        }
                        for table in results as! [[[String:AnyObject]]] {
                            do {
                                let rawData = try JSONSerialization.data(withJSONObject: table as Any)
                                let jsonString = String(data: rawData, encoding: String.Encoding.utf8)
                                print(jsonString)
                                
                                let myJsFuncName = "html('\(jsonString!)', 'Y', '\(self.cardData)')"
                                self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                            } catch {
                                print("catch >>>>>>>>>>>> customerList Select")
                            }
                        }
                        client.disconnect()
                    })
                }
            } else {
                print(">>> network - customerList : fail <<<")
                    
                let dbPath = sqliteController.dbPath
                //DB 객체 생성
                let database : FMDatabase? = FMDatabase(path: dbPath as String)
                
                if let db = database {
                    var array = Array<Dictionary<String, AnyObject>>()
                    
                    db.open()
                    
                    let sqlSelect : String = "SELECT CardCode, CardName, Balance, Address FROM OCRD WHERE SlpCode = \(login_id)"
                    let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
                    guard (result != nil) else {
                        print("error >>>>>>>>>>>> customerList Select")
                        let funcName = "error()"
                        self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                        return
                    }
                    if let rs = result {
                        while rs.next(){
                            var dic = Dictionary<String, AnyObject>()
                            dic["CardCode"] = rs.string(forColumn: "CardCode") as AnyObject
                            dic["CardName"] = rs.string(forColumn: "CardName") as AnyObject
                            dic["Balance"] = rs.object(forColumn: "Balance") as AnyObject
                            dic["Address"] = rs.string(forColumn: "Address") as AnyObject
                            array.append(dic)
                        }
                    }
                    db.close()
                    
                    do {
                        let data = try JSONSerialization.data(withJSONObject: array as Any)
                        let jsonString = String(data: data, encoding: String.Encoding.utf8)
                        print(jsonString)
                        let funcName = "html('\(jsonString!)', 'N', '\(self.cardData)')"
                        webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                    } catch {
                        print("catch >>>>>>>>>>>> customerList Select")
                    }
                }
            }
        } else if message.name == "doneCustomer" {
            print(">>> CustomerController doneCustomer <<<")

            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            print(message.body)
            vc.closeCustomer(data: message.body as! String)
            
            self.presentingViewController?.dismiss(animated: true)
        }  else if message.name == "headerHtml" {
            let loginID: String = UserDefaults.standard.object(forKey: "SlpName") as! String
            let myJsFuncName = "headerHtml('','\(loginID)')"
            self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                          
        } else if message.name == "logout"{
            print(">>> CustomerController logout <<<")
            
            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            vc.logout()
            self.presentingViewController?.dismiss(animated: true)
        } else {
            print(">>> CustomerController close <<<")
            
            let presentVC = self.presentingViewController as! ViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            vc.closeCustomer(data: cardData)
            self.presentingViewController?.dismiss(animated: false)
        }
        
    }
    

}
