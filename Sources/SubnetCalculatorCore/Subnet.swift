import Foundation

public struct Subnet: Identifiable, Hashable, Codable {
    public private(set) var id = UUID()
    public let networkAddress: IPAddress
    public let cidr: Int
    public let totalHosts: UInt32
    public let usableHosts: UInt32
    public let broadcastAddress: IPAddress
    public let firstHost: IPAddress
    public let lastHost: IPAddress

    public var maskString: String {
        let mask = cidrMask
        return [
            String((mask >> 24) & 0xFF),
            String((mask >> 16) & 0xFF),
            String((mask >> 8) & 0xFF),
            String(mask & 0xFF)
        ].joined(separator: ".")
    }

    private var cidrMask: UInt32 {
        cidr == 0 ? 0 : ~((1 << (32 - cidr)) - 1)
    }
}
