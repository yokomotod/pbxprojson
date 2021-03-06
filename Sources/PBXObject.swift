import Foundation

public typealias JsonObject = [String: Any]

public /* abstract */ class PBXObject {
    let id: String
    let dict: JsonObject
    let allObjects: AllObjects
    
    public lazy var isa: String = self.string("isa")!
    
    public required init(id: String, dict: AnyObject, allObjects: AllObjects) {
        self.id = id
        self.dict = dict as! JsonObject
        self.allObjects = allObjects
    }
    
    func bool(_ key: String) -> Bool? {
        guard let string = dict[key] as? String else { return nil }
        
        switch string {
        case "0":
            return false
        case "1":
            return true
        default:
            return nil
        }
    }
    
    func string(_ key: String) -> String? {
        return dict[key] as? String
    }
    
    func strings(_ key: String) -> [String]? {
        return dict[key] as? [String]
    }
    
    func object<T : PBXObject>(_ key: String) -> T? {
        guard let objectKey = dict[key] as? String else {
            return nil
        }
        
        let obj: T = allObjects.object(objectKey)
        return obj
    }
    
    func object<T : PBXObject>(_ key: String) -> T {
        let objectKey = dict[key] as! String
        return allObjects.object(objectKey)
    }
    
    func objects<T : PBXObject>(_ key: String) -> [T] {
        let objectKeys = dict[key] as! [String]
        return objectKeys.map(allObjects.object)
    }
    
    func dictionary(_ key: String) -> [String: Any]? {
        return dict[key] as? [String: Any]
    }
    
    func toDictionary() -> JsonObject {
        return [:]
    }
}

public /* abstract */ class PBXContainer : PBXObject {
}

public class PBXProject : PBXContainer {
    public lazy var compatibilityVersion: String = self.string("compatibilityVersion")!
    public lazy var developmentRegion: String = self.string("developmentRegion")!
    public lazy var hasScannedForEncodings: Bool = self.bool("hasScannedForEncodings")!
    public lazy var knownRegions: [String] = self.strings("knownRegions")!
    public lazy var targets: [PBXNativeTarget] = self.objects("targets")
    public lazy var mainGroup: PBXGroup = self.object("mainGroup")
    public lazy var buildConfigurationList: XCConfigurationList = self.object("buildConfigurationList")
    public lazy var projectDirPath: String = self.string("projectDirPath")!
    public lazy var projectRoot: String = self.string("projectRoot")!
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        result["developmentRegion"] = self.developmentRegion
        result["hasScannedForEncodings"] = self.hasScannedForEncodings
        result["knownRegions"] = self.knownRegions
        result["targets"] = self.targets.map { $0.toDictionary() }
        result["mainGroup"] = self.mainGroup.toDictionary()
        result["buildConfigurationList"] = self.buildConfigurationList.toDictionary()
        return result
    }
}

public /* abstract */ class PBXContainerItem : PBXObject {
}

public class PBXContainerItemProxy : PBXContainerItem {
    public lazy var containerPortal: PBXProject = self.object("containerPortal")
    public lazy var proxyType: String = self.string("proxyType")!
    //public lazy var remoteGlobalIDString: PBXProject = self.object("remoteGlobalIDString")
    public lazy var remoteInfo: String = self.string("remoteInfo")!
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        result["proxyType"] = self.proxyType
        //result["containerPortal"] = self.containerPortal.toDictionary()
        //result["remoteGlobalIDString"] = self.remoteGlobalIDString.toDictionary()
        result["remoteInfo"] = self.remoteInfo
        return result
    }
}

public /* abstract */ class PBXProjectItem : PBXContainerItem {
}

public class PBXBuildFile : PBXProjectItem {
    public lazy var fileRef: PBXFileReference? = self.object("fileRef")
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        if let fileRef = self.fileRef { result["fileRef"] = fileRef.toDictionary() }
        return result
    }
}


public /* abstract */ class PBXBuildPhase : PBXProjectItem {
    public lazy var files: [PBXBuildFile] = self.objects("files")
    public lazy var runOnlyForDeploymentPostprocessing: String = self.string("runOnlyForDeploymentPostprocessing")!
    
    override public func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        result["files"] = self.files.map { $0.toDictionary() }
        result["runOnlyForDeploymentPostprocessing"] = self.runOnlyForDeploymentPostprocessing
        return result
    }
}

public class PBXCopyFilesBuildPhase : PBXBuildPhase {
    public lazy var name: String? = self.string("name")
    
    override public func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["name"] = self.name!
        return result
    }
}

public class PBXFrameworksBuildPhase : PBXBuildPhase {
}

public class PBXHeadersBuildPhase : PBXBuildPhase {
}

public class PBXResourcesBuildPhase : PBXBuildPhase {
}

public class PBXShellScriptBuildPhase : PBXBuildPhase {
    public lazy var name: String? = self.string("name")
    public lazy var shellScript: String = self.string("shellScript")!
    
    override public func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["name"] = self.name!
        result["shellScript"] = self.shellScript
        return result
    }
    
}

public class PBXSourcesBuildPhase : PBXBuildPhase {
}

public class PBXBuildStyle : PBXProjectItem {
}

public class XCBuildConfiguration : PBXBuildStyle {
    public lazy var name: String = self.string("name")!
    public lazy var buildSettings: [String: Any] = self.dictionary("buildSettings")!
    
    override public func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["name"] = self.name
        result["buildSettings"] = self.buildSettings
        return result
    }
}

public /* abstract */ class PBXTarget : PBXProjectItem {
    public lazy var buildConfigurationList: XCConfigurationList = self.object("buildConfigurationList")
    public lazy var name: String = self.string("name")!
    public lazy var productName: String = self.string("productName")!
    public lazy var buildPhases: [PBXBuildPhase] = self.objects("buildPhases")
    
    override func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["buildConfigurationList"] =  self.buildConfigurationList.toDictionary()
        result["name"] = self.name
        result["productName"] = self.productName
        result["buildPhases"] = self.buildPhases.map { $0.toDictionary() }
        return result
    }
}

public class PBXAggregateTarget : PBXTarget {
}

public class PBXNativeTarget : PBXTarget {
    // TODO: buildRules
    public lazy var dependencies: [PBXTargetDependency] = self.objects("dependencies")
    public lazy var productReference: PBXFileReference = self.object("productReference")
    public lazy var productType: String = self.string("productType")!
    
    override public func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["dependencies"] = self.dependencies.map { $0.toDictionary() }
        result["productReference"] = self.productReference.toDictionary()
        result["productType"] = self.productType
        return result
    }
}

public class PBXTargetDependency : PBXProjectItem {
    public lazy var target: PBXNativeTarget = self.object("target")
    public lazy var targetProxy: String = self.string("targetProxy")! //self.object("targetProxy")
    
    override public func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["target"] = self.target.toDictionary()
        result["targetProxy"] = self.targetProxy
        return result
    }
}

public class XCConfigurationList : PBXProjectItem {
    public lazy var buildConfigurations: [XCBuildConfiguration] = self.objects("buildConfigurations")
    public lazy var defaultConfigurationIsVisible: Bool = self.bool("defaultConfigurationIsVisible")!
    public lazy var defaultConfigurationName: String = self.string("defaultConfigurationName")!
    
    override public func toDictionary() -> JsonObject {
        var result = super.toDictionary()
        result["buildConfigurations"] = self.buildConfigurations.map { $0.toDictionary() }
        result["defaultConfigurationIsVisible"] = self.defaultConfigurationIsVisible
        result["defaultConfigurationName"] = self.defaultConfigurationName
        return result
    }
}

public class PBXReference : PBXContainerItem {
    public lazy var name: String? = self.string("name")
    public lazy var path: String? = self.string("path")
    public lazy var sourceTree: SourceTree = self.string("sourceTree").flatMap(SourceTree.init)!
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        if let name = self.name { result["name"] = name }
        if let path = self.path { result["path"] = path }
        result["sourceTree"] = self.sourceTree.toString()
        
        return result
    }
}

public class PBXFileReference : PBXReference {
    
    // convenience accessor
    public lazy var fullPath: Path? = self.allObjects.fullFilePaths[self.id]
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        if let fullPath = self.fullPath { result["fullPath"] = fullPath.toString() }
        
        return result
    }
}

public class PBXReferenceProxy : PBXReference {
    
    // convenience accessor
    public lazy var remoteRef: String = self.string("remoteRef")!
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        result["remoteRef"] = self.remoteRef
        
        return result
    }
}

public class PBXGroup : PBXReference {
    public lazy var children: [PBXReference] = self.objects("children")
    
    // convenience accessors
    public lazy var subGroups: [PBXGroup] = self.children.ofType(PBXGroup.self)
    public lazy var fileRefs: [PBXFileReference] = self.children.ofType(PBXFileReference.self)
    
    override func toDictionary() -> JsonObject {
        var result: JsonObject = super.toDictionary()
        result["children"] = self.children.map { $0.toDictionary() }
        result["subGroups"] = self.subGroups.map { $0.toDictionary() }
        result["fileRefs"] = self.fileRefs.map { $0.toDictionary() }
        
        return result
    }
}

public class PBXVariantGroup : PBXGroup {
}

public class XCVersionGroup : PBXReference {
}


public enum SourceTree {
    case absolute
    case group
    case relativeTo(SourceTreeFolder)
    
    init?(sourceTreeString: String) {
        switch sourceTreeString {
        case "<absolute>":
            self = .absolute
            
        case "<group>":
            self = .group
            
        default:
            guard let sourceTreeFolder = SourceTreeFolder(rawValue: sourceTreeString) else { return nil }
            self = .relativeTo(sourceTreeFolder)
        }
    }
    
    func toString() -> String {
        return "SourceTree"
    }
}

public enum SourceTreeFolder: String {
    case sourceRoot = "SOURCE_ROOT"
    case buildProductsDir = "BUILT_PRODUCTS_DIR"
    case developerDir = "DEVELOPER_DIR"
    case sdkRoot = "SDKROOT"
}

public enum Path {
    case absolute(String)
    case relativeTo(SourceTreeFolder, String)
    
    func toString() -> String {
        return "Path"
    }
}
