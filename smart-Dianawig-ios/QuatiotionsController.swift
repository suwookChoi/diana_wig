//
//  QuatiotionController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/06/17.
//  Copyright © 2020 smartdev. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class QuotationsController: UIViewController, WKUIDelegate
{
    @IBOutlet weak var webview: WKWebView!
    lazy var progressbar: UIProgressView = UIProgressView()
    
    var commonController: CommonController = CommonController()
    var sqliteController: SQLiteController = SQLiteController()
    
    var qutdata: String = ""
    var loginID : Int = UserDefaults.standard.value(forKey: "SlpCode") as! Int
    var loginName : String = UserDefaults.standard.value(forKey: "SlpName") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(">>> QuotationsController <<<")
        
        let contentController = WKUserContentController()
        
        contentController.add(self, name: "menu")
        contentController.add(self, name: "logout")
        
        contentController.add(self, name: "quotationDetail")
        contentController.add(self, name: "moveQuotationsDetailItem")
        contentController.add(self, name: "quotationsDetailItem")
        
        contentController.add(self, name: "headerHtml")
        contentController.add(self, name: "itemClose")
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

        let localFile = Bundle.main.path(forResource: "quotationsDetail", ofType: "html") ?? ""
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

extension QuotationsController: WKScriptMessageHandler {
    func quotationList(dbData: Dictionary<String, Any>, webview: WKWebView) {
        print(">>> QuotationsController quotationList <<<")
        
        if commonController.connectedToNetwork() {
            print(">>> network - quotationList : success <<<")
            
            var list : [Any] = []
            
            let client = SQLClient.sharedInstance()!
//            client.delegate = self
            client.connect(dbData["mssqlIP"] as! String, username: dbData["mssqlName"] as! String, password: dbData["mssqlPwd"] as! String, database: dbData["mssqlDb"] as! String) { success in
                client.execute(
                    "SELECT " +
                        "DocEntry, SlpName, Flags, CardCode, CardName, Address, CONVERT(CHAR(10), DocDate, 23) AS DocDate, " +
                        "PaidSum, '$' AS Currency, 0 AS DiscountPer, 'Y' AS InsertYN " +
                    "FROM OQUT A " +
                    "INNER JOIN (SELECT SlpCode, SlpName FROM OSLP) B ON A.SlpCode = B.SlpCode " +
                    "WHERE A.SlpCode = \(self.loginID) " +
                    "ORDER BY DocEntry DESC"
                    , completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("error >>>>>>>>>>>> quotationList Select")
                        let funcName = "error()"
                        webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                        return
                    }
                    for table in results as! [[[String:AnyObject]]] {
                        let tableCnt = table.count
                        do {
                            for row in table {
                                var arr: [String : Any] = [:]
                                arr = row
                                
                                let DocEntry = row["DocEntry"] as? Int
                                
                                client.execute(
                                    "SELECT ItemCode, Quantity, Price, Currency " +
                                    "FROM QUT1 " +
                                        "WHERE DocEntry = \(DocEntry!)"
                                    , completion: { (_ results: ([Any]?)) in
                                    guard (results != nil) else {
                                        print("error >>>>>>>>>>>> quotationList Item Select")
                                        let funcName = "error()"
                                        webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                                        return
                                    }
                                    for table in results as! [[[String:AnyObject]]] {
                                        do {
                                            arr["Item"] = table
                                            list.append(arr)
                                            
                                            if(tableCnt == list.count){
                                                let data = try JSONSerialization.data(withJSONObject: list as Any)
                                                let jsonString = String(data: data, encoding: String.Encoding.utf8)
                                                print(jsonString)
                                                
                                                let funcName = "html('\(jsonString!)', 'Y')"
                                                webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                                            }
                                        } catch {
                                            print("catch >>>>>>>>>>>> quotationList Item Select")
                                        }
                                    }
                                })
                            }
                        } catch {
                            print("catch >>>>>>>>>>>> quotationList Select")
                        }
                    }
                    client.disconnect()
                })
            }
        } else {
            print(">>> network - quotationList : fail <<<")
            
            let dbPath = sqliteController.dbPath
            //DB 객체 생성
            let database : FMDatabase? = FMDatabase(path: dbPath as String)
            
            if let db = database {
                var list = Array<Dictionary<String, AnyObject>>()
                
                db.open()
                
                let sqlSelect : String = "SELECT * " +
                                        "FROM (" +
                                            "SELECT DocEntry, SlpName, Flags, CardCode, CardName, Address, DocDate, PaidSum, '$' AS Currency, 0 AS DiscountPer, 'N' AS InsertYN " +
                                            "FROM NQUT A " +
                                                "INNER JOIN (SELECT SlpCode, SlpName FROM OSLP) B ON A.SlpCode = B.SlpCode " +
                                            "WHERE A.SlpCode = \(loginID) " +
                                            "ORDER BY DocEntry DESC" +
                                        ")" +
                                        " UNION ALL " +
                                        "SELECT * " +
                                        "FROM (" +
                                            "SELECT DocEntry, SlpName, Flags, CardCode, CardName, Address, DocDate, PaidSum, '$' AS Currency, 0 AS DiscountPer, 'Y' AS InsertYN " +
                                            "FROM OQUT A " +
                                                "INNER JOIN (SELECT SlpCode, SlpName FROM OSLP) B ON A.SlpCode = B.SlpCode " +
                                            "WHERE A.SlpCode = \(loginID) " +
                                            "ORDER BY DocEntry DESC" +
                                        ")"
                let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
                guard (result != nil) else {
                    print("error >>>>>>>>>>>> quotationList Select")
                    let funcName = "error()"
                    webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                    return
                }
                if let rs = result {
                    while rs.next(){
                        var dic = Dictionary<String, AnyObject>()
                        dic["DocEntry"] = rs.int(forColumn: "DocEntry") as AnyObject
                        dic["SlpName"] = rs.string(forColumn: "SlpName") as AnyObject
                        dic["Flags"] = rs.object(forColumn: "Flags") as AnyObject
                        dic["CardCode"] = rs.string(forColumn: "CardCode") as AnyObject
                        dic["CardName"] = rs.string(forColumn: "CardName") as AnyObject
                        dic["Address"] = rs.string(forColumn: "Address") as AnyObject
                        dic["DocDate"] = rs.string(forColumn: "DocDate") as AnyObject
                        dic["PaidSum"] = rs.object(forColumn: "PaidSum") as AnyObject
                        dic["Currency"] = rs.string(forColumn: "Currency") as AnyObject
                        dic["DiscountPer"] = rs.object(forColumn: "DiscountPer") as AnyObject
                        dic["InsertYN"] = rs.string(forColumn: "InsertYN") as AnyObject
                        
                        // QUT1 or NQT1 조회 start
                        var array = Array<Dictionary<String, AnyObject>>()
                        
                        var tableNM = ""
                        if(rs.string(forColumn: "InsertYN") == "Y"){
                            tableNM = "QUT1"
                        } else {
                            tableNM = "NQT1"
                        }
                        let sqlSelect : String = "SELECT ItemCode, Quantity, Price, Currency" +
                                                " FROM " + tableNM +
                                                " WHERE DocEntry = \(rs.int(forColumn: "DocEntry"))"
                        let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
                        guard (result != nil) else {
                            print("error >>>>>>>>>>>> quotationList Item Select")
                            let funcName = "error()"
                            webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                            return
                        }
                        if let rs = result {
                            while rs.next(){
                                var dic = Dictionary<String, AnyObject>()
                                dic["ItemCode"] = rs.string(forColumn: "ItemCode") as AnyObject
                                dic["Quantity"] = rs.object(forColumn: "Quantity") as AnyObject
                                dic["Price"] = rs.object(forColumn: "Price") as AnyObject
                                dic["Currency"] = rs.string(forColumn: "Currency") as AnyObject
                                array.append(dic)
                            }
                        }
                        dic["Item"] = array as AnyObject
                        // QUT1 or NQT1 조회 end
                        
                        list.append(dic)
                    }
                }
                db.close()
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: list as Any)
                    let jsonString = String(data: data, encoding: String.Encoding.utf8)
                    print(jsonString)
                    
                    let funcName = "html('\(jsonString!)', 'N')"
                    webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                } catch {
                    print("catch >>>>>>>>>>>> quotationList Select")
                }
            }
        }
    
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "menu" {
            print(">>> QuotationsController menu <<<")
            
            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            vc.menu(data: message.body as! String)
            self.presentingViewController?.dismiss(animated: true)
        } else if message.name == "quotationDetail" {
            print(">>> QuotationsController quotationDetail <<<")
            
            let funcName = "html('\(qutdata)')"
            self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
        } else if message.name == "moveQuotationsDetailItem" {
            print(">>> QuotationsController moveQuotationsDetailItem <<<")
            
            let localFile = Bundle.main.path(forResource: "quotationsDetailItem", ofType: "html") ?? ""
            let url = URL(fileURLWithPath: localFile)
            let request = URLRequest(url : url)
            webview.load(request)
        } else if message.name == "quotationsDetailItem" {
            print(">>> QuotationsController quotationsDetailItem <<<")
            
            let funcName = "html('\(qutdata)')"
            self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
        } else if message.name == "headerHtml"{
            let myJsFuncName = "headerHtml('\(message.body)','\(loginName)')"
            self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
        } else if message.name == "itemClose" {
            print(">>> QuotationsController itemClose <<<")
            
            let localFile = Bundle.main.path(forResource: "quotationsDetail", ofType: "html") ?? ""
            let url = URL(fileURLWithPath: localFile)
            let request = URLRequest(url : url)
            webview.load(request)
        } else if message.name == "logout"{
            print(">>> QuotationsController logout <<<")
            
            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            vc.logout()
            self.presentingViewController?.dismiss(animated: true)
        } else {
            print(">>> QuotationsController close <<<")

            let presentVC = self.presentingViewController
            guard (presentVC as? ViewController) != nil else {
                return
            }
            self.presentingViewController?.dismiss(animated: false)
        }

    }
}
