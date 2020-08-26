//
//  ReportARLedgerController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/06/30.
//  Copyright © 2020 smartdev. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class ReportARLedgerController: UIViewController, WKUIDelegate
{
    var commonController: CommonController = CommonController()
    var sqliteController: SQLiteController = SQLiteController()
    
    
    func ARLedgerList(dbData: Dictionary<String, Any>, webview: WKWebView, data: [String : Any]) {
        print(">>> ReportARLedgerController ARLedgerList <<<")
        
        let cardCode = data["cardCode"] as? String
        let startDate = data["startDate"] as? String
        let endDate = data["endDate"] as? String

        if commonController.connectedToNetwork() {
            print(">>> network - ARLedgerList : success <<<")

            let client = SQLClient.sharedInstance()!
//            client.delegate = self
            client.connect(dbData["mssqlIP"] as! String, username: dbData["mssqlName"] as! String, password: dbData["mssqlPwd"] as! String, database: dbData["mssqlDb"] as! String) { success in
                client.execute(
                    "WITH ARLG_SEARCH (" +
                        "INV, GB, SEQ, CardCode," +
                        "DocDate," +
                        "Term, Amount, Paid, Balance," +
                        "IP1, IP2, Remarks1, Remarks2, LastBalance" +
                    ") " +
                    "AS " +
                    "(" +
                        "SELECT " +
                            "INV, GB, SEQ, CardCode, " +
                            "CONVERT(VARCHAR(10), DocDate, 23) AS DocDate, Term, " +
                            "Amount, Paid, Balance, " +
                            "IP1, IP2, Remarks1, Remarks2, " +
                            "(" +
                                "SELECT Balance " +
                                "FROM (SELECT INV, MAX(SEQ) AS SEQ FROM ARLG WHERE GB='RCV' GROUP BY INV) C " +
                                "    INNER JOIN (SELECT * FROM ARLG WHERE GB='RCV' AND INV = A.INV) D ON C.INV = D.INV AND C.SEQ = D.SEQ" +
                            ") AS LastBalance " +
                        "FROM ARLG A " +
                        "WHERE GB = 'INV' " +
                            "AND CardCode = '" + cardCode! + "' " +
                            "AND (CONVERT(int, REPLACE(CONVERT(VARCHAR(10), DocDate, 121), '-', '')) " +
                                "BETWEEN REPLACE('" + startDate! + "', '/', '') AND REPLACE('" + endDate! + "', '/', ''))" +
                    ") " +

                    "SELECT * " +
                    "FROM ARLG_SEARCH " +
                    "UNION ALL " +
                    "SELECT " +
                        "INV, GB, SEQ, CardCode, " +
                        "CONVERT(VARCHAR(10), DocDate, 23) AS DocDate, Term, " +
                        "Amount, Paid, Balance, " +
                        "IP1, IP2, Remarks1, Remarks2, '0.00' AS LastBalance " +
                    "FROM ARLG " +
                    "WHERE GB = 'RCV' " +
                        "AND INV IN (SELECT INV FROM ARLG_SEARCH) " +
                    "ORDER BY INV DESC, GB, SEQ"
                    , completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("error >>>>>>>>>>>> ARLedgerList Select")
                        let funcName = "error()"
                        webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                        return
                    }
                    for table in results as! [[[String:AnyObject]]] {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: table as Any)
                            let jsonString = String(data: data, encoding: String.Encoding.utf8)
                            print(jsonString)
                            let funcName = "html('\(jsonString!)', 'Y')"
                            webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                        } catch {
                            print("catch >>>>>>>>>>>> ARLedgerList Select")
                        }
                    }
                    client.disconnect()
                })
            }
        } else {
            print(">>> network - ARLedgerList : fail <<<")
                
            let dbPath = sqliteController.dbPath
            //DB 객체 생성
            let database : FMDatabase? = FMDatabase(path: dbPath as String)
            
            if let db = database {
                var array = Array<Dictionary<String, AnyObject>>()
                
                db.open()
                
                let sqlSelect : String = "WITH ARLG_SEARCH (" +
                                            "INV, GB, SEQ, CardCode," +
                                            "DocDate," +
                                            "Term, Amount, Paid, Balance," +
                                            "IP1, IP2, Remarks1, Remarks2, LastBalance" +
                                        ") " +
                                        "AS " +
                                        "(" +
                                            "SELECT " +
                                                "INV, GB, SEQ, CardCode, " +
                                                "DocDate, Term, " +
                                                "Amount, Paid, Balance, " +
                                                "IP1, IP2, Remarks1, Remarks2, " +
                                                "(" +
                                                    "SELECT Balance " +
                                                    "FROM (SELECT INV, MAX(SEQ) AS SEQ FROM ARLG WHERE GB='RCV' GROUP BY INV) C " +
                                                    "    INNER JOIN (SELECT * FROM ARLG WHERE GB='RCV' AND INV = A.INV) D ON C.INV = D.INV AND C.SEQ = D.SEQ" +
                                                ") AS LastBalance " +
                                            "FROM ARLG A " +
                                            "WHERE GB = 'INV' " +
                                                "AND CardCode = '" + cardCode! + "' " +
                                                "AND (strftime('%s', DocDate) " +
                                                    "BETWEEN strftime('%s', REPLACE('" + startDate! + "', '/', '-')) " +
                                                        "AND strftime('%s', REPLACE('" + endDate! + "', '/', '-'))) " +
                                        ") " +
                    
                                        "SELECT * " +
                                        "FROM ARLG_SEARCH " +
                                        "UNION ALL " +
                                        "SELECT " +
                                            "INV, GB, SEQ, CardCode, " +
                                            "DocDate, Term, " +
                                            "Amount, Paid, Balance, " +
                                            "IP1, IP2, Remarks1, Remarks2, '0.00' AS LastBalance " +
                                        "FROM ARLG " +
                                        "WHERE GB = 'RCV' " +
                                            "AND INV IN (SELECT INV FROM ARLG_SEARCH) " +
                                        "ORDER BY INV DESC, GB, SEQ"
                let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
                guard (result != nil) else {
                    print("error >>>>>>>>>>>> ARLedgerList Select")
                    let funcName = "error()"
                    webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                    return
                }
                if let rs = result {
                    while rs.next(){
                        var dic = Dictionary<String, AnyObject>()
                        dic["INV"] = rs.object(forColumn: "INV") as AnyObject
                        dic["GB"] = rs.string(forColumn: "GB") as AnyObject
                        dic["SEQ"] = rs.object(forColumn: "SEQ") as AnyObject
                        dic["CardCode"] = rs.string(forColumn: "CardCode") as AnyObject
                        dic["DocDate"] = rs.string(forColumn: "DocDate") as AnyObject
                        dic["Term"] = rs.string(forColumn: "Term") as AnyObject
                        dic["Amount"] = rs.object(forColumn: "Amount") as AnyObject
                        dic["Paid"] = rs.object(forColumn: "Paid") as AnyObject
                        dic["Balance"] = rs.object(forColumn: "Balance") as AnyObject
                        dic["IP1"] = rs.object(forColumn: "IP1") as AnyObject
                        dic["IP2"] = rs.string(forColumn: "IP2") as AnyObject
                        dic["Remarks1"] = rs.string(forColumn: "Remarks1") as AnyObject
                        dic["Remarks2"] = rs.string(forColumn: "Remarks2") as AnyObject
                        dic["LastBalance"] = rs.object(forColumn: "LastBalance") as AnyObject
                        array.append(dic)
                    }
                }
                db.close()
                
                do {
                    let data = try JSONSerialization.data(withJSONObject: array as Any)
                    let jsonString = String(data: data, encoding: String.Encoding.utf8)
                    print(jsonString)
                    let funcName = "html('\(jsonString!)', 'N')"
                    webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                } catch {
                    print("catch >>>>>>>>>>>> ARLedgerList Select")
                }
            }
        }
    }
}
