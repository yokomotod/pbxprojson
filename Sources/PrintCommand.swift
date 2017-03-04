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
        // Use the parsed options to do something interesting here.
        let projURL = URL(fileURLWithPath: options.filePath)
        let projFile = try! XCProjectFile(xcodeprojURL: projURL)
        let rootObject = projFile.project
        
        let json = [
//            "archiveVersion": pbxproj["archiveVersion"]!,
//            "classes": pbxproj["classes"]!,
//            "objectVersion": pbxproj["objectVersion"]!,
            "rootObject": [
                //"attributes": rootObject["attributes"]!,
                "buildConfigurationList": rootObject.buildConfigurationList.toDictionary(),
                //"compatibilityVersion": rootObject.["compatibilityVersion"]!,
                //"developmentRegion": rootObject.developmentRegion,
                "hasScannedForEncodings": rootObject.hasScannedForEncodings,
                "knownRegions": rootObject.knownRegions,
                //"projectDirPath": rootObject["projectDirPath"]!,
                //"projectRoot": rootObject["projectRoot"]!,
                "targets": rootObject.targets.map { $0.toDictionary() }
            ]
        ]

        print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)
        
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
