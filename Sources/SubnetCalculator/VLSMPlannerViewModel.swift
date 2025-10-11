import Foundation

/// View model for VLSM planning.
/// This is a simple observable class that can be used with SwiftUI on macOS/iOS
/// or manually on other platforms.
public class VLSMPlannerViewModel {
    
    // MARK: - Properties (Input)
    
    /// The base network CIDR input string.
    public var baseNetworkInput: String = "" {
        didSet { updateBaseNetwork() }
    }
    
    /// The requirements input (comma-separated list of host counts or CIDRs).
    public var requirementsInput: String = "" {
        didSet { updateRequirements() }
    }
    
    /// Whether to reserve network and broadcast addresses.
    public var reserveNetworkBroadcast: Bool = true {
        didSet {
            planner.reserveNetworkBroadcast = reserveNetworkBroadcast
            runPlanning()
        }
    }
    
    /// Whether to allow /31 for point-to-point links.
    public var allowP2P: Bool = false {
        didSet {
            planner.allowP2P = allowP2P
            runPlanning()
        }
    }
    
    // MARK: - Properties (Output)
    
    /// The base network, if valid.
    public private(set) var baseNetwork: IPv4Network?
    
    /// Parsed requirements.
    public private(set) var requirements: [VLSMRequirement] = []
    
    /// The planning result.
    public private(set) var planResult: VLSMResult?
    
    /// Validation error message, if any.
    public private(set) var errorMessage: String?
    
    /// Success indicator.
    public private(set) var isSuccess: Bool = false
    
    /// Allocations from the plan (empty if failed).
    public var allocations: [VLSMAllocation] {
        guard let result = planResult else { return [] }
        switch result {
        case .success(let allocs, _):
            return allocs
        case .failure(_, let allocs, _):
            return allocs
        }
    }
    
    /// Free blocks from the plan.
    public var freeBlocks: [IPv4Network] {
        guard let result = planResult else { return [] }
        switch result {
        case .success(_, let blocks):
            return blocks
        case .failure(_, _, let blocks):
            return blocks
        }
    }
    
    /// Failed requirement, if planning failed.
    public var failedRequirement: VLSMRequirement? {
        guard let result = planResult else { return nil }
        switch result {
        case .success:
            return nil
        case .failure(let req, _, _):
            return req
        }
    }
    
    /// Total allocated addresses.
    public var totalAllocated: UInt32 {
        allocations.reduce(0) { $0 + $1.network.totalAddresses }
    }
    
    /// Total free addresses.
    public var totalFree: UInt32 {
        freeBlocks.reduce(0) { $0 + $1.totalAddresses }
    }
    
    /// Summary message.
    public var summaryMessage: String {
        if let baseNet = baseNetwork {
            let total = baseNet.totalAddresses
            return "Base: \(baseNet) (\(total) addresses) | Allocated: \(totalAllocated) | Free: \(totalFree)"
        }
        return ""
    }
    
    // MARK: - Private Properties
    
    private let planner: VLSMPlanner
    
    // MARK: - Initialization
    
    public init() {
        self.planner = VLSMPlanner()
    }
    
    // MARK: - Private Methods
    
    private func updateBaseNetwork() {
        let input = baseNetworkInput
        guard !input.isEmpty else {
            baseNetwork = nil
            errorMessage = nil
            runPlanning()
            return
        }
        
        if let network = IPv4Network(cidr: input) {
            baseNetwork = network
            errorMessage = nil
        } else {
            baseNetwork = nil
            errorMessage = "Invalid base network. Example: 10.0.0.0/24"
        }
        runPlanning()
    }
    
    private func updateRequirements() {
        let input = requirementsInput
        guard !input.isEmpty else {
            requirements = []
            errorMessage = nil
            runPlanning()
            return
        }
        
        let parts = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var reqs: [VLSMRequirement] = []
        
        for part in parts {
            if part.hasPrefix("/") {
                // CIDR requirement
                if let prefix = Int(part.dropFirst()), prefix >= 0 && prefix <= 32 {
                    reqs.append(.cidr(prefix))
                } else {
                    errorMessage = "Invalid CIDR in requirements: \(part)"
                    requirements = []
                    runPlanning()
                    return
                }
            } else {
                // Host count requirement
                if let count = Int(part), count > 0 {
                    reqs.append(.hosts(count))
                } else {
                    errorMessage = "Invalid host count in requirements: \(part)"
                    requirements = []
                    runPlanning()
                    return
                }
            }
        }
        
        requirements = reqs
        errorMessage = nil
        runPlanning()
    }
    
    private func runPlanning() {
        guard let baseNet = baseNetwork, !requirements.isEmpty else {
            planResult = nil
            isSuccess = false
            return
        }
        
        let result = planner.plan(baseNetwork: baseNet, requirements: requirements)
        planResult = result
        
        switch result {
        case .success:
            isSuccess = true
            errorMessage = nil
        case .failure(let failedReq, _, _):
            isSuccess = false
            errorMessage = "Failed to allocate: \(failedReq.displayString)"
        }
    }
    
    // MARK: - Public Methods
    
    /// Manually refresh the planning.
    public func refresh() {
        runPlanning()
    }
    
    /// Export allocations to JSON.
    public func exportJSON() throws -> String {
        try SubnetExporter.exportVLSMJSON(allocations, allowP2P: allowP2P)
    }
    
    /// Export allocations to CSV.
    public func exportCSV() -> String {
        SubnetExporter.exportVLSMCSV(allocations, allowP2P: allowP2P)
    }
    
    /// Add a label to an allocation.
    public func setLabel(_ label: String, forAllocationAt index: Int) {
        guard let result = planResult else { return }
        
        var allocs: [VLSMAllocation]
        let blocks: [IPv4Network]
        
        switch result {
        case .success(let allocations, let freeBlocks):
            allocs = allocations
            blocks = freeBlocks
        case .failure(_, let allocations, let freeBlocks):
            allocs = allocations
            blocks = freeBlocks
        }
        
        guard index >= 0 && index < allocs.count else { return }
        allocs[index].label = label
        
        planResult = .success(allocations: allocs, freeBlocks: blocks)
    }
    
    /// Toggle lock status for an allocation.
    public func toggleLock(forAllocationAt index: Int) {
        guard let result = planResult else { return }
        
        var allocs: [VLSMAllocation]
        let blocks: [IPv4Network]
        
        switch result {
        case .success(let allocations, let freeBlocks):
            allocs = allocations
            blocks = freeBlocks
        case .failure(_, let allocations, let freeBlocks):
            allocs = allocations
            blocks = freeBlocks
        }
        
        guard index >= 0 && index < allocs.count else { return }
        allocs[index].isLocked = !allocs[index].isLocked
        
        planResult = .success(allocations: allocs, freeBlocks: blocks)
    }
}
