//
//  SemverTests.swift
//  SemverTests
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import XCTest

class SemverTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMajor() {
		let major = parse(major: "3.12.2")
		
		XCTAssert(major == 3)
    }
	
	func testMinor() {
		let minor = parse(minor: "3.12.2")
		
		XCTAssert(minor == 12)
	}
	
	func testPatch() {
		let patch = parse(patch: "3.12.2")
		
		XCTAssert(patch == 2)
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
