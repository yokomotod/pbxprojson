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
        
        print(options.filePath)
        
        // Use the parsed options to do something interesting here.
        let data = try! Data(contentsOf: URL(fileURLWithPath: options.filePath))
        
        var format: PropertyListSerialization.PropertyListFormat = PropertyListSerialization.PropertyListFormat.binary
        let obj = try! PropertyListSerialization.propertyList(from: data, options: [], format: &format)
        
        let dict = obj as! Dictionary<String, Any>
        print(dict["objectVersion"]!)

        
        return .success()
    }
}

public struct PrintCommandOptions: OptionsProtocol {
    let filePath: String
    
    static func create(_ filePath: String) -> (String) -> PrintCommandOptions {
        return { filePath in PrintCommandOptions(filePath: filePath) }
    }
    
    public static func evaluate(_ m: CommandMode) -> Result<PrintCommandOptions, CommandantError<AnyError>> {
        return create
            <*> m <| Option(key: "filepath", defaultValue: "", usage: "path to project.pbxproj to read")
            <*> m <| Argument(usage: "print: print <path>")
    }
}
