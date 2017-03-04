//
//  TestCommand.swift
//  pbxprojson
//
//  Created by Noriyuki on 2017/03/04.
//
//
import Commandant
import Result

public struct TestCommand: CommandProtocol {
    public typealias Options = NoOptions<AnyError>
    
    public let verb = "test"
    public let function = "execute test command"
    
    public func run(_ options: Options) -> Result<(), AnyError> {
        // Use the parsed options to do something interesting here.
        print("OK")
        
        return .success()
    }
}
