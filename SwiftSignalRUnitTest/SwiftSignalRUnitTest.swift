//
//  SwiftSignalRUnitTest.swift
//  SwiftSignalRUnitTest
//
//  Created by zsy on 2017/5/5.
//  Copyright © 2017年 zsy. All rights reserved.
//

import XCTest
import SwiftSignalR
class SwiftSignalRUnitTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    

    
    func testSignalRInvoke(){
        do{
            
            let invokeException = expectationWithDescription("invoke")

            let connection = try HubConnection(url: "https://swiftsignalrtest.azurewebsites.net")
            let testHubProxy = connection.createHubProxy("TestHub") as? HubProxy
            let shit1 = Shit(shitColor: 0, shitShape: 0, shitWeight: 1)
            let shit2 = Shit(shitColor: 0, shitShape: 0, shitWeight: 2)
            let shits = [shit1,shit2]
            let shitPerson = ShitPerson(gender: 0, age: 20, name: "LY", shits: shits)
            var param = [AnyObject?]()
            param.append(shitPerson)
            
            connection.started = {
                testHubProxy!.invoke("RegisterForShitPerson",params: param){
                    res,err -> () in
                    if let boolRes = res as? Bool{
                        XCTAssert(boolRes == true)
                    }else{
                        XCTFail("error invoke")
                    }
                    invokeException.fulfill()
                }
            }
            
            try connection.start()
            
            waitForExpectationsWithTimeout(10000){
                err in
                XCTAssertNil(err,"Error")
            }
            
        }catch let err{
            
        }
        
 
    }
    
}
