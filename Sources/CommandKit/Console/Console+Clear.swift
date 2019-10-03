/// Supported methods for clearing the `Console`.
///
/// See `Console.clear(_:)`
public enum ConsoleClear {
    /// Clears the entire viewable area of the `Console`.
    case screen
    /// Deletes the last line that was printed to the `Console`.
    case line
}


extension Console {
    /**
     Clear console window
     */
    public func clear(_ type: ConsoleClear) {
        switch type {
        case .line:
            command(.cursorUp)
            command(.eraseLine)
        case .screen:
            command(.eraseScreen)
        }
    }
    
    /**
     Deletes lines that were previously printed to the terminal.
     
     console.print("Hello!")
     console.clear(lines: 1) // clears the previous print
     
     - parameters:
     - lines: The number of lines to clear.
     */
    public func clear(lines: Int) {
        for _ in 0..<lines {
            clear(.line)
        }
    }
}
