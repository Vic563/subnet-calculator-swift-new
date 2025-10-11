import Foundation

/// Represents an IPv4 network (address + mask).
public struct IPv4Network: Equatable, Hashable, CustomStringConvertible {
    /// The network address.
    public let address: IPv4Address
    
    /// The subnet mask.
    public let mask: IPv4Mask
    
    /// Creates a network from an address and mask.
    public init(address: IPv4Address, mask: IPv4Mask) {
        // Normalize to network address
        let networkRaw = address.rawValue & mask.rawValue
        self.address = IPv4Address(rawValue: networkRaw)
        self.mask = mask
    }
    
    /// Creates a network from an address and prefix length.
    public init(address: IPv4Address, prefixLength: Int) {
        self.init(address: address, mask: IPv4Mask(prefixLength: prefixLength))
    }
    
    /// Creates a network from a CIDR string (e.g., "192.168.1.0/24").
    /// - Parameter cidr: The CIDR notation string
    /// - Returns: A network if the string is valid, nil otherwise
    public init?(cidr: String) {
        let parts = cidr.split(separator: "/").map(String.init)
        guard parts.count == 2 else { return nil }
        
        guard let address = IPv4Address(string: parts[0]),
              let prefixLength = Int(parts[1]),
              prefixLength >= 0 && prefixLength <= 32 else {
            return nil
        }
        
        self.init(address: address, prefixLength: prefixLength)
    }
    
    /// The network address (first address in the range).
    public var networkAddress: IPv4Address {
        address
    }
    
    /// The broadcast address (last address in the range).
    public var broadcastAddress: IPv4Address {
        IPv4Address(rawValue: address.rawValue | ~mask.rawValue)
    }
    
    /// The first usable host address.
    /// - Parameter allowP2P: If true, /31 networks use the network address as first usable
    /// - Returns: The first usable address, or nil if no usable addresses
    public func firstUsableAddress(allowP2P: Bool = false) -> IPv4Address? {
        if mask.prefixLength == 32 {
            return nil
        } else if mask.prefixLength == 31 && allowP2P {
            return networkAddress
        } else if mask.prefixLength >= 31 {
            return nil
        }
        return IPv4Address(rawValue: address.rawValue + 1)
    }
    
    /// The last usable host address.
    /// - Parameter allowP2P: If true, /31 networks use the broadcast address as last usable
    /// - Returns: The last usable address, or nil if no usable addresses
    public func lastUsableAddress(allowP2P: Bool = false) -> IPv4Address? {
        if mask.prefixLength == 32 {
            return nil
        } else if mask.prefixLength == 31 && allowP2P {
            return broadcastAddress
        } else if mask.prefixLength >= 31 {
            return nil
        }
        return IPv4Address(rawValue: broadcastAddress.rawValue - 1)
    }
    
    /// The total number of addresses in this network.
    public var totalAddresses: UInt32 {
        mask.totalAddresses
    }
    
    /// The number of usable host addresses.
    public func usableHosts(allowP2P: Bool = false) -> UInt32 {
        mask.usableHosts(allowP2P: allowP2P)
    }
    
    /// String representation in CIDR notation.
    public var description: String {
        "\(address)/\(mask.prefixLength)"
    }
    
    /// Checks if an address is contained within this network.
    public func contains(_ ip: IPv4Address) -> Bool {
        (ip.rawValue & mask.rawValue) == address.rawValue
    }
    
    /// Subdivides this network into equal-sized subnets.
    /// - Parameter count: The desired number of subnets
    /// - Returns: An array of subnets, or nil if subdivision is not possible
    public func subdivide(into count: Int) -> [IPv4Network]? {
        guard count > 0 else { return nil }
        
        // Find the smallest power of 2 >= count
        var bitsNeeded = 0
        var subnetsCount = 1
        while subnetsCount < count {
            bitsNeeded += 1
            subnetsCount *= 2
        }
        
        let newPrefix = mask.prefixLength + bitsNeeded
        guard newPrefix <= 32 else { return nil }
        
        let subnetSize = UInt32(1) << (32 - newPrefix)
        var subnets: [IPv4Network] = []
        
        for i in 0..<subnetsCount {
            let subnetAddress = IPv4Address(rawValue: address.rawValue + UInt32(i) * subnetSize)
            subnets.append(IPv4Network(address: subnetAddress, prefixLength: newPrefix))
        }
        
        return subnets
    }
}
