//
//  MSSQL_CONNECT.m
//  smart-Dianawig_iosUITests
//
//  Created by smartdev on 2020/06/15.
//  Copyright © 2020 smartdev. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "SQLClient.h"
#import "MSSQL_CONNECT.h"

@implementation  MSSQL_CONNECT

- (void)connect {
    SQLClient* client = [SQLClient sharedInstance];

    //client.delegate = self;
    [client connect:@"gw.smartport.kr:51823" username:@"wig" password:@"smart1234" database:@"BEAUTY4YOU" completion:^(BOOL success) {
        printf("if5!!!!!!!");
        if (success)
        {
          [client execute:@"SELECT * FROM OCRD" completion:^(NSArray* results) {
              printf("111");
            for (NSArray* table in results)
//              for (NSDictionary* row in table)
//                  for (NSString* column in row){
//                  NSLog(@"%@=%@", column, row[column]);
                  NSLog(@"%@=%@", table);

                      
//                  }
            [client disconnect];
          }];
        }else {
            printf("error!!!!!!!");
        }
    }];
    
}

@end
