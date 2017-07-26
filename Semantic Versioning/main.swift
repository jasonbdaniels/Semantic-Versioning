//
//  main.swift
//  Semantic Versioning
//
//  Created by Daniels, Jason on 12/21/16.
//  Copyright © 2016 Daniels, Jason. All rights reserved.
//

import Foundation

enum Command: String {
	case make	 = "make"
	case major	 = "major"
	case minor	 = "minor"
	case patch	 = "patch"
	case pre	 = "pre"
	case meta	 = "meta"
	case bump	 = "bump"
	case set	 = "set"
	case version = "version"
}

enum SubscriptCommand: String {
	case pre	= "pre[]"
	case meta	= "meta[]"
	
	var semverPart: Semver.Part {
		switch self {
		case .pre: return .pre
		case .meta: return .meta
		}
	}
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
		let semverPart = commandPart.semverPart,
		let result = Semver.Parser.string(for: semverPart, from: CommandLine.arguments[2]) {
		
		return result
	}
	
	return ""
}

func parse(subscriptCommand: SubscriptCommand, withIndex index: Int) -> String {
	guard CommandLine.argc > 2 else {
		return ""
	}
	
	let input = CommandLine.arguments[2]
	let semverPart: Semver.Part
	
	switch subscriptCommand {
	case .pre: semverPart = .pre
	case .meta: semverPart = .meta
	}
	
	let subpart = Semver.Parser.subString(for: semverPart, from: input, at: index)
	
	return subpart ?? ""
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
		let command = Command(rawValue: CommandLine.arguments[2]),
		let part = command.semverPart {
		let newValue = CommandLine.arguments[3]
		let versionString = CommandLine.arguments[4]
		
		return Semver.Mutator.set(part: part, newValue: newValue, semver: versionString)
	}
	
	return ""
}

func bump() -> String {
	if CommandLine.argc >= 4,
		let command = Command(rawValue: CommandLine.arguments[2]),
		let part = command.semverPart {
		let versionString = CommandLine.arguments[3]
		
		return Semver.Mutator.bump(part: part, semver: versionString)
	}
	
	return ""
}

extension CharacterSet {
	static var integers: CharacterSet {
		var integers = CharacterSet.decimalDigits
		
		integers.remove(charactersIn: "-.")
		
		return integers
	}
}

if CommandLine.argc > 1{
	let operation = CommandLine.arguments[1]
	
	if let command = Command(rawValue: operation) {
		switch command {
		case .make: print(make())
		case .major, .minor, .patch, .pre, .meta: print(parse(commandPart: command))
		case .bump: print(bump())
		case .set: print(set())
		case .version: print("Version: \(VERSION)\n\nCommand line tool used to perform operations on [semantic versions](http://semver.org). Current Implementation follows Semantic Versioning *2.0.0*")
		}
	}
	else if let numberRange = operation.rangeOfCharacter(from: .integers) {
		let indexString = operation.substring(with: numberRange)
		var operation = operation
		
		operation.removeSubrange(numberRange)
		
		if let subscriptCommand = SubscriptCommand(rawValue: operation),
			let index = Int(notZeroPadded: indexString) {
			let output = parse(subscriptCommand: subscriptCommand, withIndex: index)
			
			print(output)
		}
	}
}
