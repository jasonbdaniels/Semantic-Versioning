//
//  SemverTests.swift
//  SemverTests
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import XCTest

class SemverTests: XCTestCase {
	var version: String {
		return semver.make() ?? "Invalid"
	}
	
	var semver: Semver = Semver(major: 3, minor: 12, patch: 2, pre: "alpha.1.a-b", meta: "2016-12-22-08-32")
    
    override func setUp() {
        super.setUp()
		
		semver.major = 3
		semver.minor = 12
		semver.patch = 2
		semver.pre = "alpha.1.a-b"
		semver.meta = "2016-12-22-08-32"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testBump(){
		let minor = 12
		semver.minor = minor
		let newSemver = Semver.bump(part: .minor, semver: version)
		
		semver.minor = 13
		semver.patch = 0
		
		XCTAssert(newSemver == version)
	}
	
	func testSet(){
		let newValue = ""
		let newSemver = Semver.set(part: .pre, newValue: newValue, semver: version)
		
		semver.pre = newValue
		
		XCTAssert(newSemver == version)
	}
	
	func testMake(){
		semver.major = 3
		semver.minor = 12
		semver.patch = 2
		semver.pre = "alpha.1.a-b"
		semver.meta = "2016-12-22-08-32"
		
		let semverString = semver.make()
		let validSemver = "\(semver.major).\(semver.minor!).\(semver.patch!)-\(semver.pre!)+\(semver.meta!)"
		
		XCTAssert(validSemver == semverString!)
	}
	
    func testMajor() {
		let parsedMajor = Semver.parse(major: version)
		
		XCTAssert(semver.major == parsedMajor)
    }
	
	func testMinor() {
		let parsedMinor = Semver.parse(minor: version)
		
		XCTAssert(semver.minor == parsedMinor)
	}
	
	func testPatch() {
		let parsedPatch = Semver.parse(patch: version)
		
		XCTAssert(semver.patch == parsedPatch)
	}
	
	func testPre() {
		let parsedPre = Semver.parse(pre: version)
		
		XCTAssert(semver.pre == parsedPre)
	}
	
	func testMeta() {
		let parsedMeta = Semver.parse(meta: version)
		
		XCTAssert(semver.meta == parsedMeta)
	}
}
