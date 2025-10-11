import Foundation

/// Represents subnet information for export.
public struct SubnetExportData: Codable {
    public let subnet: String
    public let prefix: Int
    public let netmask: String
    public let wildcardMask: String
    public let firstUsable: String?
    public let lastUsable: String?
    public let broadcast: String
    public let totalAddresses: UInt32
    public let usableHosts: UInt32
    public let label: String?
    
    public init(network: IPv4Network, label: String? = nil, allowP2P: Bool = false) {
        self.subnet = network.networkAddress.description
        self.prefix = network.mask.prefixLength
        self.netmask = network.mask.description
        self.wildcardMask = network.mask.wildcardMask.description
        self.firstUsable = network.firstUsableAddress(allowP2P: allowP2P)?.description
        self.lastUsable = network.lastUsableAddress(allowP2P: allowP2P)?.description
        self.broadcast = network.broadcastAddress.description
        self.totalAddresses = network.totalAddresses
        self.usableHosts = network.usableHosts(allowP2P: allowP2P)
        self.label = label
    }
}

/// Handles exporting subnet data to various formats.
public class SubnetExporter {
    
    /// Export subnet data to JSON format.
    /// - Parameter data: Array of subnet export data
    /// - Returns: JSON string representation
    /// - Throws: Encoding errors
    public static func exportJSON(_ data: [SubnetExportData]) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(data)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    
    /// Export subnet data to CSV format.
    /// - Parameter data: Array of subnet export data
    /// - Returns: CSV string representation
    public static func exportCSV(_ data: [SubnetExportData]) -> String {
        var csv = "Subnet,Prefix,Netmask,Wildcard Mask,First Usable,Last Usable,Broadcast,Total Addresses,Usable Hosts,Label\n"
        
        for item in data {
            let fields = [
                item.subnet,
                "\(item.prefix)",
                item.netmask,
                item.wildcardMask,
                item.firstUsable ?? "N/A",
                item.lastUsable ?? "N/A",
                item.broadcast,
                "\(item.totalAddresses)",
                "\(item.usableHosts)",
                item.label ?? ""
            ]
            
            // Escape fields that contain commas or quotes
            let escapedFields = fields.map { field -> String in
                if field.contains(",") || field.contains("\"") {
                    return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return field
            }
            
            csv += escapedFields.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    /// Export VLSM allocations to JSON.
    public static func exportVLSMJSON(_ allocations: [VLSMAllocation], allowP2P: Bool = false) throws -> String {
        let exportData = allocations.map { allocation in
            SubnetExportData(network: allocation.network, label: allocation.label, allowP2P: allowP2P)
        }
        return try exportJSON(exportData)
    }
    
    /// Export VLSM allocations to CSV.
    public static func exportVLSMCSV(_ allocations: [VLSMAllocation], allowP2P: Bool = false) -> String {
        let exportData = allocations.map { allocation in
            SubnetExportData(network: allocation.network, label: allocation.label, allowP2P: allowP2P)
        }
        return exportCSV(exportData)
    }
}
