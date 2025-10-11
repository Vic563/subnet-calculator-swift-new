import Foundation

/// Represents a requirement for VLSM planning.
public enum VLSMRequirement: Equatable {
    /// Requirement specified by number of hosts needed.
    case hosts(Int)
    
    /// Requirement specified by desired CIDR prefix length.
    case cidr(Int)
    
    /// Get the display string for this requirement.
    public var displayString: String {
        switch self {
        case .hosts(let count):
            return "\(count) hosts"
        case .cidr(let prefix):
            return "/\(prefix)"
        }
    }
}

/// An allocated subnet in a VLSM plan.
public struct VLSMAllocation: Equatable {
    /// The allocated network.
    public let network: IPv4Network
    
    /// The original requirement that was satisfied.
    public let requirement: VLSMRequirement
    
    /// Optional user-defined label.
    public var label: String?
    
    /// Whether this allocation is locked (prevents reallocation).
    public var isLocked: Bool
    
    public init(network: IPv4Network, requirement: VLSMRequirement, label: String? = nil, isLocked: Bool = false) {
        self.network = network
        self.requirement = requirement
        self.label = label
        self.isLocked = isLocked
    }
}

/// Result of a VLSM planning operation.
public enum VLSMResult {
    /// Planning succeeded with allocations and remaining free space.
    case success(allocations: [VLSMAllocation], freeBlocks: [IPv4Network])
    
    /// Planning failed because a requirement couldn't fit.
    case failure(failedRequirement: VLSMRequirement, allocations: [VLSMAllocation], freeBlocks: [IPv4Network])
}

/// VLSM (Variable Length Subnet Masking) planner using largest-first best-fit allocation.
public class VLSMPlanner {
    /// Whether to reserve network and broadcast addresses (default: true).
    public var reserveNetworkBroadcast: Bool
    
    /// Whether to allow /31 for point-to-point links (RFC 3021).
    public var allowP2P: Bool
    
    public init(reserveNetworkBroadcast: Bool = true, allowP2P: Bool = false) {
        self.reserveNetworkBroadcast = reserveNetworkBroadcast
        self.allowP2P = allowP2P
    }
    
    /// Normalize a requirement to a prefix length.
    /// - Parameter requirement: The requirement to normalize
    /// - Returns: The required prefix length, or nil if invalid
    private func normalizeRequirement(_ requirement: VLSMRequirement) -> Int? {
        switch requirement {
        case .hosts(let count):
            guard count > 0 else { return nil }
            
            // Special case: 2 hosts with P2P allowed
            if count == 2 && allowP2P {
                return 31
            }
            
            // Calculate required host bits
            let neededAddresses = reserveNetworkBroadcast ? count + 2 : count
            
            // Find smallest b such that 2^b >= neededAddresses
            var hostBits = 0
            var capacity = 1
            while capacity < neededAddresses {
                hostBits += 1
                capacity *= 2
            }
            
            let prefix = 32 - hostBits
            guard prefix >= 0 && prefix <= 32 else { return nil }
            return prefix
            
        case .cidr(let prefix):
            guard prefix >= 0 && prefix <= 32 else { return nil }
            return prefix
        }
    }
    
    /// Plan VLSM allocations for the given requirements within the base network.
    /// - Parameters:
    ///   - baseNetwork: The base network to subdivide
    ///   - requirements: The list of requirements to allocate
    /// - Returns: The result of the planning operation
    public func plan(baseNetwork: IPv4Network, requirements: [VLSMRequirement]) -> VLSMResult {
        // Normalize requirements to prefix lengths
        var normalizedReqs: [(requirement: VLSMRequirement, prefix: Int)] = []
        for req in requirements {
            guard let prefix = normalizeRequirement(req) else {
                return .failure(failedRequirement: req, allocations: [], freeBlocks: [baseNetwork])
            }
            normalizedReqs.append((req, prefix))
        }
        
        // Sort by largest block first (smallest prefix value)
        normalizedReqs.sort { $0.prefix < $1.prefix }
        
        // Initialize free list with base network
        var freeBlocks = [baseNetwork]
        var allocations: [VLSMAllocation] = []
        
        // Allocate each requirement
        for (req, requiredPrefix) in normalizedReqs {
            // Find first free block that can fit this requirement
            guard let (blockIndex, block) = findFittingBlock(in: freeBlocks, forPrefix: requiredPrefix) else {
                return .failure(failedRequirement: req, allocations: allocations, freeBlocks: freeBlocks)
            }
            
            // Remove the block from free list
            freeBlocks.remove(at: blockIndex)
            
            // Split the block if needed
            var currentBlock = block
            while currentBlock.mask.prefixLength < requiredPrefix {
                let (left, right) = splitBlock(currentBlock)
                currentBlock = left
                freeBlocks.insert(right, at: 0) // Insert at beginning to maintain order
            }
            
            // Allocate the block
            allocations.append(VLSMAllocation(network: currentBlock, requirement: req))
        }
        
        return .success(allocations: allocations, freeBlocks: freeBlocks)
    }
    
    /// Find the first free block that can fit a network with the given prefix.
    private func findFittingBlock(in freeBlocks: [IPv4Network], forPrefix prefix: Int) -> (index: Int, block: IPv4Network)? {
        for (index, block) in freeBlocks.enumerated() {
            if block.mask.prefixLength <= prefix {
                return (index, block)
            }
        }
        return nil
    }
    
    /// Split a network block into two equal halves.
    private func splitBlock(_ block: IPv4Network) -> (left: IPv4Network, right: IPv4Network) {
        let newPrefix = block.mask.prefixLength + 1
        let halfSize = UInt32(1) << (32 - newPrefix)
        
        let leftAddress = block.networkAddress
        let rightAddress = IPv4Address(rawValue: block.networkAddress.rawValue + halfSize)
        
        return (
            IPv4Network(address: leftAddress, prefixLength: newPrefix),
            IPv4Network(address: rightAddress, prefixLength: newPrefix)
        )
    }
}
