import Foundation

/// Represents an IPv4 subnet mask.
public struct IPv4Mask: Equatable, Hashable, CustomStringConvertible {
    /// The raw 32-bit representation of the mask.
    public let rawValue: UInt32
    
    /// The prefix length (CIDR notation).
    public let prefixLength: Int
    
    /// Creates a mask from a prefix length (0-32).
    /// - Parameter prefixLength: The number of network bits (0-32)
    public init(prefixLength: Int) {
        precondition(prefixLength >= 0 && prefixLength <= 32, "Prefix length must be between 0 and 32")
        self.prefixLength = prefixLength
        
        if prefixLength == 0 {
            self.rawValue = 0
        } else if prefixLength == 32 {
            self.rawValue = 0xFFFFFFFF
        } else {
            self.rawValue = 0xFFFFFFFF << (32 - prefixLength)
        }
    }
    
    /// Creates a mask from a raw 32-bit value, validating that it's contiguous.
    /// - Parameter rawValue: The 32-bit mask value
    /// - Returns: A mask if the value represents a valid contiguous mask, nil otherwise
    public init?(rawValue: UInt32) {
        self.rawValue = rawValue
        
        // Validate that the mask is contiguous (all 1s followed by all 0s)
        let value = rawValue
        var foundZero = false
        var prefixLen = 0
        
        for i in 0..<32 {
            let bit = (value >> (31 - i)) & 1
            if bit == 1 {
                if foundZero {
                    // Found a 1 after a 0, not contiguous
                    return nil
                }
                prefixLen += 1
            } else {
                foundZero = true
            }
        }
        
        self.prefixLength = prefixLen
    }
    
    /// Creates a mask from a dotted-decimal string (e.g., "255.255.255.0").
    /// - Parameter string: The dotted-decimal mask string
    /// - Returns: A mask if the string is valid and contiguous, nil otherwise
    public init?(string: String) {
        guard let address = IPv4Address(string: string) else { return nil }
        self.init(rawValue: address.rawValue)
    }
    
    /// The wildcard mask (bitwise NOT of the netmask).
    public var wildcardMask: IPv4Address {
        IPv4Address(rawValue: ~rawValue)
    }
    
    /// String representation in dotted-decimal notation.
    public var description: String {
        IPv4Address(rawValue: rawValue).description
    }
    
    /// The number of total addresses in this subnet.
    public var totalAddresses: UInt32 {
        if prefixLength == 32 {
            return 1
        }
        return 1 << (32 - prefixLength)
    }
    
    /// The number of usable host addresses, considering RFC behavior.
    /// - Parameter allowP2P: If true, /31 networks have 2 usable addresses (RFC 3021)
    /// - Returns: The number of usable host addresses
    public func usableHosts(allowP2P: Bool = false) -> UInt32 {
        if prefixLength == 32 {
            return 0
        } else if prefixLength == 31 && allowP2P {
            return 2
        } else if prefixLength >= 31 {
            return 0
        } else {
            let total = totalAddresses
            return total > 2 ? total - 2 : 0
        }
    }
}
