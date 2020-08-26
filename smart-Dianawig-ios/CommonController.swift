//
//  common.swift
//  smart-Dianawig-ios
//
//  Created by smartdev on 2020/06/17.
//  Copyright © 2020 smartdev. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SystemConfiguration

class CommonController: UIViewController, WKUIDelegate {

    func connectedToNetwork() -> Bool {
       
           var zeroAddress = sockaddr_in()
                zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
                zeroAddress.sin_family = sa_family_t(AF_INET)

      guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
           $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
               SCNetworkReachabilityCreateWithAddress(nil, $0)
           }
       }) else {
           return false
       }
              var flags: SCNetworkReachabilityFlags = []
          if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
              return false
          }
          if flags.isEmpty {
              return false
          }
          let isReachable = flags.contains(.reachable)
          let needsConnection = flags.contains(.connectionRequired)
          return (isReachable && !needsConnection)
    }

    func getDBData() -> Dictionary<String, Any> {
        var dbData = Dictionary<String, Any>()
        dbData["mssqlIP"] = ""
        dbData["mssqlName"] = ""
        dbData["mssqlPwd"] = ""
        dbData["mssqlDb"] = ""
        
        return dbData
    }
    
    func progressBarSetting(progressbar: UIProgressView) -> UIProgressView {
        progressbar.transform = progressbar.transform.scaledBy(x: 1, y: 5)
        progressbar.progress = 0.0
        progressbar.progressTintColor = UIColor(red: 179/255.0, green: 55/255.0, blue: 146/255.0, alpha: 0.8)
        progressbar.layer.cornerRadius = 10
        progressbar.clipsToBounds = true
        progressbar.layer.sublayers![1].cornerRadius = 10
        progressbar.subviews[1].clipsToBounds = true

        return progressbar
    }
}
