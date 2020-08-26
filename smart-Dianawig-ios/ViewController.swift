//
//  ViewController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/06/16.
//  Copyright © 2020 smartdev. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration


class ViewController: UIViewController ,WKUIDelegate, WKNavigationDelegate {


    @IBOutlet weak var webview: WKWebView!
   lazy var progressbar: UIProgressView = UIProgressView()
    
    var network_stat: String = ""
    var nextMessageBody: String = ""
    var nextMessageBodyObj: [String:AnyObject] = [String:AnyObject]()
    
    var commonController: CommonController = CommonController()
    
    var menuName = ""
    
    var loginID: Int = 0
    var loginName :  String = ""
    var check: String = (UserDefaults.standard.object(forKey: "check") != nil) && UserDefaults.standard.object(forKey: "check") as! String == "true" ? "Y" : ""
    var login_fail : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if commonController.connectedToNetwork() {
           network_stat = "Y"
        }else {
            network_stat = "N"
        }
        
        loadLogin()
    }

}

extension ViewController: WKScriptMessageHandler {

    func content() -> WKUserContentController {
        let contentController = WKUserContentController()
        contentController.add(self, name: "loginCheck")
        contentController.add(self, name: "logout")
        contentController.add(self, name: "loginFail")
        contentController.add(self, name: "menu")
        contentController.add(self, name: "headerHtml")
        
        //customer
        contentController.add(self, name: "moveCustomer")
        
        //quotations
        contentController.add(self, name: "quotationList")
        contentController.add(self, name: "moveQuotationDetail")
        //createQuotations
        contentController.add(self, name: "createQuotations")
        
        //A/R Ledger
        contentController.add(self, name: "ARLedgerList")
        
        //Check List
        contentController.add(self, name: "CheckList")
        
        contentController.add(self, name: "resportSalesItem")
        contentController.add(self, name: "getSalesData")
        
        return contentController
    }
    
    // 로그인 화면 전환
 func login_db_check(id: Int, type: String) {
    print("====login_db_check진입 ====");
    //1.네트워크 될 때 - MS-SQL
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        if commonController.connectedToNetwork() {
            var getID : Int = 0
            var rowCnt : Int = 0
            
            do{
                let client = SQLClient.sharedInstance()!
                var id_YN : Int = 0
                client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                    client.execute("SELECT SlpCode,SlpName,EmpID FROM OSLP WHERE SlpCode = \(id)", completion: { results in
                       for table in results as! [[[String:AnyObject]]]{
                           for row in table {
                            rowCnt = row.count as! Int
                                if row.count as! Int == 3 {
                                    for(key,value) in row {
                                        UserDefaults.init()
                                        if key == "SlpCode" {UserDefaults.standard.set(value as! Int, forKey: "SlpCode")}
                                        else if key == "SlpName" { UserDefaults.standard.set(value as! String, forKey: "SlpName") }
                                        else if key == "EmpID" { UserDefaults.standard.set(value as! Int, forKey: "EmpID") }
                                        
                                    }
                                    client.disconnect()
                                }
                           }
                       }
                        if rowCnt == 3{
                            getID = UserDefaults.standard.object(forKey: "SlpCode") as! Int
                            if  getID == id {
                                UserDefaults.standard.set(type as! String, forKey: "check")
                                self.check = "Y"
                                self.login_fail = "N"
                                self.goLoginPage(result: self.check)
                            }else{
                                self.check = "N"
                                self.login_fail = "Y"
                                self.goLoginPage(result: self.check)
                            }
                        }else{
                            self.check = "N"
                            self.login_fail = "Y"
                            self.goLoginPage(result: self.check)
                        }
                   })
                }
            }catch{
                dump(error)
            }
            //return self.check
        } else { //2. 네트워크 안될 때 - SQLite
           print(">>> network - Login  <<<")
            var sqliteController: SQLiteController = SQLiteController()
            let dbPath = sqliteController.dbPath

            //DB 객체 생성
            let database : FMDatabase? = FMDatabase(path: dbPath as String)

            if let db = database {
                var array = Array<Dictionary<String, AnyObject>>()

                db.open()

               let sqlSelect : String = "SELECT SlpCode,SlpName,EmpID FROM OSLP WHERE SlpCode = \(id)"
               let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])

                var getSlpCode : Int = 0
                var getEmpID : Int = 0
                var getSlpName : String = ""
               if let rs = result {
                   while rs.next(){
                    getSlpCode = Int(rs.int(forColumn: "SlpCode"))
                    getEmpID = Int(rs.int(forColumn: "SlpCode"))
                    getSlpName = rs.object(forColumn: "SlpName") as! String
                   
                   }
                    if  getSlpCode == id {
                        UserDefaults.standard.set(getSlpCode as! Int, forKey: "SlpCode")
                        UserDefaults.standard.set(getSlpName, forKey: "SlpName")
                        UserDefaults.standard.set(getEmpID as! Int, forKey: "EmpID")
                        
                        self.check = "Y"
                        self.login_fail = "N"
                        self.goLoginPage(result: self.check)
                    }else{
                        self.check = "N"
                        self.login_fail = "Y"
                        self.goLoginPage(result: self.check)
                    }
                }else{
                    self.check = "N"
                    self.login_fail = "Y"
                    self.goLoginPage(result: self.check)
                }
                db.close()
                
            }
            
        }
       
    }
    // 로그인 화면 전환
    func loadLogin() {
        print("====loadLogin진입 ====");
        var login_Auto: String = ""
        var login_id: Int = 0
       
        login_Auto = UserDefaults.standard.object(forKey: "check") != nil && UserDefaults.standard.object(forKey: "check") as! String == "true" ? "true" : "false"
        login_id = UserDefaults.standard.object(forKey: "SlpCode") != nil ? UserDefaults.standard.object(forKey: "SlpCode") as! Int : 0
        loginID = login_id
        
        if login_Auto == "true" {
            login_db_check(id: login_id, type: login_Auto)
        }else {
            goLoginPage(result: "N")
        }
        
    
       
    }
    
    func goLoginPage(result: String){
    print("====goLoginPage진입 ====");
        var contentController = content()
        var pageNM: String = ""
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController

        print(" result : \(result) , login_fail : \(login_fail)")
        if result == "Y"{
            var checkId = UserDefaults.standard.object(forKey: "SlpName") as! String
            print("checkId :: \(checkId)")
            if checkId == nil || checkId == ""{
                pageNM = "loginForm"
                login_fail = "Y"
                
                webview = WKWebView(frame: view.frame, configuration: configuration)
                webview.autoresizesSubviews = true
                webview.uiDelegate = self
                view.addSubview(webview)
                
                let localFile = Bundle.main.path(forResource: "\(pageNM)", ofType: "html") ?? ""
                let url = URL(fileURLWithPath: localFile)
                let request = URLRequest(url : url)
                webview.load(request)
            }else{
                loginName = UserDefaults.standard.object(forKey: "SlpName") as! String
                
                let login_Auto = UserDefaults.standard.object(forKey: "check") != nil && UserDefaults.standard.object(forKey: "check") as! String == "true" ? "true" : "false"
                if login_Auto == "true" {
                    webview = WKWebView(frame: view.frame, configuration: configuration)
                     webview.autoresizesSubviews = true
                    webview.uiDelegate = self
                    view.addSubview(webview)
                }
                var sqliteController: SQLiteController = SQLiteController()
                sqliteController.createSQLite(webview: webview)
                
            }
        } else if result != "Y" && login_fail == "Y" {
            
            let myJsFuncName = "login_Fail()"
            self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
            
        }else {
            
            webview = WKWebView(frame: view.frame, configuration: configuration)
            webview.uiDelegate = self
            webview.autoresizesSubviews = true
            view.addSubview(webview)
//            
//            // ProgressBar Start
//            self.view.addSubview(self.progressbar)
//            self.progressbar.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addConstraints([
//                self.progressbar.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
//                self.progressbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//                self.progressbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//                
//            ])
//
//            progressbar = commonController.progressBarSetting(progressbar: progressbar)
//            
//            webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
//            // ProgressBar End
//    
            let localFile = Bundle.main.path(forResource: "loginForm", ofType: "html") ?? ""
            let url = URL(fileURLWithPath: localFile)
            let request = URLRequest(url : url)
            webview.load(request)
        }
       
    }
    
    func menu(data: String) {
        let localFile = Bundle.main.path(forResource: data, ofType: "html") ?? ""
        let url = URL(fileURLWithPath: localFile)
        let request = URLRequest(url : url)
        
        webview.load(request)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "SlpCode")
        UserDefaults.standard.removeObject(forKey: "SlpName")
        UserDefaults.standard.removeObject(forKey: "check")
        
        let localFile = Bundle.main.path(forResource: "loginForm", ofType: "html") ?? ""
        let url = URL(fileURLWithPath: localFile)
        let request = URLRequest(url : url)
         webview.autoresizesSubviews = true
        webview.load(request);
    }
    
    func createQuotationSet(data: [String : AnyObject],searchWD: String, customerData: [String : AnyObject]) {
        print(" === createQuotationSet진입 !! === \n \(data)")
        
        setCreateQuotationPage(selectItemList: data,searchWD: searchWD, customerData: customerData);
    }
    func closeCustomer(data: String) {
        let funcName = "customerHtml('\(data)')"
        webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        
        var localFile = ""
        var url: URL = URL(fileURLWithPath: "")
        var request = URLRequest(url : url)
        
        var contentController = content()
        
         if message.name == "loginCheck" {
            var body:[String : AnyObject] = message.body as! [String : AnyObject]
            
            var login_Auto: String = UserDefaults.standard.object(forKey: "check") != nil && UserDefaults.standard.object(forKey: "check") as! String == "true" ? "true" : "false"
            var login_id: Int =  UserDefaults.standard.object(forKey: "SlpCode") != nil ? UserDefaults.standard.object(forKey: "SlpCode") as! Int : 0
            
            var id: Int = 0
            var bodyID : String  = body["id"] as! String
            id = Int(bodyID) ?? 0
//            var pw: String = body["pw"] as! String
            var check : String = body["check"] as! String
             //1. 자동 로그인일 때
            if login_Auto == "true" {
                login_db_check(id: login_id, type: login_Auto)
            }
            //2. 일반 로그인일 떄
            else {
                login_db_check(id: id, type: check)
            }
         } else if message.name == "menu" {
            
            menu(data: message.body as! String)
            
         }else if message.name == "headerHtml" {
            
            if message.body != nil {menuName = message.body as! String}
            
            let myJsFuncName = "headerHtml('\(menuName)','\(loginName)','\(network_stat)')"
            self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
            
        }else if message.name == "moveCustomer" {
            print("=== moveCustomer 진입 ===")
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CustomerController") as! CustomerController
            
            vc.modalPresentationStyle = .fullScreen
            vc.cardData = message.body as! String
            self.present(vc, animated: false, completion: nil)
            
        } else if message.name == "quotationList" {
            
            let quotationsController: QuotationsController = QuotationsController()
            quotationsController.quotationList(dbData: dbData, webview: webview)
            
        } else if message.name == "moveQuotationDetail" {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "QuotationsController") as! QuotationsController
            vc.modalPresentationStyle = .fullScreen
            vc.qutdata = message.body as! String
            self.present(vc, animated: false, completion: nil)
            
        } else if message.name == "ARLedgerList" {
            
            let reportARLedgerController: ReportARLedgerController = ReportARLedgerController()
            reportARLedgerController.ARLedgerList(dbData: dbData, webview: webview, data: message.body as! [String : Any])
            
        } else if message.name == "CheckList" {
            
            let reportCheckListController: ReportCheckListController = ReportCheckListController()
            reportCheckListController.CheckList(dbData: dbData, webview: webview, data: message.body as! [String : Any])
            
        } else if(message.name == "createQuotations"){
            var sqliteController: SQLiteController = SQLiteController()
            var body:[String : AnyObject] = message.body as! [String : AnyObject]
            var funcNM: String = body["funcNM"] as! String
             //let CreateQuotationController: CreateQuotationController = CreateQuotationController()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CreateQuotationController") as! CreateQuotationController
            
            if funcNM == "goSearchItemPage"{
                vc.modalPresentationStyle = .fullScreen
                vc.nextPage = body["pageNM"] as! String
                vc.type = body["type"] as! String
                vc.searchWD = body["searchWD"] as! String
                vc.customerData = body["CustomerData"] as! [String : AnyObject]
                self.present(vc, animated: false, completion: nil)
            }else if (funcNM == "modifyItemList"){
                vc.modalPresentationStyle = .fullScreen
                vc.nextPage = body["pageNM"] as! String
                vc.customerData = body["customerData"] as! [String : AnyObject]
                vc.selectedList = body["selectedItem"] as! String
                vc.type = body["type"] as! String
                self.present(vc, animated: false, completion: nil)
            }else if (funcNM == "createQuotationDone"){
                //Quotation Create 실행
                var customerData = body["customerData"] as! [String : AnyObject]
                var list = body["selectedItemList"] as! [[String : AnyObject]]
                var paidSum :  String = ""
                paidSum = body["paidSum"]! as! String
                
                var formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var currentDate = formatter.string(from:Date())
                
                var network_chk = commonController.connectedToNetwork()
                
                if network_chk{
                    print("=== MSSQL Insert ===")
                    let dbData = commonController.getDBData()
                    let mssqlIP = dbData["mssqlIP"] as! String
                    let mssqlName = dbData["mssqlName"] as! String
                    let mssqlPwd = dbData["mssqlPwd"] as! String
                    let mssqlDb = dbData["mssqlDb"] as! String
                    var maxDocEntry : Int = 0
                    var maxDocNum : Int = 0
                    var sql: String = "";
                    
                    sql = "SELECT MAX(DocEntry)+1 AS DocEntry, MAX(DocNum)+1 as DocNum FROM OQUT"
                    let client1 = SQLClient.sharedInstance()!
                    //let client2 = SQLClient.sharedInstance()!
                    client1.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                        client1.execute(sql, completion: { (_ results: ([Any]?)) in
                            guard (results != nil) else {
                                    print("error >>>>>>>>>>>> quotationList Select")
                                    let funcName = "error()"
                                    self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                                    return
                            }

                          for table in results as! [[[String:AnyObject]]]{
                            for row in table{
                                for (key,value) in row{
                                    if key == "DocEntry" {maxDocEntry = value as! Int }
                                    if key == "DocNum" {maxDocNum = value as! Int}
                                }
                            }
                          }
                            sql  = "INSERT INTO OQUT (DocEntry,DocNum,SlpCode,Flags,CardCode,CardName, Address, DocDate, PaidSum) "
                            sql += "VALUES (\(maxDocEntry),\(maxDocNum),\(self.loginID),1,'\(customerData["cardCode"]!)','\(customerData["cardName"]!)','\(customerData["Address"]!)','\(currentDate)',\(paidSum))"
                            
                            client1.execute(sql, completion: { (_ results: ([Any]?)) in
                                if success {
                                    do{
                                        print("OQUT Insert success : Line 439")
                                    }catch{
                                        print("ERROR Line 460: \(error)")
                                    }
                                }else{
                                    print("Fail!!")
                                }
                                client1.disconnect()
                                self.insertQUT1Data(list: list, DocEntry : maxDocEntry, paidSum : paidSum)
                            })
                        })
                    }
                }else{
                     print(" === SQLite Insert ===")
                     let dbPath = sqliteController.dbPath
                     let database : FMDatabase? = FMDatabase(path: dbPath as String)
                     let dbData = commonController.getDBData()
                     var maxDocEntry : Int = 0
                     var maxDocNum : Int = 0
                     var updateResult : Int = 0
                    
                    if loginID == 0{
                      var myJsFuncName = "reLogin();"
                        self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                    }else{
                        if let db2 = database {
                                     db2.open()
                                     let sqlSelect : String = "SELECT MAX(DocEntry) as DocEntry ,MAX(DocNum) as DocNum FROM NQUT"
                                        let result2 : FMResultSet? = db2.executeQuery(sqlSelect, withArgumentsIn: [])
                                        
                                        if let rs = result2{
                                          while rs.next(){
                                            maxDocEntry = Int(rs.int(forColumn: "DocEntry"))
                                            maxDocNum = Int(rs.int(forColumn: "DocNum"))
                                          }
                                         }
                                       db2.close()
                                }
                                
                                var date = DateFormatter()
                                var cnt: Int = 0
                                var db_success : Bool = false
                                
                                maxDocEntry += 1
                                maxDocNum += 1
                                
                                var sqlInsert  = ""
                                
                                sqlInsert  = "INSERT INTO NQUT (DocEntry,DocNum, SlpCode,Flags,CardCode,CardName,Address,DocDate,PaidSum) "
                                sqlInsert += "VALUES (\(maxDocEntry),\(maxDocNum),\(loginID),1,'\(customerData["cardCode"]!)','\(customerData["cardName"]!)','\(customerData["Address"]!)','\(currentDate)',\(paidSum));"
                               
                                if let NQUT_DB = database {
                                   NQUT_DB.open()
                                    var result : FMResultSet? = NQUT_DB.executeQuery(sqlInsert, withArgumentsIn: [])
                                    do{
                                        db_success = NQUT_DB.executeUpdate(sqlInsert, withArgumentsIn: [])
                                        
                                    }catch{
                                       let myJsFuncName = "DB_INSERT('fail')"
                                       self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                                    }
                                    NQUT_DB.close()
                                }
                                sqlInsert = ""
                                var preEnt : [Int] = []
                                if db_success == true {
                                    if let db = database {
                                      db.open()
                                    
                                      var seq : Int = 1
                                      for var i in list{

                                        sqlInsert = "INSERT INTO NQT1 ( DocEntry, LineNum ,ItemCode, Quantity, Price, Currency)"
                                        sqlInsert += "VALUES (\(maxDocEntry), \(seq) "
                                        if i["itemCode"] != nil {sqlInsert +=  ",'\( i["itemCode"]!)'"} else {sqlInsert +=  ",''"}
                                        if i["selectedQt"] != nil {sqlInsert  +=  ",'\( i["selectedQt"]!)'"} else {sqlInsert +=  ",0 "}
                                        if i["itemPrice"] != nil {sqlInsert  +=  ",'\( i["itemPrice"]!)'"} else {sqlInsert +=  ",0 "}
                                        if i["currency"] != nil {sqlInsert  +=  ",'\( i["currency"]!)'"} else {sqlInsert +=  ",''"}

                                        sqlInsert += ");"
                                        seq += 1
                                      
                                        updateResult = sqliteController.insertSqlite(sqlInsert: sqlInsert)
                                        
                                      }
                                        db.close()
                                    }
                                    
                                    preEnt.append(maxDocEntry)
                                    sqliteController.selectSqlite(sqlSelect: "SELECT DocEntry ,Currency FROM NQT1")
                                    
                                    let myJsFuncName = "DB_INSERT('success')"
                                    self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                                }else{
                                    print("NQUT Insert Fail")
                                    deleteOQUT(DocEntry: maxDocEntry, type: "SQLite",preEnt : preEnt)
                                    let myJsFuncName = "DB_INSERT('fail')"
                                    self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                            }
                               
                        }
                    }
            }
        }else if message.name == "resportSalesItem"{
          let mssqlIP = "10.10.10.120:1433"
          let mssqlName = "wig"
          let mssqlPwd = "smart1234"
          let mssqlDb = "BEAUTY4YOU"
               if network_stat == "Y"{
             let client = SQLClient.sharedInstance()!
                                    //            client.delegate = self
                client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                    client.execute("SELECT ItemCode, REPLACE(REPLACE(ItemName,'+','&#43;'),'\"','&#34;') AS ItemName, OnHand ,LastPurPrc as itemPrice,LastPurCur FROM OITM ", completion: { (_ results: ([Any]?)) in
                      guard (results != nil) else {
                              print("error >>>>>>>>>>>> resportSalesItem Select")
                              let funcName = "error()"
                             self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                              return
                      }
                    for table in results as! [[[String:AnyObject]]]{
                        do {
                            let rawData = try JSONSerialization.data(withJSONObject: table as Any)
                            let jsonString = String(data: rawData, encoding: String.Encoding.utf8)
                            let message = try JSONSerialization.data(withJSONObject: message.body as Any)
                            let messageString = String(data:  message, encoding: String.Encoding.utf8)
                          //let myJsFuncName = "html('\(jsonString!)','\(message.body)')"
                            let myJsFuncName = "html('\(jsonString!)','\(messageString!)')"
                            
                          self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                        } catch {
                          print("ERROR!!!!")
                        }
                      }
                        client.disconnect()
                    })
                }
            }else{
                 print(">>> network - create : fail <<<")
                 var sqliteController: SQLiteController = SQLiteController()
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
                           let rawData = try JSONSerialization.data(withJSONObject: array as Any)
                           let jsonString = String(data: rawData, encoding: String.Encoding.utf8)
                           let message = try JSONSerialization.data(withJSONObject: message.body as Any)
                           let messageString = String(data:  message, encoding: String.Encoding.utf8)
                           let myJsFuncName = "html('\(jsonString!)','\(messageString!)')"
                           self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                     } catch {
                         
                     }
                 }
            }
        }else if message.name == "getSalesData"{
          let mssqlIP = "10.10.10.120:1433"
          let mssqlName = "wig"
          let mssqlPwd = "smart1234"
          let mssqlDb = "BEAUTY4YOU"
             if network_stat == "Y"{
                 let client = SQLClient.sharedInstance()!
                                        //            client.delegate = self
                    client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                        client.execute("SELECT ItemCode FROM OITM ", completion: { (_ results: ([Any]?)) in
                            guard (results != nil) else {
                               print("error >>>>>>>>>>>> getSalesData Select")
                               let funcName = "error()"
                               self.webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                               return
                            }
                             for table in results as! [[[String:AnyObject]]]{

                            do {
                                let rawData = try JSONSerialization.data(withJSONObject: table as Any)
                                let jsonString = String(data: rawData, encoding: String.Encoding.utf8)
                                let message = try JSONSerialization.data(withJSONObject: message.body as Any)
                                let messageString = String(data:  message, encoding: String.Encoding.utf8)
                              //let myJsFuncName = "html('\(jsonString!)','\(message.body)')"
                                let myJsFuncName = "html('\(jsonString!)','\(messageString!)')"
                                self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                            } catch {
                              print("ERROR!!!!")
                            }
                          }
                            client.disconnect()
                        })
                    }
            }else{
                print(">>> network - create : fail <<<")
                var sqliteController: SQLiteController = SQLiteController()
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
                                let rawData = try JSONSerialization.data(withJSONObject: array as Any)
                                let jsonString = String(data: rawData, encoding: String.Encoding.utf8)
                                let message = try JSONSerialization.data(withJSONObject: message.body as Any)
                                let messageString = String(data:  message, encoding: String.Encoding.utf8)
                                let myJsFuncName = "html('\(jsonString!)','\(messageString!)')"
                                self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
                          } catch {
                              
                          }
                      }
            }
        }else if message.name == "logout"{
            UserDefaults.standard.removeObject(forKey: "SlpCode")
            UserDefaults.standard.removeObject(forKey: "check")
                     
            let localFile = Bundle.main.path(forResource: "loginForm", ofType: "html") ?? ""
            let url = URL(fileURLWithPath: localFile)
            let request = URLRequest(url : url)
            webview.load(request);

         }else {
            loadLogin()
        }
        
    }
    func setCreateQuotationPage(selectItemList : [String:AnyObject],searchWD: String, customerData: [String:AnyObject]){
        do{
            print(" === setCreateQuotationPage 진입 !! === \n \(selectItemList)")
                
                let itemList = try JSONSerialization.data(withJSONObject: selectItemList["selectItem"]!)
                
                let customerData = try JSONSerialization.data(withJSONObject: customerData)
                let itemJsonString = String(data: itemList,encoding: String.Encoding.utf8)
                let customerJsonString = String(data: customerData,encoding: String.Encoding.utf8)
                let myJsFuncName = "setPage('\(itemJsonString!)','\(customerJsonString!)')"
                
                self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
            
               }catch{

            }
    }
//    func close_Storyboard(){
//        let storyboard = UIStoryboard(name: "sub", bundle: nil)
//        let nextView = storyboard.instantiateViewController(withIdentifier: "createQuotationController")
//        self.present(nextView, animated: true, completion: nil)
//    }
//
  // 진입 시 NQUT Table Insert
//    func insertQuotation(){
//          print("=== insertQuotation 진입 ===")
//          let dbData = commonController.getDBData()
//          let mssqlIP = dbData["mssqlIP"] as! String
//          let mssqlName = dbData["mssqlName"] as! String
//          let mssqlPwd = dbData["mssqlPwd"] as! String
//          let mssqlDb = dbData["mssqlDb"] as! String
//
//        var docEntry: Int = 0
//        var docNum: Int = 0
//            //DB 객체 생성
//        var array = Array<Dictionary<String, AnyObject>>()
//        if commonController.connectedToNetwork() {
//            let client = SQLClient.sharedInstance()!
//            client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
//                client.execute("SELECT  MAX(DocNum) AS DocNum , MAX(DocEntry) AS DocEntry FROM OQUT", completion: { (_ results: ([Any]?)) in
//                    guard (results != nil) else {
//                        print("error >>>>>>>>>>>> insertQuotation Select")
//                        return
//                    }
//                    for table in results as! [[[String:AnyObject]]]{
//                        for raw in table{
//                            for (key,value) in raw{
//                                if key == "DocEntry" {docEntry = value as! Int}
//                                else if key == "DocNum" {docNum = value as! Int}
//                            }
//                        }
//                    }
//                client.disconnect()
//
//                self.insertQuotation2(docEntry: docEntry,docNum: docNum)
//                }) // end of client.excute completion
//
//            }
//        }
//    }
    func insertQuotation(){
          print("=== insertQuotation 진입 ===")
          let dbData = commonController.getDBData()
          let mssqlIP = dbData["mssqlIP"] as! String
          let mssqlName = dbData["mssqlName"] as! String
          let mssqlPwd = dbData["mssqlPwd"] as! String
          let mssqlDb = dbData["mssqlDb"] as! String
              
        var docEntry: Int = 0
        var docNum: Int = 0
        
        if commonController.connectedToNetwork() {
            let client = SQLClient.sharedInstance()!
            client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                client.execute("SELECT MAX(DocNum) AS DocNum , MAX(DocEntry) AS DocEntry FROM OQUT", completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("error >>>>>>>>>>>> insertQuotation Select")
                        return
                    }
                    for table in results as! [[[String:AnyObject]]]{
                        for raw in table{
                            for (key,value) in raw{
                                if key == "DocEntry" {docEntry = value as! Int}
                                else if key == "DocNum" {docNum = value as! Int}
                                print("@@>>>>>>>>>>>>>>max 조회 end \n docEntry : \(docEntry) / docNum : \(docNum) ")
                            }
                        }
                    }
                    
                    var sqliteController: SQLiteController = SQLiteController()
                    let dbPath = sqliteController.dbPath
                    let database : FMDatabase? = FMDatabase(path: dbPath as String)

                    if let db = database {
                        db.open()
                        let sqlSelect : String = "SELECT DocEntry ," +
                                                "DocEntry , " +
                                                "SlpCode , " +
                                                "Flags , " +
                                                "N.CardCode as CardCode , " +
                                                "S.CardName as CardName, " +
                                                "CASE WHEN S.Address == '' then '' WHEN S.Address is null then '' ELSE S.Address End as Address, " +
                                                "DocDate , " +
                                                "PaidSum " +
                                                "FROM NQUT N " +
                                                "LEFT JOIN (SELECT CardName, Address, CardCode FROM OCRD)S ON N.CardCode = S.CardCode "

                        let client = SQLClient.sharedInstance()!
                        var result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])

                        if let rs = result {
                            while rs.next(){
                                docEntry += 1
                                docNum += 1
                                
                                var maxDocEntry: Int = 0
                                maxDocEntry = docEntry
                                
                                var preEnt : Int = 0
                                preEnt = Int(rs.int(forColumn: "DocEntry"))
                                
                                let sqlCode = rs.int(forColumn: "SlpCode") == nil ? -1 : rs.int(forColumn: "SlpCode")
                                let CardCode : String = rs.object(forColumn: "CardCode") == nil ? "" : rs.object(forColumn: "CardCode")! as! String
                                let CardName : String = rs.object(forColumn: "CardName") == nil ? "" : rs.object(forColumn: "CardName")! as! String
                                print("adrress >>\(rs.object(forColumn: "Address")!)")
                                let Address : String = rs.string(forColumn: "Address")! == "<null>" || rs.object(forColumn: "Address") == nil ? "''" : rs.object(forColumn: "Address")! as! String
                                let DocDate = rs.object(forColumn: "DocDate")!
                                let PaidSum = rs.int(forColumn: "PaidSum")
                                let sql = "INSERT INTO OQUT (DocEntry,DocNum,SlpCode,Flags,CardCode,CardName,Address,DocDate,PaidSum) " +
                                "VALUES ( \(docEntry),\(docNum),\(sqlCode) ,1 , '\(CardCode)'," +
                                "'\(CardName)', \(Address), '\(DocDate)'," +
                                "\(PaidSum))"
                                print(sql)
                                sqliteController.insertSqlite(sqlInsert: sql)
                                client.execute(sql, completion: { (_ results: ([Any]?)) in
                                    print(">>>>>>>OQUT results :\(results)")
                                    
                                    db.open()
                                    var sqlSelect2 = "SELECT (SELECT MAX(LineNum) AS MaxLineNum FROM NQT1 WHERE DocEntry = \(preEnt)) AS MaxLineNum, DocEntry, LineNum, ItemCode, Quantity, Price, Currency FROM NQT1 WHERE DocEntry = \(preEnt) ORDER BY LineNum"
                                    
                                    var lineNum = 0
                                    let result2 : FMResultSet? = db.executeQuery(sqlSelect2, withArgumentsIn: [])
                                    if let rs2 = result2 {
                                        while rs2.next(){
                                            do{
                                                print("@@>>>while start")
                                                lineNum += 1
                                                var sql_dic = Dictionary<Int, String>()
                                                
                                                let MaxLineNum = rs2.int(forColumn: "MaxLineNum")
                                                print(">>>MaxLineNum: \(MaxLineNum)")
                                                let ItemCode = rs2.object(forColumn: "ItemCode")!
                                                let Quantity = rs2.int(forColumn: "Quantity")
                                                let Price = rs2.string(forColumn: "Price")!
                                                let Currency = rs2.object(forColumn: "Currency")!
                                                let itemCode = rs2.string(forColumn: "ItemCode") as AnyObject
                                                print("preEnt : \(preEnt), docEntry : \(docEntry), maxDocEntry : \(maxDocEntry)")
                                                
                                                var lineNum2 = lineNum
                                                let sql2 = "INSERT INTO QUT1 (DocEntry,LineNum,ItemCode,Quantity,Price,Currency) " +
                                                "VALUES ( \(maxDocEntry) ,\(lineNum)" +
                                                " ,'\(ItemCode)',\(Quantity)" +
                                                " ,\(Price) ,'\(Currency)')"
                                                print(sql2)
                                               // sqliteController.insertSqlite(sqlInsert: sql2)
                                                client.execute(sql2, completion: {(_ results: ([Any]?)) in
                                                    print(">>>>>>>QUT1 results :\(results)")
                                                    print(preEnt)
                                                    print(lineNum2)
                                                    if MaxLineNum == lineNum2 {
                                                        db.open()
                                                        print(">>preEnt",preEnt)
                                                        var result = db.executeUpdate("DELETE FROM NQUT WHERE DocEntry = \(preEnt)", withArgumentsIn: [])
                                                        print(">>result1",result)
                                                        var result2 = db.executeUpdate("DELETE FROM NQT1 WHERE DocEntry = \(preEnt)", withArgumentsIn: [])
                                                        print(">>result2",result2)
                                                        db.close()
                                                    }
                                                })
                                            }catch{
                                                print("INSERT ERROR : Line 826")
                                                print(error)
                                            }
                                            print("@@>>>while end")
                                        }// End of -While rs2-
                                    } // End of - if let rs2 = result2 {-
                                    
                                    db.close()

                                })
                            }
                        }// End of - if let rs = result -
                        db.close()
                    }
                    client.disconnect()
                }) // end of client.excute completion
               
            }
        }
    }
    func insertQuotation2(docEntry : Int ,docNum : Int){
        print("=== insertQuotation2 진입 ===")
        var sqliteController: SQLiteController = SQLiteController()
        let dbPath = sqliteController.dbPath
        let database : FMDatabase? = FMDatabase(path: dbPath as String)
        let dbData = commonController.getDBData()
        

        var maxDocEntry = docEntry
        var maxDocNum = docNum

        var array = Array<Dictionary<String, Int>>()
        var oqut_sql_array = Array<Dictionary<Int, String>>()
        var qut1_sql_array = Array<Dictionary<Int, String>>()
        if let db = database {
            db.open()
            let sqlSelect : String = "SELECT DocEntry ," +
                                    "DocEntry , " +
                                    "SlpCode , " +
                                    "Flags , " +
                                    "N.CardCode as CardCode , " +
                                    "S.CardName as CardName, " +
                                    "S.Address as Address, " +
                                    "DocDate , " +
                                    "PaidSum " +
                                    "FROM NQUT N " +
                                    "LEFT JOIN (SELECT CardName, Address, CardCode FROM OCRD)S ON N.CardCode = S.CardCode "

            var sql :  String = ""
            var oqut_sql :  String = ""
            let client = SQLClient.sharedInstance()!
            var result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
            var dic = Dictionary<String, Int>()
            var sql_dic = Dictionary<Int, String>()
            var preEnt_array : [Int]  = []
            
                if let rs = result {
                    while rs.next(){
                        maxDocEntry += 1
                        maxDocNum += 1

                        dic = [:]
                        sql_dic = [:]
                        var preEnt : Int = 0
                        preEnt = Int(rs.int(forColumn: "DocEntry"))

                        let sqlCode = rs.int(forColumn: "SlpCode")
                        let CardCode = rs.object(forColumn: "CardCode")!
                        let CardName = rs.object(forColumn: "CardName")!
                        let Address = rs.object(forColumn: "Address")!
                        let DocDate = rs.object(forColumn: "DocDate")!
                        let PaidSum = rs.int(forColumn: "PaidSum")

                        oqut_sql = "INSERT INTO OQUT (DocEntry,DocNum,SlpCode,Flags,CardCode,CardName,Address,DocDate,PaidSum) " +
                                    "VALUES ( \(maxDocEntry),\(maxDocNum),\(sqlCode) ,1 , '\(CardCode)'," +
                                    "'\(CardName)', '\(Address)', '\(DocDate)'," +
                                    "\(PaidSum) ); "
                        
                        dic["maxDocEntry"] = maxDocEntry as! Int
                        dic["preEnt"] = preEnt as! Int
                        
                        sql_dic[maxDocEntry] = oqut_sql
                        
                        array.append(dic)
                        oqut_sql_array.append(sql_dic)
                    }
                }// End of - if let rs = result -
                
                sql = ""
                var preEnt = 0
                for row in array{
                    print("row : \(row)")
                     var sqlSelect2 = ""
                    for (key, value) in row {
                       
                        if key == "preEnt" {
                            preEnt = value
                        }else if key == "maxDocEntry" {
                            maxDocEntry = value
                        }
                    } // End of ror (key, value) in row
                        sqlSelect2 = "SELECT DocEntry, LineNum, ItemCode, Quantity, Price, Currency FROM NQT1 WHERE DocEntry = "
                        sqlSelect2 += "\(preEnt)"
                    preEnt_array.append(preEnt)
                        var lineNum = 1
                        let result2 : FMResultSet? = db.executeQuery(sqlSelect2, withArgumentsIn: [])
                        if let rs2 = result2 {
                            while rs2.next(){
                                do{
                                    var sql_dic = Dictionary<Int, String>()
                                    
                                    let ItemCode = rs2.object(forColumn: "ItemCode")!
                                    let Quantity = rs2.int(forColumn: "Quantity")
                                    let Price = rs2.string(forColumn: "Price")!
                                    let Currency = rs2.object(forColumn: "Currency")!
                                    let itemCode = rs2.string(forColumn: "ItemCode") as AnyObject
                                    print("preEnt : \(preEnt), maxDocEntry : \(maxDocEntry)")
                                    sql = "INSERT INTO QUT1 (DocEntry,LineNum,ItemCode,Quantity,Price,Currency) " +
                                    "VALUES ( \(maxDocEntry) ,\(lineNum)" +
                                    " ,'\(ItemCode)',\(Quantity)" +
                                    " ,\(Price) ,'\(Currency)');"
                                    lineNum += 1
                                    //let maxDocEntry_str : String = maxDocEntry as! String
                                    sql_dic[maxDocEntry] = sql
                                   
                                      qut1_sql_array.append(sql_dic)
                                }catch{
                                    print("INSERT ERROR : Line 826")
                                    print(error)
                                }
                            }// End of -While rs2-
                        } // End of - if let rs2 = result2 {-
                    
                }// End of -for row in array-
            print("oqut_sql_array")
            print(oqut_sql_array)
            mssql_insert(oqut : oqut_sql_array, qut1 : qut1_sql_array, array: array , preEnt : preEnt_array)
                
            }
    }
    
    func mssql_insert(oqut : Array<Dictionary<Int, String>>, qut1 :Array<Dictionary<Int, String>> ,array : Array<Dictionary<String, Int>>, preEnt : [Int]){
        print("=== mssql_insert 진입 === ")
        print(oqut)
        print(qut1)
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        do{
            let client = SQLClient.sharedInstance()!
            var maxDocEntry: Int = 0
            var sql : String = ""
            
            client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                for row in oqut{
                    for (key,value) in row{
                         maxDocEntry = key
                         sql = value
                    }
                    do{
                        var qut_maxDocEntry : Int = 0
                        var qut_sql : String = ""
                        for row in qut1{
                            for (key,value) in row{
                                qut_maxDocEntry = key
                                qut_sql = value
                            }
                            if maxDocEntry == qut_maxDocEntry {
                                sql += qut_sql
                            }
                        }
                        print("1. SQL :: \(sql)")
                    }catch{
                        print("ERROR :: \(error)")
                    }
                    do{
                       client.execute(sql, completion: { (_ results: ([Any]?)) in
                           print("results :\(results)")
                       })
                       print("2. SQL :: \(sql)")
                       self.InsertSqlite(OQUT : sql ,QUT1 : "", maxDocEntry : maxDocEntry , type : "quatationInsert" ,preEnt : preEnt)
                     
                    }catch{
                      print(error)
                      self.deleteOQUT(DocEntry : maxDocEntry, type : "MSSQL",preEnt : preEnt)
                    }
                }
                
               client.disconnect()
            }
        }catch{
            print(error)
        }
        
    }
    
    //QUT1 DB 만 저장
    func insertQUT1Data(list : [[String : AnyObject]] ,DocEntry : Int, paidSum : String){
        print("=== insertQUT1Data 진입 ===")
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        
        print("paidSum>>>\(paidSum)")
        
        var sql: String = ""
        var cnt : Int = 1
        var lastCnt = 0
        
        for var i in list{
            lastCnt = list.count
            sql += "INSERT INTO QUT1 ( DocEntry, LineNum ,ItemCode, Quantity, Price, Currency)"
            sql += "VALUES (\(DocEntry), \(cnt) "
            sql  +=  ",'\( i["itemCode"]!)'"
            sql  +=  ",'\( i["selectedQt"]!)'"
            sql  +=  ",'\( i["itemPrice"]!)'"
            sql  +=  ",'\( i["currency"]!)'"
            sql += ");"
            
            cnt += 1
            lastCnt += 1
        }
        
       var db_success = 0
       var check_Cnt = 0
       let client = SQLClient.sharedInstance()!
       client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
        client.execute(sql, completion: { (_ results: ([Any]?)) in
           print(sql)
           var type = "Fail"
           if results == nil {
                type = "Fail"
                print("OQT1 Insert Fail : \(results)")
           }else{
                type = "success"
                print("OQT1 Insert Success : \(results)")
           }
                
           let myJsFuncName = "DB_INSERT('\(type)')"
           self.webview.evaluateJavaScript(myJsFuncName) { (result, error) in if let result = error{ print(result) } }
            
        })
        client.disconnect()
        }
        print("!!END!!")
    }
    

    func InsertSqlite(OQUT : String ,QUT1 : String, maxDocEntry : Int, type : String, preEnt : [Int]){
        print("===InsertSqlite 진입===\(type)")
        print(OQUT)
         let sqliteController : SQLiteController = SQLiteController()
         let dbPath = sqliteController.dbPath
         let database : FMDatabase? = FMDatabase(path: dbPath as String)
         let dbData = commonController.getDBData()
         
        if let db = database {
           db.open()
           var result = db.executeUpdate(OQUT, withArgumentsIn: [])
           print("SQLite Insert 결과 !!!\(result)")
            if type == "quatationInsert"{
                if result {
                    print("qutation_Insert OQUT SUCCESS : \(OQUT)")
                //    deleteOQUT(DocEntry: maxDocEntry, type: "quatationInsert", preEnt: preEnt)
                    sqliteController.selectSqlite(sqlSelect: "SELECT DocEntry FROM OQUT")
                }else{
                    print("qutation_Insert OQUT Fail!! \n \(OQUT)")
                  //  deleteOQUT(DocEntry: maxDocEntry, type: "MSSQL", preEnt: preEnt)
                    sqliteController.selectSqlite(sqlSelect: "SELECT DocEntry FROM OQUT")
                }
                
                
            }else{
                do{
                  // var db_success = db.executeUpdate(sqlInsert, withArgumentsIn: [])
                   if(result == true){
                       if let db2 = database {
                          db2.open()
                           var result2 = db2.executeUpdate(QUT1, withArgumentsIn: [])
                           do{
                              print(QUT1)
                              print("Sqlite QUT1 Success \(result2)")
                              deleteOQUT(DocEntry: maxDocEntry, type: "quatationInsert", preEnt : preEnt)
                              sqliteController.selectSqlite(sqlSelect: "SELECT DocEntry FROM OQUT")
                           }catch{
                              print("Sqlite QUT1 Fail")
                           }
                             db2.close()
                       }
                   }else{
                       
                   }
               }catch{
                   print("Sqlite OQUT Fail")
               }
            }
              db.close()
        }else{
            print("SQLite Insert 실패 ! 연결 안됨")
        }
    }

    func deleteOQUT(DocEntry : Int, type : String , preEnt : [Int]){
        print("=== deleteOQUT 진입 === ")
        let sqliteController : SQLiteController = SQLiteController()
        let dbPath = sqliteController.dbPath
        let database : FMDatabase? = FMDatabase(path: dbPath as String)
        let dbData = commonController.getDBData()
        
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        
        if type == "MSSQL"{
            print("\n *******************")
            print("MSSQL진입 !")
            let sql : String = "DELETE FROM OQUT WHERE DocEntry = \(DocEntry); DELETE FROM QUT1 WHERE DocEntry = \(DocEntry);"
            print(sql)
            print("\n *******************")
            let client = SQLClient.sharedInstance()!
               client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
               client.execute(sql, completion: { (_ results: ([Any]?)) in
                   
               })
               client.disconnect()
               
            }
        }else if type == "quatationInsert"{ // SQLite 삭제
            print("=== quatationInsert 진입 ===")
            if let db = database {
               db.open()
               var sql : String = ""
                print(" preEnt: \(preEnt)")
               for row in preEnt {
                    print(" row : \(row)")
                    sql = "DELETE FROM NQUT WHERE DocEntry = \(row);"
                   
                   do{
                        var result = db.executeUpdate(sql, withArgumentsIn: [])
                        sql = "DELETE FROM NQT1 WHERE DocEntry = \(row);"
                        result = db.executeUpdate(sql, withArgumentsIn: [])
                        print("SQLite NQUT/NQT1 DELETE 결과  :: \(result)")
                   }catch{
                        deleteOQUT(DocEntry : row, type : "MSSQL" , preEnt : preEnt)
                   }
               }
               db.close()
            }
        }else { // SQLite 삭제
             print("=== SQLite Delete 진입 ===")
            if let db = database {
               db.open()
               var sql : String = ""
               
               sql = "DELETE FROM NQUT WHERE DocEntry = \(DocEntry);"
               var result = db.executeUpdate(sql, withArgumentsIn: [])
               print("SQLite 결과 : \(result), SQL : \(sql)")
                do{
                    var db_success = db.executeUpdate(sql, withArgumentsIn: [])
                    if(result == true){
                        print("Sqlite QUT1 DB delete Success \(result)")
                        if let db2 = database {
                           db2.open()

                            let sql2 : String = "DELETE FROM NQT1 WHERE DocEntry = \(DocEntry)"
                            var result = db.executeUpdate(sql2, withArgumentsIn: [])
                            do{
                               print("Sqlite QUT1 DB delete Success \(result)")
                            }catch{
                               print("Sqlite QUT1 Fail")
                            }

                            sqliteController.selectSqlite(sqlSelect: "SELECT DocEntry FROM NQUT")
                            db2.close()
                        }
                    }
                }catch{
                    print("Sqlite OQUT Fail")
                }
                  db.close()
            }
        }
        
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


