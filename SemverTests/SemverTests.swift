//
//  SemverTests.swift
//  SemverTests
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import XCTest

class SemverTests: XCTestCase {
	let major = 3
	let minor = 12
	let patch = 2
	let pre = "alpha.1.a-b"
	let meta = "2016-12-22-08-32"
	var version: String {
		return "\(major).\(minor).\(patch)-\(pre)+\(meta)"
	}
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testMake(){
		let semver = Semver(major: major, minor: minor, patch: patch, pre: pre, meta: meta)
		let semverString = semver.make()
		
		XCTAssert(version == semverString)
	}
	
    func testMajor() {
		let parsedMajor = Semver.parse(major: version)
		
		XCTAssert(major == parsedMajor)
    }
	
	func testMinor() {
		let parsedMinor = Semver.parse(minor: version)
		
		XCTAssert(minor == parsedMinor)
	}
	
	func testPatch() {
		let parsedPatch = Semver.parse(patch: version)
		
		XCTAssert(patch == parsedPatch)
	}
	
	func testPre() {
		let parsedPre = Semver.parse(pre: version)
		
		XCTAssert(pre == parsedPre)
	}
	
	func testMeta() {
		let parsedMeta = Semver.parse(meta: version)
		
		XCTAssert(meta == parsedMeta)
	}
}
