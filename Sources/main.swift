//import Commandant
//import Result
import Foundation

//let commandRegistry = CommandRegistry<AnyError>()

let data = try! Data(contentsOf: URL(fileURLWithPath: "../project.pbxproj"))

var format: PropertyListSerialization.PropertyListFormat = PropertyListSerialization.PropertyListFormat.binary
let obj = try PropertyListSerialization.propertyList(from: data, options: [], format: &format)

let dict = obj as! Dictionary<String, Any>
print(dict["objectVersion"]!)
