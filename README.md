# swift-tools-system

A Swift package providing type-safe, executable tools with macro-based code generation and JSON descriptors.

## Overview

ToolsSystemMacros enables you to build executable tools that can be integrated into applications, APIs, or AI systems. The framework uses Swift macros to automatically generate boilerplate code, ensuring type safety and reducing manual implementation effort. Tools come with built-in JSON descriptors for easy integration and documentation.

## Features

- **Type-safe tool definitions** with compile-time validation
- **Automatic code generation** via Swift macros
- **Asynchronous execution** with full async/await support
- **Structured argument handling** with validation
- **Multiple output types** including primitives and arrays
- **JSON descriptors** for API documentation and discovery
- **Comprehensive error handling**
- **Full serialization support**

## Async/Await Support

All tools support asynchronous execution out of the box. This enables tools to perform:
- Network requests and API calls
- File I/O operations  
- Database queries
- Long-running computations
- Any other asynchronous work

### Async Tool Example

```swift
@Tool("fetch_data", "Fetches data from a remote API")
struct DataFetcher {
    @ToolArgument("request", "API request configuration")
    struct APIRequest {
        let url: String
        let timeout: TimeInterval
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let request = try arguments.decode(APIRequest.self)
        
        // Perform async network request
        let (data, _) = try await URLSession.shared.data(from: URL(string: request.url)!)
        let response = String(data: data, encoding: .utf8) ?? ""
        
        return .string(response)
    }
}

// Usage with async/await
let fetcher = DataFetcher()
let request = DataFetcher.APIRequest(url: "https://api.example.com/data", timeout: 30.0)
let result = try await fetcher.call(arguments: [request])
```

## Project Setup

### Prerequisites

- Swift 5.9+
- macOS 14.0+ / iOS 17.0+
- Xcode 15.0+ (for development)

### Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/morissonmaciel/swift-tools-system.git", branch: "main")
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            .product(name: "ToolsSystem", package: "swift-tools-system"),
            .product(name: "ToolsSystemMacros", package: "swift-tools-system")
        ]
    )
]
```

### Build Commands

```bash
# Build the package
swift build

# Run tests
swift test

# Build in release mode
swift build -c release

# Generate documentation (if using DocC)
swift package generate-documentation
```

## Progressive Usage Guide

### Level 1: Basic Tool (No Arguments)

Start with a simple tool that requires no input:

```swift
import ToolsSystemMacros

@Tool("greet", "Returns a friendly greeting")
struct GreetingTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .string("Hello! 👋")
    }
}

// Usage
let tool = GreetingTool()
let result = try await tool.call(arguments: [])
print(tool.jsonDescription) // Get JSON descriptor
```

**JSON Descriptor Output:**
```json
{
  "arguments": [],
  "description": "Returns a friendly greeting",
  "name": "greet",
  "returnType": {
    "description": "The result of the tool execution",
    "type": "ToolOutput"
  }
}
```

### Level 2: Single Argument Tool

Add structured input to your tool:

```swift
@Tool("calculate_square", "Calculates the square of a number")
struct SquareCalculator {
    @ToolArgument("number", "The number to square")
    struct NumberInput {
        let value: Double
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let input = try arguments.decode(NumberInput.self)
        let result = input.value * input.value
        return .double(result)
    }
}

// Usage
let calculator = SquareCalculator()
let input = SquareCalculator.NumberInput(value: 5.0)
let result = try await calculator.call(arguments: [input])

if case .double(let squared) = result {
    print("5² = \(squared)") // Prints: 5² = 25.0
}
```

### Level 3: Multiple Properties with Validation

Create tools with complex argument structures:

```swift
@Tool("format_text", "Formats text with various styling options")
struct TextFormatter {
    @ToolArgument("format_options", "Text formatting configuration")
    struct FormatOptions {
        @Required let text: String
        let uppercase: Bool
        let addEmoji: Bool
        let maxLength: Int?
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let options = try arguments.decode(FormatOptions.self)
        
        var result = options.text
        
        if options.uppercase {
            result = result.uppercased()
        }
        
        if let maxLength = options.maxLength, result.count > maxLength {
            result = String(result.prefix(maxLength)) + "..."
        }
        
        if options.addEmoji {
            result = "✨ \(result) ✨"
        }
        
        return .string(result)
    }
}

// Usage
let formatter = TextFormatter()
let options = TextFormatter.FormatOptions(
    text: "hello world",
    uppercase: true,
    addEmoji: true,
    maxLength: 20
)
let result = try await formatter.call(arguments: [options])
```

### Level 4: Advanced Tool with Multiple Output Types

Handle different scenarios with various output types:

```swift
@Tool("analyze_numbers", "Performs statistical analysis on a list of numbers")
struct NumberAnalyzer {
    @ToolArgument("dataset", "The numbers to analyze")
    struct DataSet {
        let numbers: [Double]
        let operation: String // "sum", "average", "stats", "list"
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let data = try arguments.decode(DataSet.self)
        
        guard !data.numbers.isEmpty else {
            return .string("Error: Empty dataset")
        }
        
        switch data.operation {
        case "sum":
            let sum = data.numbers.reduce(0, +)
            return .double(sum)
            
        case "average":
            let avg = data.numbers.reduce(0, +) / Double(data.numbers.count)
            return .double(avg)
            
        case "stats":
            let sum = data.numbers.reduce(0, +)
            let avg = sum / Double(data.numbers.count)
            let min = data.numbers.min()!
            let max = data.numbers.max()!
            return .array([sum, avg, min, max])
            
        case "list":
            return .array(data.numbers)
            
        default:
            return .string("Unknown operation: \(data.operation)")
        }
    }
}

// Usage examples
let analyzer = NumberAnalyzer()

// Get sum
let sumInput = NumberAnalyzer.DataSet(numbers: [1, 2, 3, 4, 5], operation: "sum")
let sumResult = try await analyzer.call(arguments: [sumInput])

// Get statistics array
let statsInput = NumberAnalyzer.DataSet(numbers: [10, 20, 30], operation: "stats")
let statsResult = try await analyzer.call(arguments: [statsInput])
```

### Level 5: Real-World Example - File Processor

A production-ready tool with comprehensive error handling:

```swift
@Tool("process_file", "Processes files with various operations")
struct FileProcessor {
    @ToolArgument("file_operation", "File processing configuration")
    struct FileOperation {
        @Required let filePath: String
        @Required let operation: String // "read", "size", "exists", "info"
        let encoding: String? // For text files
        let maxSize: Int? // Maximum file size to process
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let operation = try arguments.decode(FileOperation.self)
        let url = URL(fileURLWithPath: operation.filePath)
        
        switch operation.operation {
        case "exists":
            let exists = FileManager.default.fileExists(atPath: operation.filePath)
            return .bool(exists)
            
        case "size":
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: operation.filePath)
                let size = attributes[.size] as? Int64 ?? 0
                return .int(Int(size))
            } catch {
                return .string("Error getting file size: \(error.localizedDescription)")
            }
            
        case "read":
            // Check file size limit
            if let maxSize = operation.maxSize {
                let attributes = try? FileManager.default.attributesOfItem(atPath: operation.filePath)
                let size = attributes?[.size] as? Int64 ?? 0
                if size > maxSize {
                    return .string("File too large: \(size) bytes (max: \(maxSize))")
                }
            }
            
            do {
                let content = try String(contentsOf: url)
                return .string(content)
            } catch {
                return .string("Error reading file: \(error.localizedDescription)")
            }
            
        case "info":
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: operation.filePath)
                let size = attributes[.size] as? Int64 ?? 0
                let modified = attributes[.modificationDate] as? Date ?? Date()
                let isDirectory = attributes[.type] as? FileAttributeType == .typeDirectory
                
                return .array([
                    operation.filePath,
                    Int(size),
                    modified.description,
                    isDirectory
                ])
            } catch {
                return .string("Error getting file info: \(error.localizedDescription)")
            }
            
        default:
            return .string("Unknown operation: \(operation.operation)")
        }
    }
}
```

## JSON Descriptors

Every tool automatically provides a comprehensive JSON descriptor:

```swift
let tool = FileProcessor()
print(tool.jsonDescription)

// Access the structured descriptor
let descriptor = tool.toolDescriptor
print("Tool name: \(descriptor.name)")
print("Description: \(descriptor.description)")
print("Arguments count: \(descriptor.arguments.count)")
```

This enables:
- **API Documentation**: Auto-generate OpenAPI specs
- **Tool Discovery**: Dynamically find and describe available tools
- **Validation**: Verify argument structures before execution
- **Integration**: Easy integration with external systems

## Architecture

### ToolsSystem Module
Core types and protocols:
- `ToolProtocol` - Main protocol for executable tools
- `ToolDefinition` - Tool metadata
- `ToolOutput` - Type-safe output values
- `ToolArgumentProtocol` - Argument protocol
- `ToolDescriptor` - JSON descriptor types
- `ToolError` - Standardized errors

### ToolsSystemMacros Module
Swift macros for code generation:
- `@Tool` - Generates tool conformance and descriptors
- `@ToolArgument` - Generates argument conformance
- `@Required` - Marks required properties

## Output Types

Tools support multiple output types:

```swift
return .string("Text result")
return .double(3.14159)
return .int(42)
return .bool(true)
return .array(["mixed", 123, true, 45.67])
return .data(binaryData)
```

## Error Handling

Comprehensive error handling with standardized errors:

```swift
func call(arguments: [Argument]) async throws -> ToolOutput {
    // Handle missing arguments
    guard !arguments.isEmpty else {
        throw ToolError.noArguments
    }
    
    // Handle type mismatches
    let input = try arguments.decode(MyInput.self) // Throws ToolError.invalidArgumentType
    
    // Custom error handling
    guard input.isValid else {
        return .string("Validation failed: Invalid input")
    }
    
    // ... async tool logic
    let result = await performAsyncOperation(input)
    return .string(result)
}
```

## Testing

Comprehensive test suite covering:
- Macro code generation
- Tool execution with various inputs
- Argument validation and decoding
- JSON descriptor generation
- Error handling scenarios
- Serialization round-trips

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter ToolExecutionTests

# Run tests with verbose output
swift test --verbose

# Run tests in parallel
swift test --parallel
```

## Build Commands

```bash
# Development build
swift build

# Release build (optimized)
swift build -c release

# Clean build artifacts
swift package clean

# Resolve dependencies
swift package resolve

# Update dependencies
swift package update
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `swift test`
5. Submit a pull request

## Requirements

- **Swift**: 5.9 or later
- **Platforms**: macOS 14.0+, iOS 17.0+
- **Dependencies**: Swift Syntax for macro support

## License

[Add your license information here]
