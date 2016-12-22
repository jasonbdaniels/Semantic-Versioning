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
	
	internal static func bump(semver: String, part: Part) -> String {
		
		
		return ""
	}
	
	internal static func set(part: Part, newValue: String, semver: String) -> String {
		guard var major = Semver.parse(major: semver) else {
			return ""
		}
		var minor = Semver.parse(minor: semver)
		var patch = Semver.parse(patch: semver)
		var pre = Semver.parse(pre: semver)
		var meta = Semver.parse(meta: semver)
		
		switch part {
		case .major:
			major = Int(newValue) ?? major
		case .minor:
			minor = Int(newValue)
		case .patch:
			patch = Int(newValue)
		case .pre:
			pre = newValue
		case .meta:
			meta = newValue
		}
		
		let semverStruct = Semver(major: major, minor: minor, patch: patch, pre: pre, meta: meta)
		
		return semverStruct.make() ?? semver
	}
}

extension Semver: CustomStringConvertible {
	public var description: String {
		guard let version = self.make() else {
			return "Invalid parts."
		}
		
		return version
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
