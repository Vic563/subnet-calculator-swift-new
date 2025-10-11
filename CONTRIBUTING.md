# Contributing to Subnet Studio

Thank you for your interest in contributing to Subnet Studio! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We aim to create a welcoming environment for all contributors.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/subnet-calculator-swift-new.git
   cd subnet-calculator-swift-new
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Requirements
- Swift 5.10 or later
- Xcode 14+ (for macOS development)
- Swift Package Manager (included with Swift)

### Building the Project
```bash
swift build
```

### Running Tests
```bash
swift test
```

### Running Examples
```bash
swift run SubnetCalculatorExample
```

## Making Changes

### Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions focused and concise
- Use value types (structs) where appropriate

### Testing
- Write unit tests for all new functionality
- Ensure all existing tests pass
- Aim for high test coverage
- Include edge cases in tests

### Documentation
- Update README.md for user-facing changes
- Update CHANGELOG.md following Keep a Changelog format
- Add inline code documentation for public APIs
- Include examples for new features

### Commit Messages
- Use clear, descriptive commit messages
- Start with a verb in present tense (e.g., "Add", "Fix", "Update")
- Reference issue numbers when applicable
- Keep the first line under 72 characters

Example:
```
Add support for IPv6 address parsing

- Implement IPv6Address struct
- Add tests for IPv6 parsing
- Update documentation

Fixes #123
```

## Submitting Changes

1. **Ensure all tests pass**:
   ```bash
   swift test
   ```

2. **Update documentation** as needed

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Your descriptive commit message"
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub:
   - Provide a clear title and description
   - Reference any related issues
   - Explain the motivation for the change
   - Describe how you tested the changes

## Pull Request Guidelines

- Keep PRs focused on a single feature or fix
- Write a clear description of the changes
- Include tests for new functionality
- Update documentation as needed
- Respond to review feedback promptly
- Ensure CI checks pass

## What to Contribute

### Good First Issues
- Documentation improvements
- Test coverage improvements
- Bug fixes
- Example enhancements

### Feature Ideas
- IPv6 support
- Additional export formats
- Performance optimizations
- Accessibility improvements
- UI enhancements (for future SwiftUI implementation)

### Bug Reports
When reporting bugs, please include:
- Swift version
- Operating system and version
- Steps to reproduce
- Expected vs. actual behavior
- Relevant code snippets or test cases

### Feature Requests
When requesting features, please include:
- Use case description
- Proposed API or interface
- Any alternative approaches considered
- Willingness to implement (if applicable)

## Project Structure

```
subnet-calculator-swift-new/
├── Sources/
│   └── SubnetCalculator/
│       ├── IPv4Address.swift       # IPv4 address model
│       ├── IPv4Mask.swift          # Subnet mask model
│       ├── IPv4Network.swift       # Network model
│       ├── VLSMPlanner.swift       # VLSM allocation algorithm
│       ├── SubnetExporter.swift    # Export functionality
│       ├── SubnetCalculatorViewModel.swift  # Regular subnet VM
│       └── VLSMPlannerViewModel.swift       # VLSM planner VM
├── Tests/
│   └── SubnetCalculatorTests/
│       └── SubnetCalculatorTests.swift
├── Examples/
│   └── main.swift
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

## Core Algorithms

### VLSM Planning
The VLSM planner uses a largest-first best-fit algorithm:
1. Normalize requirements to prefix lengths
2. Sort by largest block first (smallest prefix)
3. Allocate from a free list, splitting blocks as needed
4. Track remaining free space

When modifying the VLSM algorithm:
- Maintain O(r log r) complexity
- Ensure deterministic allocation order
- Validate with the existing acceptance criteria
- Add tests for edge cases

### Subnet Calculations
- Use bitwise operations for efficiency
- Handle /31 and /32 edge cases correctly
- Respect the allowP2P flag for RFC 3021 compliance
- Validate all inputs thoroughly

## Testing Guidelines

### Unit Tests
- Use the Swift Testing framework
- Organize tests into suites by component
- Test both success and failure cases
- Include edge cases (0, 32, /31, /32, etc.)
- Validate against PRD acceptance criteria

### Test Coverage
Aim to test:
- Valid inputs
- Invalid inputs
- Edge cases
- Error conditions
- Boundary conditions

## Questions?

If you have questions about contributing, please:
- Check existing issues and pull requests
- Open a new issue for discussion
- Reach out to the maintainers

## License

By contributing to Subnet Studio, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to Subnet Studio! 🎉
