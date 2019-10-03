//
//  Console.swift
//  CommandKitProto
//
//  Created by Sean Alling on 12/18/18.
//

import Foundation
import SPMUtility
import Basic

/**
        Console
 */
final public class Console: Extendable {
    
//    static var main = Console()
    // Set these properties
//    public let usage: String
//    public let overview: String
    
    public init() {
        self.extend = [:]
        self.tools = []
    }
    public var extend: Extend
    private var tools: [Tool]
    
//    public var stream: OutputByteStream
    
    public func register(tool: Tool.Type) {
        let newTool = tool.init(console: self)
        newTool.willRegisterTool()
        self.tools.append(newTool)
    }
    
    
    public func register(tools: [Tool.Type]) {
        for elem in tools {
            self.register(tool: elem.self)
        }
    }
    
    
    private var toolNames: [String] {
        return self.tools.map({ $0.name })
    }
    
    
    private func tool(named: String) -> Tool? {
        return self.tools.first(where: { $0.name == named })
    }
    
    
    public func run(input: String? = nil) {
        var arguments: [String]
        
        if let safeInput = input {
            arguments = safeInput.split(separator: " ").map({ String($0) })
            _ = arguments.dropFirst()
        }
        else {
            arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
        }
        
        do {
            guard let firstArgument = arguments.first, let tool = self.tool(named: firstArgument) else { throw ConsoleError.noToolFound }
            tool.willStartRunning()
            try tool.run(arguments)
            tool.didFinishRunning()
        }
        catch ConsoleError.noToolFound {
            if let firstArgument = arguments.first {
                error("Tool not found: \(firstArgument)", newLine: true)
            }
            else {
                error("No first tool argument specified", newLine: true)
            }
            /// TODO: Add Help support for all tools in Console
        }
        catch {
            handle(error: error)
        }
    }
    
    func handle(error: Error) {
        self.output("Error: ", style: ConsoleStyle.init(color: .red, background: nil, isBold: true), newLine: false)
        
        switch error {
        case ArgumentParserError.expectedArguments(let parser, _):
            self.error("\(error)\n", newLine: false)
            parser.printUsage(on: stdoutStream)
            
        default:
            self.error("\(error)\n", newLine: false)
        }
    }
    
    
//    private func parse() throws -> ArgumentParser.Result {
//        let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
//        return try parser.parse(arguments)
//    }
//
//
//    private func process(arguments: ArgumentParser.Result) throws {
//        guard let subparser = arguments.subparser(parser),
//            let command = commands.first(where: { $0.command == subparser }) else {
//                parser.printUsage(on: stdoutStream)
//                return
//        }
//        try command.run(with: arguments)
//    }
    
    public enum ConsoleError: Error {
        case noToolFound
    }
}


extension Console {
    /// Report error
    public func report(error: String, newLine: Bool) {
        let output = newLine ? error + "\n" : error
        let data = output.data(using: .utf8) ?? Data()
        FileHandle.standardError.write(data)
    }
    
    
    /// Return the size of the console window
    public var size: (width: Int, height: Int) {
        var w = winsize()
        _ = ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &w);
        return (Int(w.ws_col), Int(w.ws_row))
    }
}


extension Console {
    /// Dynamically exclude ANSI commands when Xcode since it doesn't support them.
    internal var areANSICommandsEnabled: Bool {
        #if Xcode
            return false
        #else
            return true
        #endif
    }
}


extension Console {
    /**
        Performs an `ANSICommand`.
     */
    public func command(_ command: ANSICommand) {
        guard areANSICommandsEnabled else { return }
        Swift.print(command.ansi, separator: "", terminator: "")
    }
}

