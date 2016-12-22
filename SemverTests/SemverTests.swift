//
//  SemverTests.swift
//  SemverTests
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import XCTest

class SemverTests: XCTestCase {
	var major = 3
	var minor = 12
	var patch = 2
	var pre = "alpha.1.a-b"
	var meta = "2016-12-22-08-32"
	var version: String {
		var output = "\(major).\(minor).\(patch)"
		
		if pre.characters.count > 0 {
			output.append("-\(pre)")
		}
		
		if meta.characters.count > 0 {
			output.append("+\(meta)")
		}
		
		return output
	}
    
    override func setUp() {
        super.setUp()
		
		major = 3
		minor = 12
		patch = 2
		pre = "alpha.1.a-b"
		meta = "2016-12-22-08-32"
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testSet(){
		let newValue = ""
		let newSemver = Semver.set(part: .pre, newValue: newValue, semver: version)
		
		pre = newValue
		
		XCTAssert(newSemver == version)
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
