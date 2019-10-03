//
//  Console+Output.swift
//  CommandKitProto
//
//  Created by Sean Alling on 12/20/18.
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

extension Console {
    
    /////////////////      OUTPUT       /////////////////
    
    /**
     Print Console output
     */
    public func output(_ text: ConsoleText, newLine: Bool = true) {
        var lines = 0
        for fragment in text.fragments {
            let strings = fragment.string.split(separator: "\n", omittingEmptySubsequences: false)
            for string in strings {
                let count = string.count
                if count > size.width && count > 0 && size.width > 0 {
                    lines += (count / size.width) + 1
                }
            }
            /// add line for each fragment
            lines += strings.count - 1
        }
        if newLine { lines += 1 }
        
        didOutputLines(count: lines)
        
        let terminator = newLine ? "\n" : ""
        
        let output: String
        if areANSICommandsEnabled {
            output = text.terminalStylize()
        } else {
            output = text.description
        }
        Swift.print(output, terminator: terminator)
        fflush(stdout)
    }
    
    
    /**
     Outputs a `String` to the `Console` with the specified `ConsoleStyle` style.
     
     console.print("Hello, world!", style: .plain)
     
     - parameters:
     - string: `String` to print.
     - style: `ConsoleStyle` to use for the `string`.
     - newLine: If `true`, the next output will be on a new line.
     */
    public func output(_ string: String, style: ConsoleStyle = .plain, newLine: Bool = true) {
        self.output(string.consoleText(style), newLine: newLine)
    }
    
    
    /**
     Outputs a `String` to the `Console` with `ConsoleStyle.plain` style.
     
     console.print("Hello, world!")
     
     - parameters:
     - string: `String` to print.
     - newLine: If `true`, the next output will be on a new line.
     */
    public func print(_ string: String = "", newLine: Bool = true) {
        self.output(string.consoleText(.plain), newLine: newLine)
    }
    
    
    /**
     Outputs a `String` to the `Console` with `ConsoleStyle.info` style.
     
     console.info("Vapor is the best.")
     
     - parameters:
     - string: `String` to print.
     - newLine: If `true`, the next output will be on a new line.
     */
    public func info(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.info), newLine: newLine)
    }
    
    
    /**
     Outputs a `String` to the `Console` with `ConsoleStyle.success` style.
     
     console.success("It works!")
     
     - parameters:
     - string: `String` to print.
     - newLine: If `true`, the next output will be on a new line.
     */
    public func success(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.success), newLine: newLine)
    }
    
    
    /**
     Outputs a `String` to the `Console` with `ConsoleStyle.warning` style.
     
     console.warning("Watch out...")
     
     - parameters:
     - string: `String` to print.
     - newLine: If `true`, the next output will be on a new line.
     */
    public func warning(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.warning), newLine: newLine)
    }
    
    
    /**
     Outputs a `String` to the `Console` with `ConsoleStyle.error` style.
     
     console.error("Uh oh...")
     
     - parameters:
     - string: `String` to print.
     - newLine: If `true`, the next output will be on a new line.
     */
    public func error(_ string: String = "", newLine: Bool = true) {
        output(string.consoleText(.error), newLine: newLine)
    }
    
    /**
     Centers a `String` according to this console's `size`.
     
     - parameters:
     - string: `String` to center.
     - padding: `Character` to use for padding, `" "` by default.
     - returns: `String` with padding added so that it is centered.
     */
    public func center(_ string: String, padding: Character = " ") -> String {
        // Split the string into lines
        let lines = string.split(separator: Character("\n")).map(String.init)
        return center(lines).joined(separator: "\n")
    }
    
    /**
     Centers an array of `String`s according to this console's `size`.
     
     - parameters:
     - strings: `String` to center.
     - padding: `Character` to use for padding, `" "` by default.
     - returns: `String` with padding added so that it is centered.
     */
    public func center(_ strings: [String], padding: Character = " ") -> [String] {
        var lines = strings
        
        // Make sure there's more than one line
        guard lines.count > 0 else {
            return []
        }
        
        // Find the longest line
        var longestLine = 0
        for line in lines {
            if line.count > longestLine {
                longestLine = line.count
            }
        }
        
        // Calculate the padding and make sure it's greater than or equal to 0
        let paddingCount = max(0, (size.width - longestLine) / 2)
        
        // Apply the padding to each line
        for i in 0..<lines.count {
            for _ in 0..<paddingCount {
                lines[i].insert(padding, at: lines[i].startIndex)
            }
        }
        
        return lines
    }
}
