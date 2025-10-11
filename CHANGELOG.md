# Changelog

All notable changes to Subnet Studio will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-11

### Added
- Initial release of Subnet Studio
- Core IPv4 address, mask, and network models
- Regular subnet calculations
  - Network and broadcast address computation
  - Usable host range calculation
  - Netmask and wildcard mask
  - Binary representation
  - Network class detection
  - Subnet subdivision (split into N equal parts)
- VLSM (Variable Length Subnet Masking) planning
  - Largest-first best-fit allocation algorithm
  - Support for host-count and CIDR requirements
  - Automatic prefix calculation
  - Free space tracking
  - Allocation success/failure reporting
- RFC 3021 support for /31 point-to-point networks
- Export functionality
  - CSV export with proper quoting
  - JSON export with pretty printing
  - Export for single networks and VLSM plans
- View models for UI integration
  - `SubnetCalculatorViewModel` for regular calculations
  - `VLSMPlannerViewModel` for VLSM planning
  - Property-based reactive updates
  - Validation and error handling
- Comprehensive test suite (29 unit tests)
  - IPv4Address parsing and manipulation tests
  - IPv4Mask validation tests
  - IPv4Network calculation tests
  - VLSM planning tests with edge cases
  - Export functionality tests
- Complete documentation
  - Comprehensive README with examples
  - API documentation for all public types
  - Working examples demonstrating all features
  - Acceptance criteria validation

### Technical Details
- Swift 6.2 compatible
- Linux and macOS support
- No external dependencies
- Value types for immutability and safety
- Bitwise operations for efficient calculations
- O(r log r) VLSM allocation complexity

## [Unreleased]

### Planned for v1.1
- SwiftUI views with Dark Mode support
- Keyboard shortcuts (⌘1, ⌘2, ⌘E, ⌘C, ⌘L)
- Accessibility improvements (VoiceOver labels)
- History and persistence of recent calculations
- Color tags and custom labels for allocations
- Route summarization suggestions

### Planned for v2.0
- IPv6 support
- Advanced export formats (YAML)
- Router configuration templates
- Multi-environment presets
