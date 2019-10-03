//
//  Tool.swift
//  CommandKitProto
//
//  Created by Sean Alling on 12/21/18.
//

import Foundation
import Basic
import SPMUtility
//import POSIX

/// Tool Protocol
///
/// Defines a set of related commands that can be run from
/// command line interface (i.e., Terminal). Tools must be
/// registered within the `main()` run entrypoint.
///
public protocol Tool {
    
    /// Namespace reserved for this tool in user command line interface input.
    /// *Restricted to only one word with no spaces*.
    var name: String { get }
    
    /// The list of namespace `Commands` belonging to this `Tool` that are
    /// accessible to the user from their command line interface.
    var commands: [Command] { get }
    
    /// Argument parser that performs downstream parsing of command line input.
    var parser: ArgumentParser { get set }
    
    /// Reference to the Command Line Tool's `Console` for ouput and input
    /// following the initial command line interface input routing arguments.
    var console: Console { get set }
    
    /// Description of the tool used to describe this tool in help output to
    /// the command line interface.
    var usage: String { get }
    
    /// Description of the tool used to describe this tool in help output to
    /// the command line interface.
    var overview: String { get }
    
    
    /// MARK: Initialization
    
    /// Initialization, requires a `Console` dependency for full functionality.
    init(console: Console)
    
    
    /// MARK: - Runtime
    
    /// Main `run` method called that accepts initial argument input.
    func run(_ arguments: [String]) throws
    
//    func bindOptions(to parser: ArgumentParser)
    
    
    /// MARK: - Delegate Methods
    /// TODO: - Find proper insertion point for these methods, not currently implemented
    
    /// Delegate method called prior to the tool being registered to a `Console`.
    func willRegisterTool()
    
    /// Delegate method called following the tool being registered to a `Console`.
    func didRegisterTool()
    
    /// Delegate method called prior to running a the tool's run closure. Used for
    /// any additional setup required for the tool to function properly.
    func willStartRunning()
    
    /// Delegate method called following the tool's run closure. Used for
    /// any additional teardown required.
    func didFinishRunning()    
}


/// MARK: -

extension Tool {

    /// Default `run` method.
    public func run(_ arguments: [String]) throws {
        let newArguments = Array(arguments.dropFirst())
        let parsedArguments = try parse(newArguments)
        try self.process(arguments: parsedArguments)
    }
    
    /// Parses the arguments using the tool's parser, returning the result.
    fileprivate func parse(_ arguments: [String]) throws -> ArgumentParser.Result {
        return try parser.parse(arguments)
    }
    
    /// Processes the arguments using a command subparser if a command is found.
    fileprivate func process(arguments: ArgumentParser.Result) throws {
        guard let subparser = arguments.subparser(parser),
            let command = commands.first(where: { $0.name == subparser }) else {
                parser.printUsage(on: stdoutStream)
                return
        }
        try command.run(with: arguments)
    }
}


/// MARK: - Default Delegate Methods, makes methods optional conformant
extension Tool {
    
    public func willRegisterTool() { }
    public func didRegisterTool() { }
    public func willStartRunning() { }
    public func didFinishRunning() { }
}

/// MARK: - Argument Parser tool name removal
extension ArgumentParser {
    convenience init(for tool: Tool) {
        self.init(commandName: "\(tool.name)", usage: tool.usage, overview: tool.overview)
    }
}
