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
		guard let major = Parser.major(from: semver) else {return nil}
		
		self.major = major
		minor = Parser.minor(from: semver)
		patch = Parser.patch(from: semver)
		pre = Parser.pre(from: semver)
		meta = Parser.meta(from: semver)
	}
	
	public func make() -> String? {
		var versionString = "\(self.major)"
		let semanticVersionSet = CharacterSet.semanticVersion
		
		switch (minor, patch) {
		case (.some(let minor), .some(let patch)):
			versionString.append(".\(minor).\(patch)")
		case (.none, .some(let patch)):
			versionString.append(".0.\(patch)")
		default:
			break
		}
		
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
}

extension Int {
	internal init?(notZeroPadded: String){
		let characters = notZeroPadded.characters
		if characters.count > 1 && characters.first == "0" { return nil}
		self.init(notZeroPadded)
	}
}

extension String {
	var intValue: Int? {
		return Int(notZeroPadded: self)
	}
	
	fileprivate var dotComponents: [String] {
		return components(separatedBy: ".")
	}
	
	fileprivate func dotComponent(at index: Int) -> String? {
		let components = dotComponents
		let indexInbounds = (components.startIndex..<components.endIndex).contains(index)
		
		return indexInbounds ? components[index] : nil
	}
	
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
		var characters = CharacterSet.alphanumerics
		
		characters.insert(charactersIn: ".-")
		
		return characters
	}
}

extension Semver {
	struct Parser {
		fileprivate static func major(from semver: String) -> Int? {
			let major = string(for: .major, from: semver)
			
			return major?.intValue
		}
		
		fileprivate static func minor(from semver: String) -> Int? {
			let minor = string(for: .minor, from: semver)
			
			return minor?.intValue
		}
		
		fileprivate static func patch(from semver: String) -> Int? {
			let patch = string(for: .patch, from: semver)
			
			return patch?.intValue
		}
		
		fileprivate static func pre(from semver: String, forComponentAt index: Int? = nil) -> String? {
			let pre = string(for: .pre, from: semver)
			
			return dotComponent(from: pre, at: index)
		}
		
		fileprivate static func meta(from semver: String, forComponentAt index: Int? = nil) -> String? {
			let meta = string(for: .meta, from: semver)
			
			return dotComponent(from: meta, at: index)
		}
		
		fileprivate static func dotComponent(from other: String?, at index: Int? = nil) -> String? {
			if let index = index {
				return other?.dotComponent(at: index)
			}
			else {
				return other
			}
		}
		
		internal static func subString(for part: Part, from semver: String, at index: Int? = nil) -> String? {
			switch part {
			case .pre: return pre(from: semver, forComponentAt: index)
			case .meta: return meta(from: semver, forComponentAt: index)
			default: return nil
			}
		}
		
		internal static func string(for part: Part, from semver: String) -> String? {
			let version: String
			let preVersion: String?
			var versionMetaParts = semver.components(separatedBy: "+")
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
				return versionMetaParts.count > 1 ? versionMetaParts.last : nil
			}
		}
	}
}

extension Semver {
	struct Mutator {
		internal static func bump(part: Part, semver: String) -> String {
			guard var version = Semver(semver: semver) else {return ""}
			
			//Proposition
			switch part {
			case .major:
				version.major += 1
			case .minor:
				version.minor = (version.minor ?? 0) + 1
			case .patch:
				version.patch = (version.patch ?? 0) + 1
			case .pre:
				version.pre?.semverIncrement()
			case .meta:
				version.meta?.semverIncrement()
			}
			
			//Consequence
			switch part {
			case .major:
				if version.minor != nil {
					version.minor = 0
				}
				
				fallthrough
			case .major, .minor:
				if version.patch != nil {
					version.patch = 0
				}
				
				fallthrough
			case .major, .minor, .patch:
				if version.pre != nil {
					version.pre = version.pre?.removingTrailingDotNumbers()
				}
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
}
