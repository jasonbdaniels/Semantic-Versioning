//
//  SemanticVersioning.swift
//  Semantic Versioning
//
//  Created by Daniels, Jason on 12/22/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import Foundation

public struct Semver {
	//MARK: Models
	
	public enum Part: Int {
		case major = 0
		case minor = 1
		case patch = 2
		case pre = 3
		case meta = 4
	}
	
	var major: Int
	var minor: Int?
	var patch: Int?
	var pre: String?
	var meta: String?
	
	//MARK: Making
	
	init(major: Int, minor: Int?, patch: Int?, pre: String?, meta: String?){
		self.major = major
		self.minor = minor
		self.patch = patch
		self.pre = pre
		self.meta = meta
	}
	
	init?(semver: String) {
		guard let major = Semver.parse(major: semver) else {return nil}
		
		self.major = major
		self.minor = Semver.parse(minor: semver)
		self.patch = Semver.parse(patch: semver)
		self.pre = Semver.parse(pre: semver)
		self.meta = Semver.parse(meta: semver)
	}
	
	public func make() -> String? {
		let major = self.major
		guard let minor = self.minor else {return nil}
		guard let patch = self.patch else {return nil}
		let semanticVersionSet = CharacterSet.semanticVersion
		var versionString = "\(major).\(minor).\(patch)"
		
		if let pre = self.pre, pre.characters.count > 0 {
			if pre.trimmingCharacters(in: semanticVersionSet).characters.count == 0 {
				versionString.append("-\(pre)")
			}
			else {
				return nil
			}
		}
		
		if let meta = self.meta, meta.characters.count > 0 {
			if meta.trimmingCharacters(in: semanticVersionSet).characters.count == 0 {
				versionString.append("+\(meta)")
			}
			else {
				return nil
			}
		}
		
		return versionString
	}
	
	//MARK: Parsing
	
	public static func parse(major semver: String) -> Int? {
		guard let major = parse(part: .major, from: semver) else {
			return nil
		}
		
		return Int(major)
	}
	
	public static func parse(minor semver: String) -> Int? {
		guard let minor = parse(part: .minor, from: semver) else {
			return nil
		}
		
		return Int(minor)
	}
	
	public static func parse(patch semver: String) -> Int? {
		guard let patch = parse(part: .patch, from: semver) else {
			return nil
		}
		
		return Int(patch)
	}
	
	public static func parse(pre semver: String) -> String? {
		return parse(part: .pre, from: semver)
	}
	
	public static func parse(meta semver: String) -> String? {
		return parse(part: .meta, from: semver)
	}
	
	internal static func parse(part: Part, from semver: String) -> String? {
		let version: String
		let preVersion: String?
		let versionMetaParts = semver.components(separatedBy: "+")
		let versionPart = versionMetaParts[0]
		
		if let preInfoRange = versionPart.range(of: "-") {
			version = versionPart.substring(to: preInfoRange.lowerBound)
			preVersion = versionPart.substring(from: preInfoRange.upperBound)
		}
		else {
			version = versionPart
			preVersion = nil
		}
		
		switch part {
		case .major, .minor, .patch:
			let versionParts = version.components(separatedBy: ".")
			
			return part.rawValue < versionParts.count ? versionParts[part.rawValue] : nil
		case .pre:
			return preVersion
		case .meta:
			return versionMetaParts.last
		}
	}
	
	//MARK: Mutating
	
	internal static func bump(part: Part, semver: String) -> String {
		guard var version = Semver(semver: semver) else {return ""}
		
		//Proposition
		switch part {
		case .major:
			version.major += 1
		case .minor:
			version.minor = (version.minor ?? -1) + 1
		case .patch:
			version.patch = (version.patch ?? -1) + 1
		case .pre:
			version.pre?.semverIncrement()
		case .meta:
			version.meta?.semverIncrement()
		}
		
		//Consequence
		switch part {
		case .major:
			version.minor = 0
			fallthrough
		case .major, .minor:
			version.patch = 0
			fallthrough
		case .major, .minor, .patch:
			version.pre = version.pre?.removingTrailingDotNumbers()
		case .pre, .meta:
			break
		}
		
		return version.make() ?? semver
	}
	
	internal static func set(part: Part, newValue: String, semver: String) -> String {
		guard var version = Semver(semver: semver) else {return ""}
		
		switch part {
		case .major:
			version.major = Int(newValue) ?? version.major
		case .minor:
			version.minor = Int(newValue)
		case .patch:
			version.patch = Int(newValue)
		case .pre:
			version.pre = newValue
		case .meta:
			version.meta = newValue
		}
		
		return version.make() ?? semver
	}
}

extension Int {
	init?(notZeroPadded: String){
		if notZeroPadded.characters.first == "0" { return nil}
		self.init(notZeroPadded)
	}
}

extension String {
	mutating func semverIncrement() {
		let dotNumberInfo = self.trailingDotNumbers(maxCount: 1)
		guard let lastNumber = dotNumberInfo.numbers.last else { self.append(".1"); return }
		let dotNumbers = dotNumberInfo.numbers.dropLast().reduce("", { (result: String, number: Int) -> String in
			result.appending(".\(number)")
		})
		
		self.replaceSubrange(dotNumberInfo.range, with: dotNumbers.appending(".\(lastNumber + 1)"))
	}
	
	func trailingDotNumbers(maxCount: Int = Int.max) -> (range: Range<String.Index>, numbers: [Int]) {
		let selfParts = self.components(separatedBy: ".")
		var numbers = [Int]()
		
		for part in selfParts.reversed() {
			if let number = Int(notZeroPadded: part) {
				numbers.insert(number, at: 0)
				
				if numbers.count == maxCount {
					break
				}
			}
			else {
				break
			}
		}
		
		let lowerBound = self.index(self.endIndex, offsetBy: -2*numbers.count)
		let numberRange = lowerBound..<self.endIndex
		
		return (numberRange, numbers)
	}
	
	func removingTrailingDotNumbers() -> String {
		let selfParts = self.components(separatedBy: ".")
		var removalCount: Int = 0
		
		for part in selfParts.reversed() {
			if let _ = Int(notZeroPadded: part) {
				removalCount += 1
			}
			else {
				break
			}
		}
		
		if selfParts.count - removalCount > 0 {
			var newSelf: String = selfParts[0]
			
			for index in 1..<(selfParts.count - removalCount) {
				newSelf.append(".\(selfParts[index])")
			}
			
			return newSelf
		}
		
		return ""
	}
}

extension Semver: CustomStringConvertible {
	public var description: String {
		return self.make() ?? "Invalid parts"
	}
}

extension CharacterSet {
	public static var semanticVersion: CharacterSet {
		var characters = CharacterSet()
		
		characters.formUnion(CharacterSet.alphanumerics)
		characters.insert(charactersIn: ".-")
		
		return characters
	}
}
