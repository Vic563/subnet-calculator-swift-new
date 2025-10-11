import Testing
@testable import SubnetCalculator

/// Tests for IPv4Address functionality.
@Suite("IPv4Address Tests")
struct IPv4AddressTests {
    
    @Test("Create from octets")
    func createFromOctets() {
        let addr = IPv4Address(192, 168, 1, 1)
        #expect(addr.description == "192.168.1.1")
    }
    
    @Test("Create from string")
    func createFromString() {
        let addr = IPv4Address(string: "10.0.0.1")
        #expect(addr != nil)
        #expect(addr?.description == "10.0.0.1")
    }
    
    @Test("Invalid string returns nil")
    func invalidString() {
        #expect(IPv4Address(string: "256.0.0.1") == nil)
        #expect(IPv4Address(string: "192.168.1") == nil)
        #expect(IPv4Address(string: "abc.def.ghi.jkl") == nil)
    }
    
    @Test("Octets property")
    func octetsProperty() {
        let addr = IPv4Address(203, 0, 113, 10)
        let (a, b, c, d) = addr.octets
        #expect(a == 203)
        #expect(b == 0)
        #expect(c == 113)
        #expect(d == 10)
    }
    
    @Test("Binary string representation")
    func binaryString() {
        let addr = IPv4Address(255, 255, 255, 255)
        #expect(addr.binaryString == "11111111111111111111111111111111")
        
        let addr2 = IPv4Address(192, 168, 0, 1)
        #expect(addr2.binaryString == "11000000101010000000000000000001")
    }
    
    @Test("Network class detection")
    func networkClass() {
        #expect(IPv4Address(string: "10.0.0.1")?.networkClass == "A")
        #expect(IPv4Address(string: "172.16.0.1")?.networkClass == "B")
        #expect(IPv4Address(string: "192.168.1.1")?.networkClass == "C")
        #expect(IPv4Address(string: "224.0.0.1")?.networkClass == "D (Multicast)")
        #expect(IPv4Address(string: "240.0.0.1")?.networkClass == "E (Reserved)")
    }
}

/// Tests for IPv4Mask functionality.
@Suite("IPv4Mask Tests")
struct IPv4MaskTests {
    
    @Test("Create from prefix length")
    func createFromPrefix() {
        let mask = IPv4Mask(prefixLength: 24)
        #expect(mask.description == "255.255.255.0")
        #expect(mask.prefixLength == 24)
    }
    
    @Test("Edge case prefix lengths")
    func edgeCasePrefixes() {
        let mask0 = IPv4Mask(prefixLength: 0)
        #expect(mask0.description == "0.0.0.0")
        
        let mask32 = IPv4Mask(prefixLength: 32)
        #expect(mask32.description == "255.255.255.255")
    }
    
    @Test("Create from string")
    func createFromString() {
        let mask = IPv4Mask(string: "255.255.255.0")
        #expect(mask != nil)
        #expect(mask?.prefixLength == 24)
    }
    
    @Test("Non-contiguous mask rejected")
    func nonContiguousMask() {
        // 255.255.0.255 is not contiguous
        let addr = IPv4Address(255, 255, 0, 255)
        let mask = IPv4Mask(rawValue: addr.rawValue)
        #expect(mask == nil)
    }
    
    @Test("Wildcard mask calculation")
    func wildcardMask() {
        let mask = IPv4Mask(prefixLength: 24)
        #expect(mask.wildcardMask.description == "0.0.0.255")
    }
    
    @Test("Total addresses calculation")
    func totalAddresses() {
        #expect(IPv4Mask(prefixLength: 24).totalAddresses == 256)
        #expect(IPv4Mask(prefixLength: 30).totalAddresses == 4)
        #expect(IPv4Mask(prefixLength: 32).totalAddresses == 1)
    }
    
    @Test("Usable hosts - standard")
    func usableHostsStandard() {
        #expect(IPv4Mask(prefixLength: 24).usableHosts(allowP2P: false) == 254)
        #expect(IPv4Mask(prefixLength: 30).usableHosts(allowP2P: false) == 2)
        #expect(IPv4Mask(prefixLength: 31).usableHosts(allowP2P: false) == 0)
        #expect(IPv4Mask(prefixLength: 32).usableHosts(allowP2P: false) == 0)
    }
    
    @Test("Usable hosts - /31 P2P enabled")
    func usableHostsP2P() {
        #expect(IPv4Mask(prefixLength: 31).usableHosts(allowP2P: true) == 2)
        #expect(IPv4Mask(prefixLength: 30).usableHosts(allowP2P: true) == 2)
    }
}

/// Tests for IPv4Network functionality.
@Suite("IPv4Network Tests")
struct IPv4NetworkTests {
    
    @Test("Create from CIDR - acceptance criteria")
    func createFromCIDR() {
        let network = IPv4Network(cidr: "192.168.10.42/24")
        #expect(network != nil)
        #expect(network?.networkAddress.description == "192.168.10.0")
        #expect(network?.broadcastAddress.description == "192.168.10.255")
        #expect(network?.mask.prefixLength == 24)
    }
    
    @Test("Network normalization")
    func networkNormalization() {
        // Even if we give a non-network address, it should normalize
        let network = IPv4Network(cidr: "192.168.10.42/24")
        #expect(network?.networkAddress.description == "192.168.10.0")
    }
    
    @Test("Usable range - standard /24")
    func usableRangeStandard() {
        let network = IPv4Network(cidr: "192.168.10.0/24")!
        #expect(network.firstUsableAddress(allowP2P: false)?.description == "192.168.10.1")
        #expect(network.lastUsableAddress(allowP2P: false)?.description == "192.168.10.254")
        #expect(network.usableHosts(allowP2P: false) == 254)
    }
    
    @Test("Usable range - /31 without P2P")
    func usableRange31WithoutP2P() {
        let network = IPv4Network(cidr: "203.0.113.10/31")!
        #expect(network.firstUsableAddress(allowP2P: false) == nil)
        #expect(network.lastUsableAddress(allowP2P: false) == nil)
        #expect(network.usableHosts(allowP2P: false) == 0)
    }
    
    @Test("Usable range - /31 with P2P")
    func usableRange31WithP2P() {
        let network = IPv4Network(cidr: "203.0.113.10/31")!
        #expect(network.firstUsableAddress(allowP2P: true)?.description == "203.0.113.10")
        #expect(network.lastUsableAddress(allowP2P: true)?.description == "203.0.113.11")
        #expect(network.usableHosts(allowP2P: true) == 2)
    }
    
    @Test("Usable range - /32")
    func usableRange32() {
        let network = IPv4Network(cidr: "192.168.1.1/32")!
        #expect(network.firstUsableAddress(allowP2P: false) == nil)
        #expect(network.lastUsableAddress(allowP2P: false) == nil)
        #expect(network.usableHosts(allowP2P: false) == 0)
    }
    
    @Test("Contains check")
    func containsCheck() {
        let network = IPv4Network(cidr: "192.168.10.0/24")!
        #expect(network.contains(IPv4Address(string: "192.168.10.1")!) == true)
        #expect(network.contains(IPv4Address(string: "192.168.11.1")!) == false)
    }
    
    @Test("Subdivision into 4 - acceptance criteria")
    func subdivisionInto4() {
        let network = IPv4Network(cidr: "192.168.10.0/24")!
        let subnets = network.subdivide(into: 4)
        
        #expect(subnets != nil)
        #expect(subnets?.count == 4)
        
        // Check each subnet matches acceptance criteria
        #expect(subnets?[0].description == "192.168.10.0/26")
        #expect(subnets?[0].firstUsableAddress(allowP2P: false)?.description == "192.168.10.1")
        #expect(subnets?[0].lastUsableAddress(allowP2P: false)?.description == "192.168.10.62")
        #expect(subnets?[0].broadcastAddress.description == "192.168.10.63")
        
        #expect(subnets?[1].description == "192.168.10.64/26")
        #expect(subnets?[1].firstUsableAddress(allowP2P: false)?.description == "192.168.10.65")
        #expect(subnets?[1].lastUsableAddress(allowP2P: false)?.description == "192.168.10.126")
        #expect(subnets?[1].broadcastAddress.description == "192.168.10.127")
        
        #expect(subnets?[2].description == "192.168.10.128/26")
        #expect(subnets?[2].firstUsableAddress(allowP2P: false)?.description == "192.168.10.129")
        #expect(subnets?[2].lastUsableAddress(allowP2P: false)?.description == "192.168.10.190")
        #expect(subnets?[2].broadcastAddress.description == "192.168.10.191")
        
        #expect(subnets?[3].description == "192.168.10.192/26")
        #expect(subnets?[3].firstUsableAddress(allowP2P: false)?.description == "192.168.10.193")
        #expect(subnets?[3].lastUsableAddress(allowP2P: false)?.description == "192.168.10.254")
        #expect(subnets?[3].broadcastAddress.description == "192.168.10.255")
    }
}

/// Tests for VLSM planning functionality.
@Suite("VLSM Tests")
struct VLSMTests {
    
    @Test("VLSM planning - acceptance criteria")
    func vlsmAcceptanceCriteria() {
        let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: false)
        let baseNetwork = IPv4Network(cidr: "10.0.0.0/24")!
        let requirements: [VLSMRequirement] = [.hosts(50), .hosts(20), .hosts(10), .hosts(5)]
        
        let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)
        
        guard case .success(let allocations, let freeBlocks) = result else {
            Issue.record("VLSM planning should succeed")
            return
        }
        
        #expect(allocations.count == 4)
        
        // First allocation: 50 hosts needs /26 (62 usable)
        #expect(allocations[0].network.mask.prefixLength == 26)
        #expect(allocations[0].network.networkAddress.description == "10.0.0.0")
        #expect(allocations[0].network.usableHosts(allowP2P: false) == 62)
        
        // Second allocation: 20 hosts needs /27 (30 usable)
        #expect(allocations[1].network.mask.prefixLength == 27)
        #expect(allocations[1].network.networkAddress.description == "10.0.0.64")
        #expect(allocations[1].network.usableHosts(allowP2P: false) == 30)
        
        // Third allocation: 10 hosts needs /28 (14 usable)
        #expect(allocations[2].network.mask.prefixLength == 28)
        #expect(allocations[2].network.networkAddress.description == "10.0.0.96")
        #expect(allocations[2].network.usableHosts(allowP2P: false) == 14)
        
        // Fourth allocation: 5 hosts needs /29 (6 usable)
        #expect(allocations[3].network.mask.prefixLength == 29)
        #expect(allocations[3].network.networkAddress.description == "10.0.0.112")
        #expect(allocations[3].network.usableHosts(allowP2P: false) == 6)
        
        // Should have leftover space
        #expect(freeBlocks.count > 0)
        #expect(freeBlocks[0].networkAddress.description == "10.0.0.120")
    }
    
    @Test("VLSM with CIDR requirements")
    func vlsmWithCIDR() {
        let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: false)
        let baseNetwork = IPv4Network(cidr: "10.0.0.0/24")!
        let requirements: [VLSMRequirement] = [.cidr(26), .cidr(27)]
        
        let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)
        
        guard case .success(let allocations, _) = result else {
            Issue.record("VLSM planning should succeed")
            return
        }
        
        #expect(allocations.count == 2)
        #expect(allocations[0].network.mask.prefixLength == 26)
        #expect(allocations[1].network.mask.prefixLength == 27)
    }
    
    @Test("VLSM failure - insufficient space")
    func vlsmFailure() {
        let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: false)
        let baseNetwork = IPv4Network(cidr: "192.168.1.0/30")! // Only 4 addresses
        let requirements: [VLSMRequirement] = [.hosts(10)] // Needs more than 4
        
        let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)
        
        guard case .failure(let failedReq, let allocations, _) = result else {
            Issue.record("VLSM planning should fail")
            return
        }
        
        #expect(allocations.isEmpty)
        if case .hosts(let count) = failedReq {
            #expect(count == 10)
        }
    }
    
    @Test("VLSM with P2P enabled for 2 hosts")
    func vlsmWithP2P() {
        let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: true)
        let baseNetwork = IPv4Network(cidr: "192.168.1.0/24")!
        let requirements: [VLSMRequirement] = [.hosts(2)]
        
        let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)
        
        guard case .success(let allocations, _) = result else {
            Issue.record("VLSM planning should succeed")
            return
        }
        
        #expect(allocations.count == 1)
        #expect(allocations[0].network.mask.prefixLength == 31)
    }
}

/// Tests for export functionality.
@Suite("Export Tests")
struct ExportTests {
    
    @Test("Export to JSON")
    func exportJSON() throws {
        let network = IPv4Network(cidr: "192.168.1.0/24")!
        let data = [SubnetExportData(network: network, label: "Test Network")]
        
        let json = try SubnetExporter.exportJSON(data)
        #expect(json.contains("\"subnet\" : \"192.168.1.0\""))
        #expect(json.contains("\"prefix\" : 24"))
        #expect(json.contains("\"label\" : \"Test Network\""))
    }
    
    @Test("Export to CSV")
    func exportCSV() {
        let network = IPv4Network(cidr: "192.168.1.0/24")!
        let data = [SubnetExportData(network: network, label: "Test Network")]
        
        let csv = SubnetExporter.exportCSV(data)
        #expect(csv.contains("Subnet,Prefix,Netmask"))
        #expect(csv.contains("192.168.1.0,24,255.255.255.0"))
        #expect(csv.contains("Test Network"))
    }
    
    @Test("Export VLSM allocations")
    func exportVLSMAllocations() throws {
        let planner = VLSMPlanner(reserveNetworkBroadcast: true, allowP2P: false)
        let baseNetwork = IPv4Network(cidr: "10.0.0.0/24")!
        let requirements: [VLSMRequirement] = [.hosts(50)]
        
        let result = planner.plan(baseNetwork: baseNetwork, requirements: requirements)
        
        guard case .success(let allocations, _) = result else {
            Issue.record("VLSM planning should succeed")
            return
        }
        
        let json = try SubnetExporter.exportVLSMJSON(allocations)
        #expect(json.contains("\"subnet\" : \"10.0.0.0\""))
        
        let csv = SubnetExporter.exportVLSMCSV(allocations)
        #expect(csv.contains("10.0.0.0,26"))
    }
}
