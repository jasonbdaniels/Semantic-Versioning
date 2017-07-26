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
        super.tearDown()
    }
	
	func testStringSemverIncrement(){
		var semverPart = "alpha.2.1"
		
		semverPart.semverIncrement()
		XCTAssert("alpha.2.2" == semverPart)
	}
	
	func testTrailingDotNumbers(){
		let numbers = [2, 3]
		let dotNumbers = numbers.reduce("") { (result: String, number: Int) -> String in
			result.appending(".\(number)")
		}
		let trailingDotNumbers = "alpha.1-rc\(dotNumbers)"
		let dotNumberInfo = trailingDotNumbers.trailingDotNumbers()
		let upperBound = trailingDotNumbers.endIndex
		let lowerBound = trailingDotNumbers.index(upperBound, offsetBy: -dotNumbers.characters.count)
		
		XCTAssert(dotNumberInfo.range.lowerBound == lowerBound)
		XCTAssert(dotNumberInfo.range.upperBound == upperBound)
		XCTAssert(dotNumberInfo.numbers == numbers)
	}
	
	func testRemoveTrailingDots(){
		let lessTrailingDots = "alpha.1-rc.2.3".removingTrailingDotNumbers()
		
		XCTAssert(lessTrailingDots == "alpha.1-rc")
	}
	
	func testBumpPre(){
		semver.pre = "alpha.1.2"
		let newSemver = Semver.Mutator.bump(part: .pre, semver: version)
		semver.pre = "alpha.1.3"
		
		XCTAssert(version == newSemver)
	}
	
	func testBumpMinorPreDotNumbers(){
		semver.minor = 12
		semver.pre = "alpha.1.2"
		semver.meta = "00101"
		let newSemver = Semver.Mutator.bump(part: .minor, semver: version)
		
		semver.minor = 13
		semver.patch = 0
		semver.pre = "alpha"
		
		XCTAssert(newSemver == version)
	}
	
	func testBumpMinorPrePaddedZero(){
		semver.minor = 12
		semver.pre = "00101"
		let newSemver = Semver.Mutator.bump(part: .minor, semver: version)
		
		semver.minor = 13
		semver.patch = 0
		semver.pre = "00101"
		
		XCTAssert(newSemver == version)
	}
	
	func testBumpSimpleMinor(){
		semver.major = 1
		semver.minor = 0
		semver.patch = nil
		semver.pre = nil
		semver.meta = nil
		
		XCTAssert(version == "1.0")
		
		let bumpedVersion = Semver.Mutator.bump(part: .minor, semver: version)
		
		XCTAssert("1.1.0" == bumpedVersion)
	}
	
	func testBumpNotExistingPart() {
		semver.major = 1
		semver.minor = nil
		semver.patch = nil
		semver.pre = nil
		semver.meta = nil
		
		XCTAssert(version == "1")
		
		let bumpedVersion = Semver.Mutator.bump(part: .minor, semver: version)
		
		XCTAssert("1.1" == bumpedVersion)
		
		let oneDotOne = Semver(semver: bumpedVersion)!
		let bumpedPatch = Semver.Mutator.bump(part: .patch, semver: bumpedVersion)
		
		XCTAssert("1.1.1" == bumpedPatch)
	}
	
	func testSet(){
		let newValue = ""
		let newSemver = Semver.Mutator.set(part: .pre, newValue: newValue, semver: version)
		
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
		let parsedMajor = Semver.Parser.string(for: .major, from: version)
		
		XCTAssert(semver.major == parsedMajor?.intValue)
    }
	
	func testMinor() {
		let parsedMinor = Semver.Parser.string(for: .minor, from: version)
		
		XCTAssert(semver.minor == parsedMinor?.intValue)
	}
	
	func testPatch() {
		let parsedPatch = Semver.Parser.string(for: .patch, from: version)
		
		XCTAssert(semver.patch == parsedPatch?.intValue)
	}
	
	func testPre() {
		let parsedPre = Semver.Parser.string(for: .pre, from: version)
		
		XCTAssert(semver.pre == parsedPre)
	}
	
	func testMeta() {
		let parsedMeta = Semver.Parser.string(for: .meta, from: version)
		
		XCTAssert(semver.meta == parsedMeta)
	}
	
	func testPreSubpart() {
		let parsedPreSubpart = Semver.Parser.subString(for: .pre, from: version, at: 2)
		
		XCTAssert("a-b" == parsedPreSubpart)
	}
	
	func testMetaSubpart() {
		let parsedMetaSubpart = Semver.Parser.subString(for: .meta, from: version, at: 0)
		
		XCTAssert(semver.meta == parsedMetaSubpart)
	}
}
