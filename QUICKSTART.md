# Quick Start Guide

## Installation

Add to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Vic563/subnet-calculator-swift-new.git", from: "1.0.0")
]
```

## 30-Second Examples

### Calculate a Subnet
```swift
import SubnetCalculator

let network = IPv4Network(cidr: "192.168.1.0/24")!
print("Network: \(network.networkAddress)")      // 192.168.1.0
print("Broadcast: \(network.broadcastAddress)")  // 192.168.1.255
print("Usable: \(network.usableHosts())")        // 254
```

### Split into Subnets
```swift
let subnets = network.subdivide(into: 4)!
for subnet in subnets {
    print(subnet)  // 192.168.1.0/26, 192.168.1.64/26, ...
}
```

### VLSM Planning
```swift
let planner = VLSMPlanner()
let base = IPv4Network(cidr: "10.0.0.0/24")!
let requirements: [VLSMRequirement] = [.hosts(50), .hosts(20), .hosts(10)]

switch planner.plan(baseNetwork: base, requirements: requirements) {
case .success(let allocations, let freeBlocks):
    for alloc in allocations {
        print("\(alloc.network) - \(alloc.network.usableHosts()) hosts")
    }
    print("Free: \(freeBlocks.count) blocks")
case .failure(let failed, _, _):
    print("Failed: \(failed)")
}
```

### Export to CSV/JSON
```swift
let data = [SubnetExportData(network: network)]
let csv = SubnetExporter.exportCSV(data)
let json = try SubnetExporter.exportJSON(data)
```

## Running the Examples

```bash
git clone https://github.com/Vic563/subnet-calculator-swift-new.git
cd subnet-calculator-swift-new
swift run SubnetCalculatorExample
```

## Running Tests

```bash
swift test
```

## Documentation

- **README.md** - Full documentation and API reference
- **IMPLEMENTATION.md** - Implementation details and architecture
- **CONTRIBUTING.md** - How to contribute
- **CHANGELOG.md** - Version history

## Features

✅ IPv4 subnet calculations
✅ VLSM planning (largest-first allocation)
✅ RFC 3021 /31 P2P support
✅ CSV/JSON export
✅ ViewModels for UI integration
✅ 29 unit tests
✅ Zero dependencies

## Next Steps

1. **Use the library** in your project
2. **Read the full README** for detailed examples
3. **Explore the tests** for usage patterns
4. **Contribute** improvements or features

## Quick Reference

| Task | Code |
|------|------|
| Parse CIDR | `IPv4Network(cidr: "192.168.1.0/24")` |
| Get network address | `network.networkAddress` |
| Get broadcast | `network.broadcastAddress` |
| Get usable range | `network.firstUsableAddress()` to `lastUsableAddress()` |
| Subdivide | `network.subdivide(into: 4)` |
| VLSM plan | `planner.plan(baseNetwork: base, requirements: reqs)` |
| Export CSV | `SubnetExporter.exportCSV(data)` |
| Export JSON | `SubnetExporter.exportJSON(data)` |

## Support

- 📖 Read the [README](README.md)
- 🐛 Report issues on GitHub
- 💡 See [CONTRIBUTING.md](CONTRIBUTING.md)

Enjoy using Subnet Studio! 🎉
