//
//  Console+Input.swift
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
    /**
        Get Console input
     */
    public func input(isSecure: Bool = true) -> String {
        didOutputLines(count: 1)
        if isSecure {
            // http://stackoverflow.com/a/30878869/2611971
            let entry: UnsafeMutablePointer<Int8> = getpass("")
            let pointer: UnsafePointer<CChar> = .init(entry)
            guard var pass = String(validatingUTF8: pointer) else {
                return ""
            }
            if pass.hasSuffix("\n") {
                pass = String(pass.dropLast())
            }
            return pass
        } else {
            return readLine(strippingNewline: true) ?? ""
        }
    }
}
