//import Commandant
//import Result
import Foundation

//let commandRegistry = CommandRegistry<AnyError>()

let data = try! Data(contentsOf: URL(fileURLWithPath: "../project.pbxproj"))

var format: PropertyListSerialization.PropertyListFormat = PropertyListSerialization.PropertyListFormat.binary
let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: &format)

let pbxproj = obj as! Dictionary<String, Any>
let objects = pbxproj["objects"] as! Dictionary<String, Any>
let rootObject = objects[pbxproj["rootObject"] as! String] as! Dictionary<String, Any>

let json = [
    "archiveVersion": pbxproj["archiveVersion"]!,
    "classes": pbxproj["classes"]!,
    "objectVersion": pbxproj["objectVersion"]!,
    "rootObject": [
        "attributes": rootObject["attributes"]!,
        "buildConfigurationList": rootObject["buildConfigurationList"]!,
        "compatibilityVersion": rootObject["compatibilityVersion"]!,
        "developmentRegion": rootObject["developmentRegion"]!,
        "hasScannedForEncodings": rootObject["hasScannedForEncodings"]!,
//        "knownRegions": rootObject["knownRegions"],
        "projectDirPath": rootObject["projectDirPath"]!,
        "projectRoot": rootObject["projectRoot"]!,
        "targets": rootObject["targets"]!

    ]
]

print(String(data: try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted), encoding: .utf8)!)

