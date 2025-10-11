import Foundation

/// Represents an IPv4 address as a 32-bit unsigned integer.
public struct IPv4Address: Equatable, Hashable, CustomStringConvertible {
    /// The raw 32-bit representation of the address.
    public let rawValue: UInt32
    
    /// Creates an IPv4 address from a 32-bit unsigned integer.
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Creates an IPv4 address from four octets.
    /// - Parameters:
    ///   - a: First octet (0-255)
    ///   - b: Second octet (0-255)
    ///   - c: Third octet (0-255)
    ///   - d: Fourth octet (0-255)
    public init(_ a: UInt8, _ b: UInt8, _ c: UInt8, _ d: UInt8) {
        self.rawValue = (UInt32(a) << 24) | (UInt32(b) << 16) | (UInt32(c) << 8) | UInt32(d)
    }
    
    /// Creates an IPv4 address from a string representation (e.g., "192.168.1.1").
    /// - Parameter string: The dotted-decimal string representation
    /// - Returns: An IPv4Address if the string is valid, nil otherwise
    public init?(string: String) {
        let components = string.split(separator: ".").map(String.init)
        guard components.count == 4 else { return nil }
        
        var octets: [UInt8] = []
        for component in components {
            guard let value = UInt8(component) else { return nil }
            octets.append(value)
        }
        
        self.init(octets[0], octets[1], octets[2], octets[3])
    }
    
    /// The four octets of the address.
    public var octets: (UInt8, UInt8, UInt8, UInt8) {
        let a = UInt8((rawValue >> 24) & 0xFF)
        let b = UInt8((rawValue >> 16) & 0xFF)
        let c = UInt8((rawValue >> 8) & 0xFF)
        let d = UInt8(rawValue & 0xFF)
        return (a, b, c, d)
    }
    
    /// String representation in dotted-decimal notation.
    public var description: String {
        let (a, b, c, d) = octets
        return "\(a).\(b).\(c).\(d)"
    }
    
    /// Binary string representation (32 bits).
    public var binaryString: String {
        let binary = String(rawValue, radix: 2)
        return String(repeating: "0", count: 32 - binary.count) + binary
    }
    
    /// Network class (A, B, C, D, or E) for reference.
    public var networkClass: String {
        let firstOctet = UInt8((rawValue >> 24) & 0xFF)
        
        if firstOctet < 128 {
            return "A"
        } else if firstOctet < 192 {
            return "B"
        } else if firstOctet < 224 {
            return "C"
        } else if firstOctet < 240 {
            return "D (Multicast)"
        } else {
            return "E (Reserved)"
        }
    }
}
