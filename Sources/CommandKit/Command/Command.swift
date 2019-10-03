//
//  File.swift
//  CommandKitProto
//
//  Created by Sean Alling on 12/18/18.
//

import Foundation
import SPMUtility


/// Command
///
public protocol Command {
    
    /// Namespace reserved for this command in user command line interface input.
    /// *Restricted to only one word with no spaces*.
    var name: String { get }
    
    /// Description of the command used to describe this tool in help output to
    /// the command line interface.
    var overview: String { get }
    
    /// Reference to the Command Line Tool's `Console` for ouput and input
    /// following the initial command line interface input routing arguments.
    var console: Console { get }
    
    
    /// MARK: - Initialization
    
    /// Initialization, requires a `Console` and `ArgumentParser` dependency for
    /// full functionality.
    init(console: Console, parser: ArgumentParser)
    
    
    /// MARK: - Runtime
    
    /// Main `run` method called that accepts parsed result from initial
    /// argument input.
    func run(with arguments: ArgumentParser.Result) throws
}
