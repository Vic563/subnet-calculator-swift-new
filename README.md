# Subnet Studio

A comprehensive IPv4 subnet calculator library with VLSM (Variable Length Subnet Masking) planning support for Swift.

## Overview

Subnet Studio is a modern macOS subnet calculator designed for network engineers and architects. It provides instant, accurate IPv4 subnet calculations with two focused modes:

- **Regular Subnetting**: Compute network/broadcast, host ranges, masks, and quick subdivisions
- **VLSM Planner**: Take a base network and a list of host-count requirements; output an optimal, non-overlapping plan using variable-length subnet masks

## Features

✨ **Core Capabilities**
- Instant, accurate IPv4 subnet calculations
- Intuitive VLSM planning with "largest-first / best-fit" allocation
- Support for RFC 3021 (/31 P2P networks)
- Export to CSV and JSON formats
- Offline and deterministic (no network dependency)

🎯 **Key Features**
- Subnet subdivision into equal parts
- Network/broadcast address calculation
- Usable host range computation
- Wildcard mask calculation
- Binary representation views
- Network class detection (A, B, C, D, E)

## Requirements

- Swift 5.10 or later
- macOS 13+ (Ventura) or Linux

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Vic563/subnet-calculator-swift-new.git", from: "1.0.0")
]
```

Then add `SubnetCalculator` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["SubnetCalculator"]
)
```

## Usage

### Basic Subnet Calculation

```swift
import SubnetCalculator

// Create a network from CIDR notation
let network = IPv4Network(cidr: "192.168.10.42/24")!

// Access network properties
print(network.networkAddress)        // 192.168.10.0
print(network.broadcastAddress)      // 192.168.10.255
print(network.firstUsableAddress())  // 192.168.10.1
print(network.lastUsableAddress())   // 192.168.10.254
print(network.totalAddresses)        // 256
print(network.usableHosts())         // 254

// Get mask information
print(network.mask)                  // 255.255.255.0
print(network.mask.prefixLength)     // 24
print(network.mask.wildcardMask)     // 0.0.0.255
```

### Subnet Subdivision

```swift
let network = IPv4Network(cidr: "192.168.10.0/24")!
let subnets = network.subdivide(into: 4)!

for subnet in subnets {
    print(subnet)
    // 192.168.10.0/26
    // 192.168.10.64/26
    // 192.168.10.128/26
    // 192.168.10.192/26
}
```

### VLSM Planning

```swift
// Create a VLSM planner
let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: false)

// Define base network and requirements
let baseNetwork = IPv4Network(cidr: "10.0.0.0/24")!
let requirements: [VLSMRequirement] = [
    .hosts(50),  // Need 50 hosts
    .hosts(20),  // Need 20 hosts
    .hosts(10),  // Need 10 hosts
    .hosts(5)    // Need 5 hosts
]

// Plan the allocations
let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)

switch result {
case .success(let allocations, let freeBlocks):
    for allocation in allocations {
        print("\(allocation.network) - \(allocation.network.usableHosts()) usable hosts")
    }
    // Output:
    // 10.0.0.0/26 - 62 usable hosts
    // 10.0.0.64/27 - 30 usable hosts
    // 10.0.0.96/28 - 14 usable hosts
    // 10.0.0.112/29 - 6 usable hosts
    
    print("\nFree space starting at: \(freeBlocks.first?.networkAddress ?? "")")
    // Free space starting at: 10.0.0.120

case .failure(let failedReq, _, let freeBlocks):
    print("Failed to allocate: \(failedReq)")
    print("Available space: \(freeBlocks)")
}
```

### /31 Point-to-Point Networks (RFC 3021)

```swift
// Without P2P support
let network1 = IPv4Network(cidr: "203.0.113.10/31")!
print(network1.usableHosts(allowP2P: false))  // 0

// With P2P support
print(network1.usableHosts(allowP2P: true))   // 2
print(network1.firstUsableAddress(allowP2P: true))  // 203.0.113.10
print(network1.lastUsableAddress(allowP2P: true))   // 203.0.113.11
```

### Export to CSV/JSON

```swift
let network = IPv4Network(cidr: "192.168.1.0/24")!
let data = [SubnetExportData(network: network, label: "Office Network")]

// Export to JSON
let json = try SubnetExporter.exportJSON(data)
print(json)

// Export to CSV
let csv = SubnetExporter.exportCSV(data)
print(csv)

// Export VLSM allocations
let planner = VLSMPlanner()
let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)

if case .success(let allocations, _) = result {
    let vlsmJSON = try SubnetExporter.exportVLSMJSON(allocations)
    let vlsmCSV = SubnetExporter.exportVLSMCSV(allocations)
}
```

## API Documentation

### IPv4Address

Represents an IPv4 address as a 32-bit unsigned integer.

**Initializers:**
- `init(rawValue: UInt32)` - Create from raw 32-bit value
- `init(_ a: UInt8, _ b: UInt8, _ c: UInt8, _ d: UInt8)` - Create from octets
- `init?(string: String)` - Create from dotted-decimal string

**Properties:**
- `rawValue: UInt32` - Raw 32-bit representation
- `octets: (UInt8, UInt8, UInt8, UInt8)` - Four octets
- `description: String` - Dotted-decimal notation
- `binaryString: String` - 32-bit binary representation
- `networkClass: String` - Network class (A, B, C, D, or E)

### IPv4Mask

Represents an IPv4 subnet mask.

**Initializers:**
- `init(prefixLength: Int)` - Create from prefix length (0-32)
- `init?(rawValue: UInt32)` - Create from raw value (validates contiguity)
- `init?(string: String)` - Create from dotted-decimal string

**Properties:**
- `rawValue: UInt32` - Raw 32-bit representation
- `prefixLength: Int` - CIDR prefix length
- `wildcardMask: IPv4Address` - Bitwise NOT of netmask
- `totalAddresses: UInt32` - Total addresses in subnet

**Methods:**
- `usableHosts(allowP2P: Bool = false) -> UInt32` - Number of usable hosts

### IPv4Network

Represents an IPv4 network (address + mask).

**Initializers:**
- `init(address: IPv4Address, mask: IPv4Mask)` - Create from address and mask
- `init(address: IPv4Address, prefixLength: Int)` - Create from address and prefix
- `init?(cidr: String)` - Create from CIDR notation (e.g., "192.168.1.0/24")

**Properties:**
- `address: IPv4Address` - Network address
- `mask: IPv4Mask` - Subnet mask
- `networkAddress: IPv4Address` - First address in range
- `broadcastAddress: IPv4Address` - Last address in range
- `totalAddresses: UInt32` - Total number of addresses

**Methods:**
- `firstUsableAddress(allowP2P: Bool = false) -> IPv4Address?` - First usable host
- `lastUsableAddress(allowP2P: Bool = false) -> IPv4Address?` - Last usable host
- `usableHosts(allowP2P: Bool = false) -> UInt32` - Number of usable hosts
- `contains(_ ip: IPv4Address) -> Bool` - Check if address is in network
- `subdivide(into count: Int) -> [IPv4Network]?` - Split into equal subnets

### VLSMPlanner

VLSM (Variable Length Subnet Masking) planner using largest-first best-fit allocation.

**Initializers:**
- `init(reserveNetworkBroadcast: Bool = true, allowP2P: Bool = false)`

**Properties:**
- `reserveNetworkBroadcast: Bool` - Reserve network/broadcast addresses
- `allowP2P: Bool` - Allow /31 for point-to-point links

**Methods:**
- `plan(baseNetwork: IPv4Network, requirements: [VLSMRequirement]) -> VLSMResult`

### VLSMRequirement

Represents a requirement for VLSM planning.

**Cases:**
- `.hosts(Int)` - Requirement by number of hosts
- `.cidr(Int)` - Requirement by CIDR prefix length

### VLSMResult

Result of VLSM planning operation.

**Cases:**
- `.success(allocations: [VLSMAllocation], freeBlocks: [IPv4Network])`
- `.failure(failedRequirement: VLSMRequirement, allocations: [VLSMAllocation], freeBlocks: [IPv4Network])`

### SubnetCalculatorViewModel

View model for regular subnet calculations (suitable for SwiftUI integration).

**Properties:**
- `ipAddressInput: String` - IP address input
- `prefixLength: Int` - Prefix length (0-32)
- `allowP2P: Bool` - Allow /31 P2P networks
- `network: IPv4Network?` - Current network (read-only)
- `errorMessage: String?` - Validation error (read-only)
- `subdivisions: [IPv4Network]` - Subdivided networks (read-only)

**Computed Properties:**
- `networkAddress`, `broadcastAddress`, `netmask`, `wildcardMask`
- `firstUsable`, `lastUsable`, `totalAddresses`, `usableHosts`
- `networkClass`, `binaryAddress`, `binaryNetmask`

**Methods:**
- `refresh()` - Manually trigger recalculation
- `exportData() -> SubnetExportData?` - Export current network
- `exportSubdivisions() -> [SubnetExportData]` - Export subdivisions

### VLSMPlannerViewModel

View model for VLSM planning (suitable for SwiftUI integration).

**Properties:**
- `baseNetworkInput: String` - Base network CIDR
- `requirementsInput: String` - Comma-separated requirements
- `reserveNetworkBroadcast: Bool` - Reserve network/broadcast
- `allowP2P: Bool` - Allow /31 P2P networks
- `baseNetwork: IPv4Network?` - Current base network (read-only)
- `requirements: [VLSMRequirement]` - Parsed requirements (read-only)
- `planResult: VLSMResult?` - Planning result (read-only)
- `isSuccess: Bool` - Success indicator (read-only)

**Computed Properties:**
- `allocations`, `freeBlocks`, `failedRequirement`
- `totalAllocated`, `totalFree`, `summaryMessage`

**Methods:**
- `refresh()` - Manually trigger planning
- `exportJSON() throws -> String` - Export to JSON
- `exportCSV() -> String` - Export to CSV
- `setLabel(_:forAllocationAt:)` - Add label to allocation
- `toggleLock(forAllocationAt:)` - Toggle lock status

## Acceptance Criteria Examples

### Regular Subnetting

Input: `192.168.10.42/24`

```
Network:        192.168.10.0
Broadcast:      192.168.10.255
Usable Range:   192.168.10.1 – 192.168.10.254
Netmask:        255.255.255.0
Wildcard:       0.0.0.255
Usable Hosts:   254
```

### Subdivision

Split `192.168.10.0/24` into 4:

```
192.168.10.0/26     (1–62, broadcast .63)
192.168.10.64/26    (65–126, broadcast .127)
192.168.10.128/26   (129–190, broadcast .191)
192.168.10.192/26   (193–254, broadcast .255)
```

### VLSM Planning

Base: `10.0.0.0/24`, Requirements: `50, 20, 10, 5` hosts

```
10.0.0.0/26     62 usable   (1–62, broadcast .63)
10.0.0.64/27    30 usable   (65–94, broadcast .95)
10.0.0.96/28    14 usable   (97–110, broadcast .111)
10.0.0.112/29   6 usable    (113–118, broadcast .119)

Leftover: 10.0.0.120/29 onwards
```

## Testing

The library includes comprehensive unit tests covering all functionality:

```bash
swift test
```

Test coverage includes:
- IPv4Address creation and manipulation
- IPv4Mask validation and calculations
- IPv4Network operations
- VLSM planning algorithm
- Export functionality
- Edge cases (/31, /32, invalid inputs)

## Algorithm Details

### VLSM Allocation (Largest-First Best-Fit)

1. **Normalize requirements**: Convert host counts to prefix lengths
   - For host requirement `h`: required bits = `ceil(log2(h + 2))`, prefix = `32 - bits`
   - Special case: 2 hosts with P2P enabled = /31
   
2. **Sort by size**: Largest blocks first (smallest prefix value)

3. **Allocate sequentially**:
   - Find first free block that fits
   - Split block if too large (binary halving)
   - Assign and remove from free list

4. **Result**: Success with allocations + leftover, or failure with first failing requirement

**Complexity**: O(r log r) for sorting + O(r log F) for allocation, where r = requirements, F = free blocks

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is available under the MIT license. See the LICENSE file for more info.

## Acknowledgments

- Based on the Subnet Studio PRD
- Implements RFC 3021 for /31 P2P networks
- Follows CIDR and VLSM best practices
