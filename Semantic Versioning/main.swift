//
//  main.swift
//  Semantic Versioning
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import Foundation

enum Command: String {
	case make	= "make"
	case major	= "major"
	case minor	= "minor"
	case patch	= "patch"
	case pre	= "pre"
	case meta	= "meta"
	case bump	= "bump"
	case set	= "set"
}

extension Command {
	var semverPart: Semver.Part? {
		switch self {
		case .major:
			return .major
		case .minor:
			return .minor
		case .patch:
			return .patch
		case .pre:
			return .pre
		case .meta:
			return .meta
		default:
			return nil
		}
	}
}

func parse(commandPart: Command) -> String {
	if CommandLine.argc > 2,
		let part = commandPart.semverPart,
		let result = Semver.parse(part: part, from: CommandLine.arguments[2]) {
		
		return result
	}
	
	return ""
}

func make() -> String {
	let args = CommandLine.arguments
	
	if 2 < args.count,
		let major = Int(args[2]) {
		let minor = 3 < args.count ? Int(args[3]) : nil
		let patch = 4 < args.count ? Int(args[4]) : nil
		let pre = 5 < args.count ? args[5] : nil
		let meta = 6 < args.count ? args[6] : nil
		let semver = Semver(major: major, minor: minor, patch: patch, pre: pre, meta: meta)
		
		return semver.make() ?? ""
	}

	return ""
}

/**
semver set <part> <new-value> <semver-string>
*/
func set() -> String {
	if CommandLine.arguments.count >= 5,
		let command = Command(rawValue: CommandLine.arguments[2]) {
		
		let newValue = CommandLine.arguments[3]
		let versionString = CommandLine.arguments[4]
		guard var major = Semver.parse(major: versionString) else {
			return ""
		}
		var minor = Semver.parse(minor: versionString)
		var patch = Semver.parse(patch: versionString)
		var pre = Semver.parse(pre: versionString)
		var meta = Semver.parse(meta: versionString)
		
		switch command {
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
		default:
			return ""
		}
		
		let semver = Semver(major: major, minor: minor, patch: patch, pre: pre, meta: meta)
		
		return semver.make() ?? versionString
	}
	
	return ""
}

if CommandLine.argc > 1,
	let command = Command(rawValue: CommandLine.arguments[1]) {
	
	switch command {
	case .make:
		print(make())
	case .major, .minor, .patch, .pre, .meta:
		print(parse(commandPart: command))
	case .bump:
		print("bump version string")
	case .set:
		print(set())
	}
}
