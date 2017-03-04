//
//  PrintCommand.swift
//  pbxprojson
//
//  Created by Noriyuki on 2017/03/04.
//
//

import Foundation
import Commandant
import Result

public struct PrintCommand: CommandProtocol {
    public typealias Options = PrintCommandOptions
    
    public let verb = "print"
    public let function = "print contents of project.pbxproj"
    
    public func run(_ options: Options) -> Result<(), AnyError> {
        let dataOrNil: Data?
        
        if options.useStdin {
            var fileContent: String = ""
            while let line = readLine() {
                fileContent += "\(line)\n"
            }
            
            dataOrNil = fileContent.data(using: .utf8)
        } else {
            dataOrNil = try? Data(contentsOf: URL(fileURLWithPath: options.filePath))
        }
        
        guard let data = dataOrNil else {
            fatalError("failed to load.")
        }

        var format: PropertyListSerialization.PropertyListFormat = .binary
        guard let propertyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: &format), let pbxproj = propertyList as? Dictionary<String, Any> else {
            fatalError("failed to deserialize")
        }

        guard let objects = pbxproj["objects"] as? Dictionary<String, Any> else {
            fatalError("cannot find objects field")
        }

        var referenceIDList: [String] = []
        for (key, value) in objects {
            if let dict = value as? Dictionary<String, Any>, let isa = dict["isa"] as? String, isa != "PBXContainerItemProxy" {
                referenceIDList.append(key)
            }
        }

        var values: [String: Value] = [:]
        for (key, object) in objects {
            if let object = object as? Dictionary<String, Any> {
                values[key] = parse(object: object, referenceIDList: Array(referenceIDList))
            }
        }

        guard let rootObjectKey = pbxproj["rootObject"] as? String, let rootValue = values[rootObjectKey] else {
            fatalError("cannot find root value")
        }

        let resolvedRootValue = rootValue.resolve(values: values)

        guard let serizliedJSONData = try? JSONSerialization.data(withJSONObject: resolvedRootValue, options: .prettyPrinted) else {
            fatalError("failed to serialize JSON")
        }

        print(String(data: serizliedJSONData, encoding: .utf8)!)

        return .success()
    }

    indirect enum Value {
        case raw(Any)
        case ref(String)
        case array([Value])
        case dictionary([String: Value])

        func resolve(values: Dictionary<String, Value>, depth: Int = 0) -> Any {
            switch self {
            case .raw(let value):
                return String(describing: value)
            case .ref(let ref):
                return values[ref]!.resolve(values: values, depth: depth + 1)
            case .array(let array):
                return array.map { $0.resolve(values: values, depth: depth) }
            case .dictionary(let dict):
                var newDict: [String: Any] = [:]
                for (key, value) in dict {
                    newDict[key] = value.resolve(values: values, depth: depth)
                }
                return newDict
            }
        }
    }

    private func parse(object: Dictionary<String, Any>, referenceIDList: [String]) -> Value {
        func makeValue(obj: Any) -> Value {
            switch obj {
            case let ref as String where referenceIDList.contains(ref):
                return .ref(ref)
            case let array as Array<String>:
                return .array(array.map { makeValue(obj: $0) })
            case let dict as Dictionary<String, Any>:
                return parse(object: dict, referenceIDList: referenceIDList)
            default:
                return .raw(obj)
            }
        }

        var rootDict: [String: Value] = [:]
        for (key, value) in object {
            rootDict[key] = makeValue(obj: value)
        }
        return .dictionary(rootDict)
    }
}

public struct PrintCommandOptions: OptionsProtocol {
    let filePath: String
    let useStdin: Bool
    
    static func create(_ filePath: String) -> (Bool) -> PrintCommandOptions {
        return { useStdin in PrintCommandOptions(filePath: filePath, useStdin: useStdin) }
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<PrintCommandOptions, CommandantError<AnyError>> {
        return create
            <*> m <| Option(key: "filepath", defaultValue: "", usage: "path to project.pbxproj to read")
            <*> m <| Option(key: "stdin", defaultValue: false, usage: "use stdin instead of filepath (filepath will be ignored)")
    }
}
