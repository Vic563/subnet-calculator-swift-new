import Foundation

/// View model for regular subnet calculations.
/// This is a simple observable class that can be used with SwiftUI on macOS/iOS
/// or manually on other platforms.
public class SubnetCalculatorViewModel {
    
    // MARK: - Properties (Input)
    
    /// The IP address input string.
    public var ipAddressInput: String = "" {
        didSet { refresh() }
    }
    
    /// The prefix length (0-32).
    public var prefixLength: Int = 24 {
        didSet { refresh() }
    }
    
    /// Whether to allow /31 for point-to-point links.
    public var allowP2P: Bool = false {
        didSet { refresh() }
    }
    
    /// Whether to show binary representations.
    public var showBinary: Bool = false
    
    // MARK: - Properties (Output)
    
    /// The current network, if valid.
    public private(set) var network: IPv4Network?
    
    /// Validation error message, if any.
    public private(set) var errorMessage: String?
    
    /// Subdivided networks for quick actions.
    public private(set) var subdivisions: [IPv4Network] = []
    
    /// Number of subdivisions to create.
    public var subdivisionCount: Int = 2 {
        didSet { updateSubdivisions() }
    }
    
    // MARK: - Computed Properties
    
    /// Network address string.
    public var networkAddress: String {
        network?.networkAddress.description ?? "N/A"
    }
    
    /// Broadcast address string.
    public var broadcastAddress: String {
        network?.broadcastAddress.description ?? "N/A"
    }
    
    /// Netmask string.
    public var netmask: String {
        network?.mask.description ?? "N/A"
    }
    
    /// Wildcard mask string.
    public var wildcardMask: String {
        network?.mask.wildcardMask.description ?? "N/A"
    }
    
    /// First usable address string.
    public var firstUsable: String {
        network?.firstUsableAddress(allowP2P: allowP2P)?.description ?? "N/A"
    }
    
    /// Last usable address string.
    public var lastUsable: String {
        network?.lastUsableAddress(allowP2P: allowP2P)?.description ?? "N/A"
    }
    
    /// Total addresses count.
    public var totalAddresses: String {
        guard let network = network else { return "0" }
        return "\(network.totalAddresses)"
    }
    
    /// Usable hosts count.
    public var usableHosts: String {
        guard let network = network else { return "0" }
        return "\(network.usableHosts(allowP2P: allowP2P))"
    }
    
    /// Network class.
    public var networkClass: String {
        network?.networkAddress.networkClass ?? "N/A"
    }
    
    /// Binary representation of the IP address.
    public var binaryAddress: String {
        guard let addr = IPv4Address(string: ipAddressInput) else { return "" }
        return addr.binaryString
    }
    
    /// Binary representation of the netmask.
    public var binaryNetmask: String {
        guard let network = network else { return "" }
        return IPv4Address(rawValue: network.mask.rawValue).binaryString
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Private Methods
    
    private func updateNetwork(ipInput: String, prefix: Int) {
        guard !ipInput.isEmpty else {
            network = nil
            errorMessage = nil
            return
        }
        
        // Try to parse CIDR notation first
        if ipInput.contains("/") {
            if let net = IPv4Network(cidr: ipInput) {
                network = net
                prefixLength = net.mask.prefixLength
                errorMessage = nil
            } else {
                network = nil
                errorMessage = "Invalid CIDR notation. Example: 192.168.1.0/24"
            }
        } else {
            // Parse as IP address
            guard let addr = IPv4Address(string: ipInput) else {
                network = nil
                errorMessage = "Invalid IP address. Example: 192.168.1.1"
                return
            }
            
            guard prefix >= 0 && prefix <= 32 else {
                network = nil
                errorMessage = "Prefix must be between 0 and 32"
                return
            }
            
            network = IPv4Network(address: addr, prefixLength: prefix)
            errorMessage = nil
        }
        
        updateSubdivisions()
    }
    
    private func updateSubdivisions() {
        guard let network = network else {
            subdivisions = []
            return
        }
        
        subdivisions = network.subdivide(into: subdivisionCount) ?? []
    }
    
    // MARK: - Public Methods
    
    /// Manually refresh the network calculation.
    public func refresh() {
        updateNetwork(ipInput: ipAddressInput, prefix: prefixLength)
    }
    
    /// Export current network data.
    public func exportData() -> SubnetExportData? {
        guard let network = network else { return nil }
        return SubnetExportData(network: network, allowP2P: allowP2P)
    }
    
    /// Export subdivisions data.
    public func exportSubdivisions() -> [SubnetExportData] {
        subdivisions.map { SubnetExportData(network: $0, allowP2P: allowP2P) }
    }
}
