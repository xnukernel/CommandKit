//
//  Console+Ask.swift
//  CommandKitProto
//
//  Created by Sean Alling on 12/20/18.
//

extension Console {
    
    /////////////////   REQUEST INPUT   /////////////////
    
    /**
     Requests input from the console after displaying a prompt.
     
     let answer = console.ask("How are you doing?")
     console.output("You said: " + answer.consoleText())
     
     Input will be read until the first newline. See `Console.input(isSecure:)`. The above code outputs:
     
     How are you doing?
     > great!
     You said: great!
     
     - parameters:
     - prompt: Text to display before asking for input.
     - isSecure: See `Console.input(isSecure:)`
     - returns: Input `String`. entered in response to the prompt.
     **/
    public func ask(_ prompt: ConsoleText, isSecure: Bool = false) -> String {
        output(prompt + .newLine + "> ".consoleText(.info), newLine: false)
        return input(isSecure: isSecure)
    }
    
    
    /**
     Requests yes / no confirmation from the user after a prompt.
     
     if console.confirm("Delete everything?") {
     console.warning("Deleting everything!")
     } else {
     console.print("OK, I won't.")
     }
     
     The above code outputs:
     
     Delete everything?
     > no
     OK, I won't.
     
     This method will attempt to convert the response into a `Bool` using `String.bool`.
     It will continue to ask until the result is a proper format, providing additional help after
     a few failed attempts.
     
     See `Console.confirmOverride` for enabling automatic answers to all confirmation prompts.
     
     - parameters:
     - prompt: `ConsoleText` to display before the confirmation input.
     - returns: `true` if the user answered yes, false if no.
     **/
    public func confirm(_ prompt: ConsoleText) -> Bool {
        var i = 0
        var result = ""
        
        /// continue to ask until the result can be converted to a bool
        while result.bool == nil {
            output(prompt)
            if i >= 1 {
                output("[y]es or [n]o> ".consoleText(.info), newLine: false)
            } else {
                output("y/n> ".consoleText(.info), newLine: false)
            }
            
            result = input().lowercased()
            i += 1
        }
        return result.bool!
    }
    
    //    /// If set, all calls to `confirm(_:)` will use this value instead of asking the user.
    //    public var confirmOverride: Bool? {
    //        get { return extend.get(\Self.confirmOverride, default: nil) }
    //        set { extend.set(\Self.confirmOverride, to: newValue) }
    //    }
    
    
    /**
     Prompts the user to choose an item from the supplied array. The chosen item will be returned.
     
     let color = console.choose("Favorite color?", from: ["Pink", "Blue"])
     console.output("You chose: " + color.consoleText())
     
     The above code will output:
     
     Favorite color?
     1: Pink
     2: Blue
     >
     
     Upon answering, the prompt and options will be cleared from the console and only the output will remain:
     
     You chose: Blue
     
     This method calls `choose(_:from:display:)` using `CustomStringConvertible` to display each element.
     
     - parameters:
     - prompt: `ConsoleText` prompt to display to the user before listing options.
     - array: Array of `CustomStringConvertible` items to choose from.
     - returns: Element from `array` that the user chose.
     **/
    public func choose<T>(_ prompt: ConsoleText, from array: [T]) -> T
        where T: CustomStringConvertible
    {
        return choose(prompt, from: array, display: { $0.description.consoleText() })
    }
    
    
    /**
     Prompts the user to choose an item from the supplied array. The chosen item will be returned.
     
     let color = console.choose("Favorite color?", from: ["Pink", "Blue"])
     console.output("You chose: " + color.consoleText())
     
     The above code will output:
     
     Favorite color?
     1: Pink
     2: Blue
     >
     
     Upon answering, the prompt and options will be cleared from the console and only the output will remain:
     
     You chose: Blue
     
     See `choose(_:from:)` which uses `CustomStringConvertible` to display each element.
     
     - parameters:
     - prompt: `ConsoleText` prompt to display to the user before listing options.
     - array: Array of `CustomStringConvertible` items to choose from.
     - display: A closure for converting each element of `array` to a `ConsoleText` for display.
     - returns: Element from `array` that the user chose.
     **/
    public func choose<T>(_ prompt: ConsoleText, from array: [T], display: (T) -> ConsoleText) -> T {
        output(prompt)
        array.enumerated().forEach { idx, item in
            let offset = idx + 1
            output("\(offset): ".consoleText(.info), newLine: false)
            let description = display(item)
            output(description)
        }
        
        var res: T?
        while res == nil {
            output("> ".consoleText(.info), newLine: false)
            let raw = input(isSecure: true)
            guard let idx = Int(raw), (1...array.count).contains(idx) else {
                // .count is implicitly offset, no need to adjust
                clear(.line)
                continue
            }
            
            // undo previous offset back to 0 indexing
            let offset = idx - 1
            res = array[offset]
        }
        
        // + 1 for > input line
        // + 1 for title line
        let lines = array.count + 2
        for _ in 1...lines {
            clear(.line)
        }
        
        return res!
    }
}


extension String {
    fileprivate var bool: Bool? {
        switch self {
        case "y": return true
        case "n": return false
        default:  return nil
        }
    }
}
