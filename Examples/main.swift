import Foundation
import SubnetCalculator

// MARK: - Example 1: Basic Subnet Calculation

print(String(repeating: "=", count: 60))
print("Example 1: Basic Subnet Calculation")
print(String(repeating: "=", count: 60))

if let network = IPv4Network(cidr: "192.168.10.42/24") {
    print("\nInput: 192.168.10.42/24")
    print("\nNetwork Information:")
    print("  Network Address:   \(network.networkAddress)")
    print("  Broadcast Address: \(network.broadcastAddress)")
    print("  Netmask:           \(network.mask)")
    print("  Wildcard Mask:     \(network.mask.wildcardMask)")
    print("  Prefix Length:     /\(network.mask.prefixLength)")
    print("\nHost Information:")
    print("  First Usable:      \(network.firstUsableAddress() ?? IPv4Address(rawValue: 0))")
    print("  Last Usable:       \(network.lastUsableAddress() ?? IPv4Address(rawValue: 0))")
    print("  Total Addresses:   \(network.totalAddresses)")
    print("  Usable Hosts:      \(network.usableHosts())")
    print("\nAdditional:")
    print("  Network Class:     \(network.networkAddress.networkClass)")
}

// MARK: - Example 2: Subnet Subdivision

print("\n" + String(repeating: "=", count: 60))
print("Example 2: Subdividing a /24 Network into 4 Subnets")
print(String(repeating: "=", count: 60))

if let network = IPv4Network(cidr: "192.168.10.0/24"),
   let subnets = network.subdivide(into: 4) {
    print("\nInput: 192.168.10.0/24, split into 4 equal subnets")
    print("\nResulting Subnets:")
    
    for (index, subnet) in subnets.enumerated() {
        let first = subnet.firstUsableAddress() ?? IPv4Address(rawValue: 0)
        let last = subnet.lastUsableAddress() ?? IPv4Address(rawValue: 0)
        print("  \(index + 1). \(subnet)")
        print("     Usable: \(first) – \(last)")
        print("     Broadcast: \(subnet.broadcastAddress)")
        print("     Usable Hosts: \(subnet.usableHosts())")
    }
}

// MARK: - Example 3: VLSM Planning

print("\n" + String(repeating: "=", count: 60))
print("Example 3: VLSM Planning")
print(String(repeating: "=", count: 60))

let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: false)
if let baseNetwork = IPv4Network(cidr: "10.0.0.0/24") {
    let requirements: [VLSMRequirement] = [
        .hosts(50),
        .hosts(20),
        .hosts(10),
        .hosts(5)
    ]
    
    print("\nBase Network: 10.0.0.0/24")
    print("Requirements: 50, 20, 10, 5 hosts")
    
    let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)
    
    switch result {
    case .success(let allocations, let freeBlocks):
        print("\n✓ Planning Successful!")
        print("\nAllocated Subnets:")
        
        for (index, allocation) in allocations.enumerated() {
            let net = allocation.network
            let first = net.firstUsableAddress() ?? IPv4Address(rawValue: 0)
            let last = net.lastUsableAddress() ?? IPv4Address(rawValue: 0)
            
            print("  \(index + 1). \(net) - \(allocation.requirement.displayString)")
            print("     Usable: \(first) – \(last)")
            print("     Broadcast: \(net.broadcastAddress)")
            print("     Usable Hosts: \(net.usableHosts())")
        }
        
        if !freeBlocks.isEmpty {
            print("\nRemaining Free Space:")
            for block in freeBlocks {
                print("  - \(block) (\(block.totalAddresses) addresses)")
            }
        }
        
    case .failure(let failedReq, let allocations, let freeBlocks):
        print("\n✗ Planning Failed!")
        print("Failed requirement: \(failedReq.displayString)")
        print("Allocated so far: \(allocations.count)")
        print("Free blocks: \(freeBlocks.count)")
    }
}

// MARK: - Example 4: /31 Point-to-Point Networks

print("\n" + String(repeating: "=", count: 60))
print("Example 4: /31 Point-to-Point Networks (RFC 3021)")
print(String(repeating: "=", count: 60))

if let network = IPv4Network(cidr: "203.0.113.10/31") {
    print("\nInput: 203.0.113.10/31")
    
    print("\nWithout P2P support (standard behavior):")
    print("  Usable Hosts: \(network.usableHosts(allowP2P: false))")
    print("  First Usable: \(network.firstUsableAddress(allowP2P: false)?.description ?? "N/A")")
    print("  Last Usable:  \(network.lastUsableAddress(allowP2P: false)?.description ?? "N/A")")
    
    print("\nWith P2P support enabled:")
    print("  Usable Hosts: \(network.usableHosts(allowP2P: true))")
    print("  First Usable: \(network.firstUsableAddress(allowP2P: true)?.description ?? "N/A")")
    print("  Last Usable:  \(network.lastUsableAddress(allowP2P: true)?.description ?? "N/A")")
}

// MARK: - Example 5: Export to CSV/JSON

print("\n" + String(repeating: "=", count: 60))
print("Example 5: Export to CSV and JSON")
print(String(repeating: "=", count: 60))

if let network = IPv4Network(cidr: "192.168.1.0/24") {
    let exportData = [SubnetExportData(network: network, label: "Office Network")]
    
    print("\nExporting network: 192.168.1.0/24")
    
    // CSV Export
    print("\nCSV Format:")
    let csv = SubnetExporter.exportCSV(exportData)
    print(csv)
    
    // JSON Export
    print("JSON Format:")
    if let json = try? SubnetExporter.exportJSON(exportData) {
        print(json)
    }
}

print("\n" + String(repeating: "=", count: 60))
print("Examples Complete!")
print(String(repeating: "=", count: 60))
