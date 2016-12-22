//
//  main.swift
//  Semantic Versioning
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import Foundation

print("Hello, World!")

enum SemverPart: Int {
	case major = 0
	case minor = 1
	case patch = 2
	case pre = 3
}

func parse(major semver: String) -> Int? {
	guard let major = parse(semver: semver, part: .major) else {
		return nil
	}
	
	return Int(major)
}

func parse(minor semver: String) -> Int? {
	guard let minor = parse(semver: semver, part: .minor) else {
		return nil
	}
	
	return Int(minor)
}

func parse(patch semver: String) -> Int? {
	guard let patch = parse(semver: semver, part: .patch) else {
		return nil
	}
	
	return Int(patch)
}

func parse(pre semver: String) -> String? {
	return parse(semver: semver, part: .pre)
}

func parse(semver: String, part: SemverPart) -> String? {
	let version: String
	let preVersion: String?
	
	if let preInfoRange = semver.range(of: "-") {
		version = semver.substring(to: preInfoRange.lowerBound)
		preVersion = semver.substring(from: preInfoRange.upperBound)
	}
	else {
		version = semver
		preVersion = nil
	}
	
	switch part {
	case .major, .minor, .patch:
		let versionParts = version.components(separatedBy: ".")
		
		return part.rawValue < versionParts.count ? versionParts[part.rawValue] : nil
	case .pre:
		return preVersion
	}
}
