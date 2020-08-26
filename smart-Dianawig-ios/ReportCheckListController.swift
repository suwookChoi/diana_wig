//
//  ReportCheckListController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/07/06.
//  Copyright © 2020 smartdev. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

class ReportCheckListController: UIViewController, WKUIDelegate
{
    var commonController: CommonController = CommonController()
    var sqliteController: SQLiteController = SQLiteController()
    
    func CheckList(dbData: Dictionary<String, Any>, webview: WKWebView, data: [String : Any]) {
        print(">>> ReportCheckListController CheckList <<<")
        
        let cardCode = data["cardCode"] as? String
        let startDate = data["startDate"] as? String
        let endDate = data["endDate"] as? String
        
        if commonController.connectedToNetwork() {
            print(">>> network - CheckList : success <<<")

            let client = SQLClient.sharedInstance()!
//            client.delegate = self
            client.connect(dbData["mssqlIP"] as! String, username: dbData["mssqlName"] as! String, password: dbData["mssqlPwd"] as! String, database: dbData["mssqlDb"] as! String) { success in
                client.execute(
                    "SELECT CardCode, " +
                        "CardName, CardPhone, " +
                        "OrderNo, " +
                        "CONVERT(VARCHAR(10), OrderDate, 23) AS OrderDate, " +
                        "OrderMan, " +
                        "OrderAmtTot, OrderAmtHair, OrderAmtGM, " +
                        "OrderQtyTot, OrderQtyHair, OrderQtyGM, " +
                        "PrintSend, " +
                        "CONVERT(VARCHAR(19), WHPickup, 20) AS WHPickup, " +
                        "Dispatch, " +
                        "CONVERT(VARCHAR(19), PickupStart, 20) AS PickupStart, " +
                        "CONVERT(VARCHAR(19), PickupEnd, 20) AS PickupEnd, " +
                        "BilNo, " +
                        "CONVERT(VARCHAR(19), BilDate, 20) AS BilDate, " +
                        "BilAmount, BilBox, BilShipCp, BilTerm " +
                    "FROM CCLT " +
                    "WHERE CardCode = '" + cardCode! + "' " +
                        "AND (CONVERT(int, REPLACE(CONVERT(VARCHAR(10), OrderDate, 121), '-', '')) " +
                            "BETWEEN REPLACE('" + startDate! + "', '/', '') AND REPLACE('" + endDate! + "', '/', ''))" +
                    "ORDER BY OrderDate DESC"
                    , completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("error >>>>>>>>>>>> CheckList Select")
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
                            print("catch >>>>>>>>>>>> CheckList Select")
                        }
                    }
                    client.disconnect()
                })
            }
        } else {
            print(">>> network - CheckList : fail <<<")
                            
            let dbPath = sqliteController.dbPath
            //DB 객체 생성
            let database : FMDatabase? = FMDatabase(path: dbPath as String)
            
            if let db = database {
                var array = Array<Dictionary<String, AnyObject>>()
                
                db.open()
                
                let sqlSelect : String = "SELECT CardCode, CardName, CardPhone, " +
                                            "OrderNo, " +
                                            "OrderDate, " +
                                            "OrderMan, " +
                                            "OrderAmtTot, OrderAmtHair, OrderAmtGM, " +
                                            "OrderQtyTot, OrderQtyHair, OrderQtyGM, " +
                                            "PrintSend, " +
                                            "WHPickup, " +
                                            "Dispatch, " +
                                            "PickupStart, " +
                                            "PickupEnd, " +
                                            "BilNo, " +
                                            "BilDate, " +
                                            "BilAmount, BilBox, BilShipCp, BilTerm " +
                                        "FROM CCLT " +
                                        "WHERE CardCode = '" + cardCode! + "' " +
                                            "AND (strftime('%s', OrderDate) " +
                                                "BETWEEN strftime('%s', REPLACE('" + startDate! + "', '/', '-')) " +
                                                    "AND strftime('%s', REPLACE('" + endDate! + "', '/', '-'))) " +
                                        "ORDER BY OrderDate DESC"
                let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
                guard (result != nil) else {
                    print("error >>>>>>>>>>>> CheckList Select")
                    let funcName = "error()"
                    webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
                    return
                }
                if let rs = result {
                    while rs.next(){
                        var dic = Dictionary<String, AnyObject>()
                        dic["CardCode"] = rs.string(forColumn: "CardCode") as AnyObject
                        dic["CardName"] = rs.string(forColumn: "CardName") as AnyObject
                        dic["CardPhone"] = rs.string(forColumn: "CardPhone") as AnyObject
                        dic["OrderNo"] = rs.object(forColumn: "OrderNo") as AnyObject
                        dic["OrderDate"] = rs.string(forColumn: "OrderDate") as AnyObject
                        dic["OrderMan"] = rs.string(forColumn: "OrderMan") as AnyObject
                        dic["OrderAmtTot"] = rs.object(forColumn: "OrderAmtTot") as AnyObject
                        dic["OrderAmtHair"] = rs.object(forColumn: "OrderAmtHair") as AnyObject
                        dic["OrderAmtGM"] = rs.object(forColumn: "OrderAmtGM") as AnyObject
                        dic["OrderQtyTot"] = rs.object(forColumn: "OrderQtyTot") as AnyObject
                        dic["OrderQtyHair"] = rs.object(forColumn: "OrderQtyHair") as AnyObject
                        dic["OrderQtyGM"] = rs.object(forColumn: "OrderQtyGM") as AnyObject
                        dic["PrintSend"] = rs.string(forColumn: "PrintSend") as AnyObject
                        dic["WHPickup"] = rs.string(forColumn: "WHPickup") as AnyObject
                        dic["Dispatch"] = rs.string(forColumn: "Dispatch") as AnyObject
                        dic["PickupStart"] = rs.string(forColumn: "PickupStart") as AnyObject
                        dic["PickupEnd"] = rs.string(forColumn: "PickupEnd") as AnyObject
                        dic["BilNo"] = rs.object(forColumn: "BilNo") as AnyObject
                        dic["BilDate"] = rs.string(forColumn: "BilDate") as AnyObject
                        dic["BilAmount"] = rs.object(forColumn: "BilAmount") as AnyObject
                        dic["BilBox"] = rs.object(forColumn: "BilBox") as AnyObject
                        dic["BilShipCp"] = rs.string(forColumn: "BilShipCp") as AnyObject
                        dic["BilTerm"] = rs.string(forColumn: "BilTerm") as AnyObject
                        
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
                    print("catch >>>>>>>>>>>> CheckList Select")
                }
            }
        }
    }
}
