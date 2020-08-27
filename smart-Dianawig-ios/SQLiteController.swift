//
//  SQLiteController.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/07/07.
//  Copyright © 2020 smartdev. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration
import SQLite3

class SQLiteController: UIViewController, WKUIDelegate
{
    var commonController: CommonController = CommonController()
    
    var dbPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]+"/"+"dianaWig.db"
    
    func insertSqlite(sqlInsert: String) -> Int {
     //DB 객체 생성
        var result = 0
        let database : FMDatabase? = FMDatabase(path: dbPath as String)
        print("INSERT 들어옴 !!")
        if let db = database {
            //DB 열기
            db.open()
            //INSERT
            db.executeUpdate(sqlInsert, withArgumentsIn: [])
            print(sqlInsert)
            if db.hadError() {
                print("DB INSERT 실패 \(db.lastErrorMessage())")
            }else{
                print("DB INSERT 성공")
            }
            
            //DB 닫기
            result = 1
            db.close()
        }else{
            result = 0
            NSLog("DB 객체 생성 실패")
        }
        return result
    }
    
    func selectSqlite(sqlSelect: String){
        
        let database : FMDatabase? = FMDatabase(path: dbPath as String)
                
        if let db = database {
            //DB 열기
            db.open()
            //SELECT
            let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
            
            if let rs = result {
                var select : String = ""
                while rs.next(){
                    print("DocEntry : \(rs.string(forColumn: "DocEntry")!)")
                    print("Currency : \(rs.string(forColumn: "Currency")!)")
                }
            }else{
               print("데이터 없음")
            }

        //DB 닫기
        db.close()
        }else{
            NSLog("DB 객체 생성 실패")
        }

       }
    func selectOITM(sqlSelect: String){
        let database : FMDatabase? = FMDatabase(path: dbPath as String)
                
        if let db = database {
            //DB 열기
            db.open()
            //SELECT
            let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])
            
            if let rs = result {
                var select : String = ""
                while rs.next(){
                    print("DocEntry : \(rs.string(forColumn: "ItemCode")!)")
                    print("DocEntry : \(rs.string(forColumn: "onHand")!)")
                }
            }else{
               print("데이터 없음")
            }

        //DB 닫기
        db.close()
        }else{
            NSLog("DB 객체 생성 실패")
        }

       }
    
    func createSQLite(webview: WKWebView) {
        let dbData = commonController.getDBData()
        let mssqlIP = dbData["mssqlIP"] as! String
        let mssqlName = dbData["mssqlName"] as! String
        let mssqlPwd = dbData["mssqlPwd"] as! String
        let mssqlDb = dbData["mssqlDb"] as! String
        
        //DB 객체 생성
        let database : FMDatabase? = FMDatabase(path: dbPath as String)
     
        if let db = database {
            let fileManager = FileManager.default
            let fileExistFlag = !fileManager.fileExists(atPath: dbPath as String)
            if fileExistFlag {
                //DB 열기
                print("333333333")
                db.open()
                
                let OQUTCreate : String = "CREATE TABLE OQUT ( " +
                                            "DocEntry INTEGER, " +
                                            "DocNum INTEGER, " +
                                            "SlpCode INTEGER, " +
                                            "Flags INTEGER, " +
                                            "CardCode TEXT, " +
                                            "CardName TEXT, " +
                                            "Address TEXT, " +
                                            "DocDate TEXT, " +
                                            "PaidSum REAL, " +
                                            "PRIMARY KEY(DocEntry, DocNum)" +
                                        ")"
            
                let NQUTCreate : String = "CREATE TABLE NQUT ( " +
                                        "DocEntry INTEGER , " +
                                        "DocNum INTEGER, " +
                                        "SlpCode INTEGER, " +
                                        "Flags INTEGER, " +
                                        "CardCode TEXT, " +
                                        "CardName TEXT, " +
                                        "Address TEXT, " +
                                        "DocDate TEXT, " +
                                        "PaidSum REAL," +
                                        "PRIMARY KEY(DocEntry, DocNum)" +
                                    ")"
                
                let QUT1Create : String = "CREATE TABLE QUT1 ( " +
                                            "DocEntry INTEGER, " +
                                            "LineNum INTEGER, " +
                                            "ItemCode TEXT, " +
                                            "Quantity REAL, " +
                                            "Price REAL, " +
                                            "Currency TEXT, " +
                                            "PRIMARY KEY(DocEntry, LineNum)" +
                                        ")"
            
                 let NQT1Create : String = "CREATE TABLE NQT1 ( " +
                                             "DocEntry INTEGER, " +
                                             "LineNum INTEGER, " +
                                             "SEQ INTEGER, " +
                                             "ItemCode TEXT, " +
                                             "Quantity REAL, " +
                                             "Price REAL, " +
                                             "Currency TEXT, " +
                                             "PRIMARY KEY(DocEntry, LineNum, SEQ)" +
                                         ")"
                
                let OSLPCreate : String = "CREATE TABLE OSLP ( " +
                                            "SlpCode INTEGER, " +
                                            "SlpName TEXT, " +
                                            "EmpID INTEGER, " +
                                            "PRIMARY KEY(SlpCode, SlpName)" +
                                        ")"
                
                let OCRDCreate : String = "CREATE TABLE OCRD ( " +
                                            "CardCode TEXT, " +
                                            "CardName TEXT, " +
                                            "Balance REAL, " +
                                            "Address TEXT, " +
                                            "SlpCode INTEGER, " +
                                            "PRIMARY KEY(CardCode)" +
                                        ")"
                
                let ARLGCreate : String = "CREATE TABLE ARLG ( " +
                                            "INV INTEGER, " +
                                            "GB TEXT, " +
                                            "SEQ INTEGER, " +
                                            "CardCode TEXT, " +
                                            "DocDate TEXT, " +
                                            "Term TEXT, " +
                                            "Amount REAL, " +
                                            "Paid REAL, " +
                                            "Balance REAL, " +
                                            "IP1 INTEGER, " +
                                            "IP2 TEXT, " +
                                            "Remarks1 TEXT, " +
                                            "Remarks2 TEXT, " +
                                            "PRIMARY KEY(INV, GB, SEQ)" +
                                        ")"
                
                let CCLTCreate : String = "CREATE TABLE CCLT ( " +
                                            "CardCode TEXT, " +
                                            "CardName TEXT, " +
                                            "CardPhone TEXT, " +
                                            "OrderNo INTEGER, " +
                                            "OrderDate TEXT, " +
                                            "OrderMan TEXT, " +
                                            "OrderAmtTot REAL, " +
                                            "OrderAmtHair REAL, " +
                                            "OrderAmtGM REAL, " +
                                            "OrderQtyTot INTEGER, " +
                                            "OrderQtyHair INTEGER, " +
                                            "OrderQtyGM INTEGER, " +
                                            "PrintSend TEXT, " +
                                            "WHPickup TEXT, " +
                                            "Dispatch TEXT, " +
                                            "PickupStart TEXT, " +
                                            "PickupEnd TEXT, " +
                                            "BilNo INTEGER, " +
                                            "BilDate TEXT, " +
                                            "BilAmount REAL, " +
                                            "BilBox INTEGER, " +
                                            "BilShipCp TEXT, " +
                                            "BilTerm TEXT" +
                                        ")"
                
                let OITMCreate : String = "CREATE TABLE OITM ( " +
                                           "ItemCode TEXT, " +
                                           "ItemName TEXT, " +
                                           "OnHand INTEGER, " +
                                           "LastPurPrc REAL, " +
                                           "LastPurCur TEXT" +
                                       ")"
                
//                let OHEMCreate : String = "CREATE TABLE IF NOT EXISTS OHEM ( " +
//                                              "empID TEXT, " +
//                                              "lastName TEXT, " +
//                                              "firstName TEXT, " +
//                                              "middleName TEXT, " +
//                                              "sex TEXT" +
//                                              "status TEXT" +
//                                          ")"
                //TABLE 생성
                db.executeStatements(OQUTCreate)
                db.executeStatements(NQUTCreate)
                db.executeStatements(QUT1Create)
                db.executeStatements(NQT1Create)
                db.executeStatements(OSLPCreate)
                db.executeStatements(OCRDCreate)
                db.executeStatements(ARLGCreate)
                db.executeStatements(CCLTCreate)
                db.executeStatements(OITMCreate)
//                db.executeStatements(OHEMCreate)
                
                //DB 닫기
                db.close()
                
                print(">>>>>>> sqlite table create : success")
            }
            
            var firstChk: Bool = true
            let client = SQLClient.sharedInstance()!
            //            client.delegate = self
            client.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                if !fileExistFlag {
                    client.execute("SELECT MAX(DocNum) AS DocNum , MAX(DocEntry) AS DocEntry FROM OQUT", completion: { (_ results: ([Any]?)) in
                        var docEntry: Int = 0
                        var docNum: Int = 0
                        
                        guard (results != nil) else {
                            print("error >>>>>>>>>>>> insertQuotation Select")
                            return
                        }
                        for table in results as! [[[String:AnyObject]]]{
                            for raw in table{
                                for (key,value) in raw{
                                    if key == "DocEntry" {docEntry = value as! Int}
                                    else if key == "DocNum" {docNum = value as! Int}
                                }
                            }
                        }
                        
                        let database : FMDatabase? = FMDatabase(path: self.dbPath as String)

                        if let db = database {
                            db.open()
                            let sqlSelect : String = "SELECT DocEntry, " +
                                                        "DocEntry, " +
                                                        "SlpCode, " +
                                                        "Flags, " +
                                                        "N.CardCode as CardCode, " +
                                                        "S.CardName as CardName, " +
                                                        "S.Address as Address, " +
                                                        "DocDate, " +
                                                        "PaidSum " +
                                                    "FROM NQUT N " +
                                                    "LEFT JOIN (SELECT CardName, Address, CardCode FROM OCRD) S ON N.CardCode = S.CardCode"

                            let client = SQLClient.sharedInstance()!
                            let result : FMResultSet? = db.executeQuery(sqlSelect, withArgumentsIn: [])

                            if let rs = result {
                                while rs.next(){
                                    do{
                                        docEntry += 1
                                        docNum += 1
                                        
                                        var maxDocEntry: Int = 0
                                        maxDocEntry = docEntry
                                        
                                        var preEnt : Int = 0
                                        preEnt = Int(rs.int(forColumn: "DocEntry"))
             
                                         let sqlCode = rs.int(forColumn: "SlpCode") == nil ? -1 : rs.int(forColumn: "SlpCode")
                                         let CardCode : String = rs.object(forColumn: "CardCode") == nil ? "" : rs.object(forColumn: "CardCode")! as! String
                                         let CardName : String = rs.object(forColumn: "CardName") == nil ? "" : rs.object(forColumn: "CardName")! as! String
                                         let Address : String = rs.string(forColumn: "Address") ?? ""
                                        
                                         let DocDate = rs.object(forColumn: "DocDate")!
                                         let PaidSum = rs.int(forColumn: "PaidSum")
                                         
                                        let sql = "INSERT INTO OQUT(DocEntry,DocNum,SlpCode,Flags,CardCode,CardName,Address,DocDate,PaidSum) " +
                                                "VALUES(\(docEntry), \(docNum), \(sqlCode), 1, '\(CardCode)', '\(CardName)', '\(Address)', '\(DocDate)', \(PaidSum))"
                                        print("insert OQUT sql - " + sql)
                                        
                                        client.execute(sql, completion: { (_ results: ([Any]?)) in
                                            db.open()
                                            
                                            var lineNum = 0
                                            let sqlSelect2 = "SELECT DocEntry, LineNum, ItemCode, Quantity, Price, Currency FROM NQT1 WHERE DocEntry = \(preEnt)"
                                            let result2 : FMResultSet? = db.executeQuery(sqlSelect2, withArgumentsIn: [])
                                            if let rs2 = result2 {
                                                var sql2 = "INSERT INTO QUT1 (DocEntry,LineNum,ItemCode,Quantity,Price,Currency) VALUES"
                                                while rs2.next(){
                                                    do{
                                                        lineNum += 1
                                                        
                                                        let ItemCode = rs2.object(forColumn: "ItemCode")!
                                                        let Quantity = rs2.int(forColumn: "Quantity")
                                                        let Price = rs2.string(forColumn: "Price")!
                                                        let Currency = rs2.object(forColumn: "Currency")!
                                                        
                                                        sql2 += "(\(maxDocEntry), \(lineNum), '\(ItemCode)', \(Quantity), \(Price) , '\(Currency)'),"
                                                    }catch{
                                                        print("INSERT QUT1 ERROR : Line 388")
                                                        print(error)
                                                    }
                                                }
                                                
                                                let sql3 = String(sql2.dropLast()) + ";"
                                                print("insert QUT1 sql - " + sql3)
                                                let client2 = SQLClient.sharedInstance()!
                                                client2.connect(mssqlIP, username: mssqlName, password: mssqlPwd, database: mssqlDb) { success in
                                                    client2.execute(sql3, completion: {(_ results: ([Any]?)) in
                                                        db.open()
                                                        let result2 = db.executeUpdate("DELETE FROM NQT1 WHERE DocEntry = \(preEnt)", withArgumentsIn: [])
                                                        let result = db.executeUpdate("DELETE FROM NQUT WHERE DocEntry = \(preEnt);", withArgumentsIn: [])
                                                        db.close()
                                                        client2.disconnect()
                                                    })
                                                }
                                            }
                                            
                                            db.close()
                                        })
                                    }catch{
                                        print("INSERT OQUT ERROR : Line 411")
                                        print(error)
                                    }
                                }
                            }
                            db.close()
                        }
                        client.disconnect()
                    })
                }
                
                client.execute("SELECT DocEntry, DocNum, SlpCode, Flags, CardCode, CardName, Address, CONVERT(CHAR(10), DocDate, 23) AS DocDate, PaidSum FROM OQUT", completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        firstChk = false
                        client.disconnect()
                        return
                    }
                    db.open()
                    
                    let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'OQUT'", withArgumentsIn: [])
                    if tableYN?.next() == true {
                        if tableYN?.int(forColumn: "CNT") == 1 {
                           db.executeUpdate("DELETE FROM OQUT", withArgumentsIn: [])
                       }
                    }
                    
                    for table in results as! [[[String:AnyObject]]] {
                        for row in table {
                            let DocEntry = row["DocEntry"] as? Int
                            let DocNum = row["DocNum"] as? Int
                            let SlpCode = row["SlpCode"] as? Int
                            let Flags = row["Flags"] as? Int
                            let CardCode = row["CardCode"] as? String
                            let CardName = row["CardName"] as? String
                            let Address = row["Address"] as? String
                            let DocDate = row["DocDate"] as? String
                            let PaidSum = row["PaidSum"] as? Double
                                                     
                            
                            var sqlInsert : String = "INSERT INTO OQUT (" +
                                                        "DocEntry, DocNum, SlpCode, Flags, " +
                                                        "CardCode, CardName, Address, DocDate, PaidSum" +
                                                    ") " +
                                                    "VALUES (" +
                                                        "\(DocEntry!), \(DocNum!), \(SlpCode!), \(Flags!), "
                            if CardCode != nil {sqlInsert += "'\(CardCode!)', "} else {sqlInsert += "null, "}
                            if CardName != nil {sqlInsert += "'\(CardName!)', "} else {sqlInsert += "null, "}
                            if Address != nil {sqlInsert += "'\(Address!)', "} else {sqlInsert += "null, "}
                            if DocDate != nil {sqlInsert += "'\(DocDate!)', "} else {sqlInsert += "null, "}
                            if PaidSum != nil {sqlInsert += "\(PaidSum!)"} else {sqlInsert += "null"}
                            sqlInsert += ")"
                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                        }
                    }
                    db.close()
                    client.disconnect()
                    print("success >>>>>>>>>>>> OQUT Insert")
                })
                
                client.execute("SELECT DocEntry, LineNum, ItemCode, Quantity, Price, Currency FROM QUT1", completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("fail >>>>>>>>>>>> QUT1 Insert")
                        firstChk = false
                        client.disconnect()
                        return
                    }
                    
                    db.open()
                    
                    let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'QUT1'", withArgumentsIn: [])
                    if tableYN?.next() == true {
                        if tableYN?.int(forColumn: "CNT") == 1 {
                           db.executeUpdate("DELETE FROM QUT1", withArgumentsIn: [])
                       }
                    }
                    
                    for table in results as! [[[String:AnyObject]]] {
                        for row in table {
                            let DocEntry = row["DocEntry"] as? Int
                            let LineNum = row["LineNum"] as? Int
                            let ItemCode = row["ItemCode"] as? String
                            let Quantity = row["Quantity"] as? Double
                            let Price = row["Price"] as? Double
                            let Currency = row["Currency"] as? String
                            
                            var sqlInsert : String = "INSERT INTO QUT1 (" +
                                                        "DocEntry, LineNum, " +
                                                        "ItemCode, Quantity, Price, Currency" +
                                                    ") " +
                                                    "VALUES (" +
                                                        "\(DocEntry!), \(LineNum!), "
                            if ItemCode != nil {sqlInsert += "'\(ItemCode!)', "} else {sqlInsert += "null, "}
                            if Quantity != nil {sqlInsert += "\(Quantity!), "} else {sqlInsert += "null, "}
                            if Price != nil {sqlInsert += "\(Price!), "} else {sqlInsert += "null, "}
                            if Currency != nil {sqlInsert += "'\(Currency!)'"} else {sqlInsert += "null"}
                            sqlInsert += ")"
                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                        }
                    }
                    db.close()
                    client.disconnect()
                    print("success >>>>>>>>>>>> QUT1 Insert")
                })
                client.execute("SELECT SlpCode , SlpName ,EmpID FROM OSLP", completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("fail >>>>>>>>>>>> OSLP Insert")
                        firstChk = false
                        client.disconnect()
                        return
                    }
                    db.open()
                    
                    let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'OSLP'", withArgumentsIn: [])
                    if tableYN?.next() == true {
                        if tableYN?.int(forColumn: "CNT") == 1 {
                           db.executeUpdate("DELETE FROM OSLP", withArgumentsIn: [])
                       }
                    }
                    
                    for table in results as! [[[String:AnyObject]]] {
                        for row in table {
                            let SlpCode = row["SlpCode"] as? Int
                            let SlpName = row["SlpName"] as? String
                            let EmpID = row["EmpID"] as? Int
                            print("EMPID :: \(row["EmpID"])")
                              var sqlInsert : String = "INSERT INTO OSLP ( SlpCode, SlpName ,EmpID) VALUES ("
                              if SlpCode != nil {sqlInsert += "\(SlpCode!), "} else {sqlInsert += "null, "}
                              if SlpName != nil {sqlInsert += "'\(SlpName!)', "} else {sqlInsert += "null, "}
                              if EmpID != nil {sqlInsert += "\(EmpID!)"} else {sqlInsert += "null "}
                              sqlInsert += ")"
                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                        }
                    }
                    db.close()
                    client.disconnect()
                    print("success >>>>>>>>>>>> OSLP Insert")
                })
                
                let login_id = UserDefaults.standard.object(forKey: "SlpCode") != nil ? UserDefaults.standard.object(forKey: "SlpCode") as! Int : 0
                client.execute("SELECT CardCode, CardName, Balance, Address, SlpCode FROM OCRD WHERE SlpCode = \(login_id)" , completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("fail >>>>>>>>>>>> OCRD Insert")
                        firstChk = false
                        client.disconnect()
                        return
                    }
                    
                    db.open()
                    
                    let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'OCRD'", withArgumentsIn: [])
                    if tableYN?.next() == true {
                        if tableYN?.int(forColumn: "CNT") == 1 {
                           db.executeUpdate("DELETE FROM OCRD", withArgumentsIn: [])
                       }
                    }
                    
                    for table in results as! [[[String:AnyObject]]] {
                        for row in table {
                            let CardCode = row["CardCode"] as? String
                            let CardName = row["CardName"] as? String
                            let Balance = row["Balance"] as? Double
                            let Address = row["Address"] as? String
                            let SlpCode = row["SlpCode"] as? Int
                            
                            var sqlInsert : String = "INSERT INTO OCRD (" +
                                                        "CardCode, SlpCode, CardName, Balance, Address" +
                                                    ") " +
                                                    "VALUES (" +
                                                        "'\(CardCode!)', \(SlpCode!), "
                            if CardName != nil {sqlInsert += "'\(CardName!)', "} else {sqlInsert += "null, "}
                            if Balance != nil {sqlInsert += "\(Balance!), "} else {sqlInsert += "null, "}
                            if Address != nil {sqlInsert += "'\(Address!)'"} else {sqlInsert += "null"}
                            sqlInsert += ")"
                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                        }
                    }
                    db.close()
                    client.disconnect()
                    print("success >>>>>>>>>>>> OCRD Insert")
                })
                
                client.execute("SELECT INV, GB, SEQ, CardCode, CONVERT(VARCHAR(10), DocDate, 23) AS DocDate, Term, Amount, Paid, Balance, IP1, IP2, Remarks1, Remarks2 FROM ARLG", completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("fail >>>>>>>>>>>> ARLG Insert")
                        firstChk = false
                        client.disconnect()
                        return
                    }
                    
                    db.open()
                    
                    let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'ARLG'", withArgumentsIn: [])
                    if tableYN?.next() == true {
                        if tableYN?.int(forColumn: "CNT") == 1 {
                           db.executeUpdate("DELETE FROM ARLG", withArgumentsIn: [])
                       }
                    }
                    
                    for table in results as! [[[String:AnyObject]]] {
                        for row in table {
                            let INV = row["INV"] as? Int
                            let GB = row["GB"] as? String
                            let SEQ = row["SEQ"] as? Int
                            let CardCode = row["CardCode"] as? String
                            let DocDate = row["DocDate"] as? String
                            let Term = row["Term"] as? String
                            let Amount = row["Amount"] as? Double
                            let Paid = row["Paid"] as? Double
                            let Balance = row["Balance"] as? Double
                            let IP1 = row["IP1"] as? Int
                            let IP2 = row["IP2"] as? String
                            let Remarks1 = row["Remarks1"] as? String
                            let Remarks2 = row["Remarks2"] as? String
                            
                            var sqlInsert : String = "INSERT INTO ARLG (" +
                                                        "INV, GB, SEQ, " +
                                                        "CardCode, DocDate, Term, Amount, Paid, Balance, " +
                                                        "IP1, IP2, Remarks1, Remarks2" +
                                                    ") " +
                                                    "VALUES (" +
                                                        "\(INV!), '\(GB!)', \(SEQ!), "
                            if CardCode != nil {sqlInsert += "'\(CardCode!)', "} else {sqlInsert += "null, "}
                            if DocDate != nil {sqlInsert += "'\(DocDate!)', "} else {sqlInsert += "null, "}
                            if Term != nil {sqlInsert += "'\(Term!)', "} else {sqlInsert += "null, "}
                            if Amount != nil {sqlInsert += "\(Amount!), "} else {sqlInsert += "null, "}
                            if Paid != nil {sqlInsert += "\(Paid!), "} else {sqlInsert += "null, "}
                            if Balance != nil {sqlInsert += "\(Balance!), "} else {sqlInsert += "null, "}
                            if IP1 != nil {sqlInsert += "\(IP1!), "} else {sqlInsert += "null, "}
                            if IP2 != nil {sqlInsert += "'\(IP2!)', "} else {sqlInsert += "null, "}
                            if Remarks1 != nil {sqlInsert += "'\(Remarks1!)', "} else {sqlInsert += "null, "}
                            if Remarks2 != nil {sqlInsert += "'\(Remarks2!)'"} else {sqlInsert += "null"}
                            sqlInsert += ")"
                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                        }
                    }
                    db.close()
                    client.disconnect()
                    print("success >>>>>>>>>>>> ARLG Insert")
                })
                
                client.execute("SELECT CardCode, CardName, CardPhone, OrderNo, " +
                                    "CONVERT(VARCHAR(10), OrderDate, 23) AS OrderDate, OrderMan, " +
                                    "OrderAmtTot, OrderAmtHair, OrderAmtGM, OrderQtyTot, OrderQtyHair, OrderQtyGM, " +
                                    "PrintSend, " +
                                    "CONVERT(VARCHAR(19), WHPickup, 20) AS WHPickup, " +
                                    "Dispatch, " +
                                    "CONVERT(VARCHAR(19), PickupStart, 20) AS PickupStart, " +
                                    "CONVERT(VARCHAR(19), PickupEnd, 20) AS PickupEnd, " +
                                    "BilNo, " +
                                    "CONVERT(VARCHAR(19), BilDate, 20) AS BilDate, " +
                                    "BilAmount, BilBox, BilShipCp, BilTerm " +
                                "FROM CCLT", completion: { (_ results: ([Any]?)) in
                    guard (results != nil) else {
                        print("fail >>>>>>>>>>>> CCLT Insert")
                        firstChk = false
                        client.disconnect()
                        return
                    }
                    db.open()
                                
                    let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'CCLT'", withArgumentsIn: [])
                    if tableYN?.next() == true {
                        if tableYN?.int(forColumn: "CNT") == 1 {
                           db.executeUpdate("DELETE FROM CCLT", withArgumentsIn: [])
                       }
                    }
                                
                    for table in results as! [[[String:AnyObject]]] {
                        for row in table {
                            let CardCode = row["CardCode"] as? String
                            let CardName = row["CardName"] as? String
                            let CardPhone = row["CardPhone"] as? String
                            let OrderNo = row["OrderNo"] as? Int
                            let OrderDate = row["OrderDate"] as? String
                            let OrderMan = row["OrderMan"] as? String
                            let OrderAmtTot = row["OrderAmtTot"] as? Double
                            let OrderAmtHair = row["OrderAmtHair"] as? Double
                            let OrderAmtGM = row["OrderAmtGM"] as? Double
                            let OrderQtyTot = row["OrderQtyTot"] as? Int
                            let OrderQtyHair = row["OrderQtyHair"] as? Int
                            let OrderQtyGM = row["OrderQtyGM"] as? Int
                            let PrintSend = row["PrintSend"] as? String
                            let WHPickup = row["WHPickup"] as? String
                            let Dispatch = row["Dispatch"] as? String
                            let PickupStart = row["PickupStart"] as? String
                            let PickupEnd = row["PickupEnd"] as? String
                            let BilNo = row["BilNo"] as? Int
                            let BilDate = row["BilDate"] as? String
                            let BilAmount = row["BilAmount"] as? Double
                            let BilBox = row["BilBox"] as? Int
                            let BilShipCp = row["BilShipCp"] as? String
                            let BilTerm = row["BilTerm"] as? String
                            
                            var sqlInsert : String = "INSERT INTO CCLT (" +
                                                        "CardCode, CardName, CardPhone, " +
                                                        "OrderNo, OrderDate, OrderMan, " +
                                                        "OrderAmtTot, OrderAmtHair, OrderAmtGM, OrderQtyTot, OrderQtyHair, OrderQtyGM, " +
                                                        "PrintSend, WHPickup, Dispatch, PickupStart, PickupEnd, " +
                                                        "BilNo, BilDate, BilAmount, BilBox, BilShipCp, BilTerm" +
                                                    ") " +
                                                    "VALUES ("
                            if CardCode != nil {sqlInsert += "'\(CardCode!)', "} else {sqlInsert += "null, "}
                            if CardName != nil {sqlInsert += "'\(CardName!)', "} else {sqlInsert += "null, "}
                            if CardPhone != nil {sqlInsert += "'\(CardPhone!)', "} else {sqlInsert += "null, "}
                            if OrderNo != nil {sqlInsert += "\(OrderNo!), "} else {sqlInsert += "null, "}
                            if OrderDate != nil {sqlInsert += "'\(OrderDate!)', "} else {sqlInsert += "null, "}
                            if OrderMan != nil {sqlInsert += "'\(OrderMan!)', "} else {sqlInsert += "null, "}
                            if OrderAmtTot != nil {sqlInsert += "\(OrderAmtTot!), "} else {sqlInsert += "null, "}
                            if OrderAmtHair != nil {sqlInsert += "\(OrderAmtHair!), "} else {sqlInsert += "null, "}
                            if OrderAmtGM != nil {sqlInsert += "\(OrderAmtGM!), "} else {sqlInsert += "null, "}
                            if OrderQtyTot != nil {sqlInsert += "\(OrderQtyTot!), "} else {sqlInsert += "null, "}
                            if OrderQtyHair != nil {sqlInsert += "\(OrderQtyHair!), "} else {sqlInsert += "null, "}
                            if OrderQtyGM != nil {sqlInsert += "\(OrderQtyGM!), "} else {sqlInsert += "null, "}
                            if PrintSend != nil {sqlInsert += "'\(PrintSend!)', "} else {sqlInsert += "null, "}
                            if WHPickup != nil {sqlInsert += "'\(WHPickup!)', "} else {sqlInsert += "null, "}
                            if Dispatch != nil {sqlInsert += "'\(Dispatch!)', "} else {sqlInsert += "null, "}
                            if PickupStart != nil {sqlInsert += "'\(PickupStart!)', "} else {sqlInsert += "null, "}
                            if PickupEnd != nil {sqlInsert += "'\(PickupEnd!)', "} else {sqlInsert += "null, "}
                            if BilNo != nil {sqlInsert += "\(BilNo!), "} else {sqlInsert += "null, "}
                            if BilDate != nil {sqlInsert += "'\(BilDate!)', "} else {sqlInsert += "null, "}
                            if BilAmount != nil {sqlInsert += "\(BilAmount!), "} else {sqlInsert += "null, "}
                            if BilBox != nil {sqlInsert += "\(BilBox!), "} else {sqlInsert += "null, "}
                            if BilShipCp != nil {sqlInsert += "'\(BilShipCp!)', "} else {sqlInsert += "null, "}
                            if BilTerm != nil {sqlInsert += "'\(BilTerm!)'"} else {sqlInsert += "null"}
                            sqlInsert += ")"
                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                        }
                    }
                    db.close()
                    client.disconnect()
                    print("success >>>>>>>>>>>> CCLT Insert")
                })
                
                client.execute("SELECT ItemCode, REPLACE(REPLACE(ItemName,'+','&#43;'),'\"','&#34;') as ItemName , OnHand ,CONVERT(NUMERIC(5,2),Round(LastPurPrc,2,1)) as LastPurPrc, REPLACE(LastPurCur,'$','-11') AS LastPurCur FROM OITM ", completion: { (_ results: ([Any]?)) in
                                   guard (results != nil) else {
                                       print("fail >>>>>>>>>>>> OITM Insert")
                                       firstChk = false
                                       client.disconnect()
                                    
                                       self.move(webview: webview, fileExistFlag: fileExistFlag, firstChk: firstChk)
                                    
                                       return
                                   }
                    
                                   db.open()
                                    
                                   let tableYN = db.executeQuery("SELECT COUNT(*) AS CNT FROM SQLITE_MASTER WHERE NAME = 'OITM'", withArgumentsIn: [])
                                   if tableYN?.next() == true {
                                       if tableYN?.int(forColumn: "CNT") == 1 {
                                          db.executeUpdate("DELETE FROM OITM", withArgumentsIn: [])
                                      }
                                   }
                                               
                                   for table in results as! [[[String:AnyObject]]] {
                                       for row in table {
                                           
                                           let ItemCode = row["ItemCode"] as? String
                                           let ItemName = row["ItemName"] as? String
                                           let OnHand = row["OnHand"] as? Int
                                           let LastPurPrc = row["LastPurPrc"] as? Double
                                           let LastPurCur = row["LastPurCur"] as? String
                                           
                                           var sqlInsert : String = "INSERT INTO OITM (" +
                                                                       "ItemCode, ItemName, OnHand, " +
                                                                       "LastPurPrc, LastPurCur" +
                                                                   ") " +
                                                                   "VALUES ("
                                           if ItemCode != nil {sqlInsert += "'\(ItemCode!)', "} else {sqlInsert += "null, "}
                                           if ItemName != nil {sqlInsert += "'\(ItemName!)', "} else {sqlInsert += "null, "}
                                           if OnHand != nil {sqlInsert += "'\(OnHand!)', "} else {sqlInsert += "null, "}
                                           if LastPurPrc != nil {sqlInsert += "'\(LastPurPrc!)', "} else {sqlInsert += "null, "}
                                           if LastPurCur != nil {sqlInsert += "'\(LastPurCur!)' "} else {sqlInsert += "null"}
                                           sqlInsert += ")"
                                            print("OITM Create >>> \n\(sqlInsert)")
                                            db.executeUpdate(sqlInsert, withArgumentsIn: [])
                                       }
                                   }
                                   db.close()
                                   client.disconnect()
                                   print("success >>>>>>>>>>>> CCLT Insert")
                                   self.move(webview: webview, fileExistFlag: fileExistFlag, firstChk: firstChk)
                               })

            }
            print("TABLE 생성 성공")
        }else{
            print("DB 객체 생성 실패")
        }
    }
    
    func move(webview: WKWebView, fileExistFlag: Bool, firstChk: Bool) {
        let networkChk: Bool = UserDefaults.standard.object(forKey: "networkChk") != nil ? UserDefaults.standard.object(forKey: "networkChk") as! Bool : true
        
        if((fileExistFlag || !networkChk) && !firstChk) {
            UserDefaults.init()
            UserDefaults.standard.set(false, forKey: "networkChk")
            
            let funcName = "networkChk()"
            webview.evaluateJavaScript(funcName) { (result, error) in if let result = error{ print(result) } }
        } else {
            UserDefaults.standard.removeObject(forKey: "networkChk")
            
            let localFile = Bundle.main.path(forResource: "quotations", ofType: "html") ?? ""
            let url = URL(fileURLWithPath: localFile)
            let request = URLRequest(url : url)
            
            webview.load(request)
        }
    }
}
