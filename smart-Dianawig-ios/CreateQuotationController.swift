//
//  createQuotationController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/06/18.
//  Copyright © 2020 smartdev. All rights reserved.
//


import Foundation
import UIKit
import WebKit
import SystemConfiguration


class CreateQuotationController: UIViewController, WKUIDelegate
{
    @IBOutlet weak var webview: WKWebView!
    lazy var progressbar: UIProgressView = UIProgressView()

    //공통 함수 컨트롤러
    let commonController: CommonController = CommonController()
    var sqliteController: SQLiteController = SQLiteController()
    
    static let sharedInstance = CreateQuotationController()
    
    var nextPage: String = ""
    
    var messageBody: [String : AnyObject] = [String : AnyObject]()
    
    var selectedList : String = ""
    
    var type : String = ""
    
    var searchWD : String = ""
    var customerData : [String : AnyObject] = [String : AnyObject]()

    
               
    
    var network_stat : String = "N"
    var loginID : Int = UserDefaults.standard.value(forKey: "SlpCode") as! Int
    var slpName : String = UserDefaults.standard.value(forKey: "SlpName") as! String
    override func viewDidLoad() {
    super.viewDidLoad()
    print("#################createQuotationController#################")

    // self.presentingViewController?.dismiss(animated: true, completion: nil)
    if commonController.connectedToNetwork() {
        network_stat = "Y"
    }else {
        network_stat = "N"
    }
        
    let contentController = WKUserContentController()
    contentController.add(self, name: "customerList")
    contentController.add(self, name: "menu")
    
    contentController.add(self, name: "SelectItemList")
    contentController.add(self, name: "selectItemPage")
    contentController.add(self, name: "selectItemPageInit")
    contentController.add(self, name: "selectItemDone")
    contentController.add(self, name: "gobackPage")
    
        contentController.add(self, name: "headerHtml")
    contentController.add(self, name: "logout")
        
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
        
    let localFile = Bundle.main.path(forResource: nextPage, ofType: "html") ?? ""
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
extension CreateQuotationController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String

        if message.name == "headerHtml"{
            
            let myJsFuncName = "headerHtml('\(message.body)','\(slpName)','\(network_stat)')"
            self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
            
        } else if message.name == "menu" {
           
           let presentVC = self.presentingViewController
           guard let vc = presentVC as? ViewController else {
               return
           }
           vc.menu(data: "createQuotations")
           self.presentingViewController?.dismiss(animated: true)
                
        }else if message.name == "SelectItemList" {
            if network_stat == "Y"{
                let client = SQLClient.sharedInstance()!
                client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                  client.execute("SELECT ItemCode, REPLACE(REPLACE(ItemName,'+','&#43;'),'\"','&#34;') AS ItemName, OnHand ,LastPurPrc,LastPurCur FROM OITM ", completion: { (_ results: ([Any]?)) in
                      guard (results != nil) else {
                            print("error >>>>>>>>>>>> quotationList Select")
                            let funcName = "error()"
                            self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                              return
                      }
                    for table in results as! [[[String:AnyObject]]]{
                      do {
                            print("MSSQL >> \(table)")
                            let rawData = try JSONSerialization.data(withJSONObject: table as Any)
                            let jsonString = String(data: rawData, encoding: String.Encoding.utf8)
                        
                            //let myJsFuncName = "html('\(jsonString!)','\(message.body)')"
                            let body = try JSONSerialization.data(withJSONObject: message.body)
                            let bodyJsonString = String(data: body,encoding: String.Encoding.utf8)
                            let myJsFuncName = "html('\(jsonString!)','\(bodyJsonString!)','\(self.searchWD)')"
                         
                        self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                      } catch {
                        print("ERROR!!!!")
                      }
                    }
                      client.disconnect()
                     
                  })
                }
           }else {
                let dbPath = sqliteController.dbPath
            
                //DB 객체 생성
                let database : FMDatabase? = FMDatabase(path: dbPath as String)
                
                if let db = database {
                    var array = Array<Dictionary<String, AnyObject>>()
                    
                    db.open()
                    
                    let sqlSelect : String = "SELECT ItemCode, ItemName , OnHand ,REPLACE(LastPurCur,'-11','$') as LastPurCur,LastPurPrc FROM OITM"
                    //let sqlSelect : String = "SELECT ItemCode, REPLACE(REPLACE(ItemName,'+','&#43;'),'\"','&#34;') AS ItemName, OnHand ,LastPurPrc,LastPurCur FROM OITM"
                    let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
                    
                    if let rs = result {
                        while rs.next(){
                            print("\n",rs.int(forColumn: "LastPurPrc"))
                            var dic = Dictionary<String, AnyObject>()
                            dic["ItemCode"] = rs.string(forColumn: "ItemCode") as AnyObject
                            dic["ItemName"] = rs.string(forColumn: "ItemName") as AnyObject
                            dic["OnHand"] = rs.int(forColumn: "OnHand") as AnyObject
                            dic["LastPurPrc"] = rs.int(forColumn: "LastPurPrc") as AnyObject
                            dic["LastPurCur"] = rs.string(forColumn: "LastPurCur") as AnyObject
                            array.append(dic)
                        }
                    }
                    db.close()
                    
                    do {
                        dump(array)
                        let body = try JSONSerialization.data(withJSONObject: message.body)
                        let bodyJsonString = String(data: body,encoding: String.Encoding.utf8)
                        let data = try JSONSerialization.data(withJSONObject: array as Any)
                        let jsonString = String(data: data, encoding: String.Encoding.utf8)
                        let myJsFuncName = "html('\(jsonString!)','\(bodyJsonString!)','\(self.searchWD)')"
                        webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                    } catch {
                        
                    }
                }
            }
        } else if message.name == "selectItemPage"{
            print("==== selectItemPage ===")
            do{
               
                messageBody = message.body as! [String:AnyObject]
                print("messageBody ::\(messageBody)")
                let localFile = Bundle.main.path(forResource: "createQuotationSelectItem", ofType: "html") ?? ""
                let url = URL(fileURLWithPath: localFile)
                let request = URLRequest(url : url)
                webview.load(request)
                
            }catch{
                print(error)
            }
            
        } else if message.name == "selectItemPageInit"{
            do{
                if type != "selected"{
                    selectedList = messageBody["selectItemList"] as! String
                    type = messageBody["type"] as! String
                }
                let myJsFuncName = "selectSetPage('\(selectedList)','\(type)')"
                
                self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
            }catch{
                print(error)
            }
        }else if message.name == "selectItemDone"{
            print("selectItemDone진입 ")
            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            print(message.body)
            messageBody = message.body as! [String : AnyObject]
            vc.nextMessageBodyObj = messageBody
            vc.createQuotationSet(data: messageBody,searchWD : searchWD, customerData:customerData)
            self.presentingViewController?.dismiss(animated: true)
            
        }else if message.name == "gobackPage"{
            print(" === gobackPage 진입 ===")
            let presentVC = self.presentingViewController
            guard let vc = presentVC as? ViewController else {
                return
            }
            print(message.body)
            messageBody = message.body as! [String : AnyObject]
            print(messageBody["selectItem"]!)
            
            vc.createQuotationSet(data: messageBody,searchWD : searchWD, customerData:customerData)
            self.presentingViewController?.dismiss(animated: true)
        }else if message.name == "logout"{
              UserDefaults.standard.removeObject(forKey: "SlpCode")
              UserDefaults.standard.removeObject(forKey: "type")
              
              let localFile = Bundle.main.path(forResource: "loginForm", ofType: "html") ?? ""
              let url = URL(fileURLWithPath: localFile)
              let request = URLRequest(url : url)
              webview.load(request);
        }
    }
}
