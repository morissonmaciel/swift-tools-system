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
- **🆕 ToolRegistry** for dynamic API response handling
- **🆕 Required examples** for all tool arguments
- **🆕 Enhanced type support** (String, Int, Bool, Double, Float)

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
    @ToolArgument("request", "API request configuration", example: "https://api.example.com/data")
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

## Implementation Requirements

⚠️ **Important**: The access level of the `call` method and `@ToolArgument` structs must match the access level of your tool struct.

```swift
// ✅ Public tool requires public call method and argument structs
@Tool("my_tool", "Description")
public struct MyTool {
    @ToolArgument("input", "Description", example: "sample input")
    public struct InputArg {
        public let value: String
    }
    
    public func call(arguments: [Argument]) async throws -> ToolOutput {
        // Implementation
    }
}

// ✅ Internal tool can have internal call method and argument structs
@Tool("my_tool", "Description")
struct MyTool {
    @ToolArgument("input", "Description", example: "sample input")
    struct InputArg {
        let value: String
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        // Implementation - internal access is fine
    }
}

// ❌ Incorrect - access level mismatch
@Tool("my_tool", "Description")
public struct MyTool {
    @ToolArgument("input", "Description", example: "sample input")
    struct InputArg {  // Should be public
        let value: String  // Should be public
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        // This will cause compilation errors - all components need to be public
    }
}
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
print(GreetingTool.jsonDescription) // Get JSON descriptor
```

**JSON Descriptor Output:**
```json
{
  "tool_name": "greet",
  "description": "Returns a friendly greeting",
  "arguments": [],
  "example": {
    "tool_name": "greet",
    "arguments": {}
  }
}
```

### Level 2: Single Argument Tool

Add structured input to your tool:

```swift
@Tool("calculate_square", "Calculates the square of a number")
struct SquareCalculator {
    @ToolArgument("number", "The number to square", example: "5.0")
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

**JSON Descriptor Output:**
```json
{
  "tool_name": "calculate_square",
  "description": "Calculates the square of a number",
  "arguments": [
    {
      "name": "number",
      "description": "The number to square",
      "type": {
        "type": "object"
      }
    }
  ],
  "example": {
    "tool_name": "calculate_square",
    "arguments": {}
  }
}
```

### Level 3: Multiple Properties with Validation

Create tools with complex argument structures:

```swift
@Tool("format_text", "Formats text with various styling options")
struct TextFormatter {
    @ToolArgument("format_options", "Text formatting configuration", example: "hello world")
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
    @ToolArgument("dataset", "The numbers to analyze", example: "[1,2,3,4,5]")
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
    @ToolArgument("file_operation", "File processing configuration", example: "/path/to/file.txt")
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

Every tool automatically provides a comprehensive JSON descriptor with improved structure:

```swift
// Access JSON description (static method)
print(FileProcessor.jsonDescription)

// Access the structured descriptor
let descriptor = FileProcessor.toolDescriptor
print("Tool name: \(descriptor.tool_name)")
print("Description: \(descriptor.description)")
print("Arguments count: \(descriptor.arguments.count)")
print("Example: \(descriptor.example?.tool_name ?? "none")")
```

**New Improved JSON Structure Features:**
- **`tool_name`** field for clear tool identification (instead of generic `name`)
- **Simplified arguments** with `name`, `description`, and `type` fields
- **Example section** showing sample usage patterns
- **Type mapping** from Swift types to JSON schema types (`string`, `number`, `boolean`, `object`, `array`)
- **Static access** - no need to instantiate tools to get descriptors
- **Clean JSON output** with sorted keys and proper formatting

**Before vs After Comparison:**
```json
// Before (old structure)
{
  "name": "web_search",
  "description": "Search web for results",
  "returnType": "ToolOutput",
  "properties": [
    {
      "name": "query", 
      "type": "QueryArgument",
      "description": "Query string to search web for"
    }
  ]
}

// After (new improved structure)
{
  "tool_name": "web_search",
  "description": "Search web for results", 
  "arguments": [
    {
      "name": "query",
      "description": "Query string to search web for",
      "type": {
        "type": "object"
      }
    }
  ],
  "example": {
    "tool_name": "web_search",
    "arguments": {}
  }
}
```

This enables:
- **API Documentation**: Auto-generate OpenAPI specs
- **Tool Discovery**: Dynamically find and describe available tools
- **Validation**: Verify argument structures before execution
- **Integration**: Easy integration with external systems and AI platforms

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
return .dictionary(["name": "John", "age": 30, "active": true])
return .dictionaryArray([["id": 1, "name": "Alice"], ["id": 2, "name": "Bob"]])
return .data(binaryData)
```

### Direct Value Access with `wrappedValue`

All `ToolOutput` cases provide direct access to their underlying values via the `wrappedValue` property:

```swift
@Tool("example_tool", "Demonstrates direct value access")
struct ExampleTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .dictionary(["name": "John", "age": 30, "active": true])
    }
}

// Usage with direct value access
let tool = ExampleTool()
let result = try await tool.call(arguments: [])

// Direct access without pattern matching
let dictionary = result.wrappedValue as? [String: any Codable & Sendable]
let name = dictionary?["name"] as? String  // "John"
let age = dictionary?["age"] as? Int       // 30
let active = dictionary?["active"] as? Bool // true

// Compare with traditional pattern matching
if case .dictionary(let dict) = result {
    let name = dict["name"] as? String
    // ... same but more verbose
}

// Works with all output types
let stringOutput = ToolOutput.string("Hello")
let stringValue = stringOutput.wrappedValue as? String // "Hello"

let arrayOutput = ToolOutput.dictionaryArray([["id": 1], ["id": 2]])
let arrayValue = arrayOutput.wrappedValue as? [[String: any Codable & Sendable]]
```

### Dictionary and Dictionary Array Output with Pretty JSON

The `.dictionary` and `.dictionaryArray` cases provide structured key-value data with automatic pretty-printing:

```swift
@Tool("user_info", "Get user information")
struct UserInfoTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .dictionary([
            "user": "john_doe",
            "profile": [
                "name": "John Doe",
                "age": 30,
                "location": "San Francisco"
            ],
            "permissions": ["read", "write"],
            "active": true,
            "last_login": "2024-01-15T10:30:00Z"
        ])
    }
}

// Usage
let tool = UserInfoTool()
let result = try await tool.call(arguments: [])
print(result.description)
// Outputs clean, pretty-formatted JSON:
// {
//   "active" : true,
//   "last_login" : "2024-01-15T10:30:00Z",
//   "permissions" : [
//     "read",
//     "write"
//   ],
//   "profile" : {
//     "age" : 30,
//     "location" : "San Francisco",
//     "name" : "John Doe"
//   },
//   "user" : "john_doe"
// }
//
// Note: URLs are not escaped (https://example.com, not https:\/\/example.com)

// Dictionary Array Example
@Tool("list_users", "Get list of users")
struct UserListTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .dictionaryArray([
            [
                "id": 1,
                "name": "Alice Smith",
                "email": "alice@example.com",
                "active": true
            ],
            [
                "id": 2,
                "name": "Bob Johnson", 
                "email": "bob@example.com",
                "active": false
            ],
            [
                "id": 3,
                "name": "Charlie Brown",
                "email": "charlie@example.com", 
                "active": true
            ]
        ])
    }
}

// Usage
let userList = UserListTool()
let result = try await userList.call(arguments: [])
print(result.description)
// Outputs clean, pretty-formatted JSON array:
// [
//   {
//     "active" : true,
//     "email" : "alice@example.com",
//     "id" : 1,
//     "name" : "Alice Smith"
//   },
//   {
//     "active" : false,
//     "email" : "bob@example.com",
//     "id" : 2,
//     "name" : "Bob Johnson"
//   },
//   {
//     "active" : true,
//     "email" : "charlie@example.com",
//     "id" : 3,
//     "name" : "Charlie Brown"
//   }
// ]
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

## Type Erasure with AnyTool

When working with tools in `Codable` contexts where you need to store `any ToolProtocol`, use the `AnyTool` wrapper:

```swift
struct ThreadModelResponse: Codable {
    let id: String
    let tool: AnyTool?  // Instead of: var tool: (any ToolProtocol)?
}

// Usage
let calcTool = CalcSquareRoot()
let anyTool = AnyTool(calcTool)
let response = ThreadModelResponse(id: "123", tool: anyTool)

// Execute the wrapped tool
let inputArgument = CalcSquareRoot.InputArgument(number: 16.0)
let result = try await anyTool.call(arguments: [inputArgument])

// Serialize/deserialize the response
let encoder = JSONEncoder()
let data = try encoder.encode(response)
let decodedResponse = try JSONDecoder().decode(ThreadModelResponse.self, from: data)

// Note: Decoded AnyTool instances preserve tool metadata but cannot execute
// since the original tool implementation is lost during encoding
```

## Troubleshooting

### Type Conversion Errors

If you see an error like:
```
cannot convert value of type 'YourTool.YourArgument' to expected element type 'Array<YourTool.Argument>.ArrayLiteralElement' (aka 'EmptyArgument')
```

**Solution**: Make sure your argument struct has the `@ToolArgument` attribute:

```swift
// ✅ Correct - struct has @ToolArgument attribute
@Tool("web_search", "Search web for results")
struct WebSearchTool {
    @ToolArgument("query", "Query string to search web for", example: "latest news")  // ← Required!
    struct QueryArgument {
        var query: String
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let args = try arguments.decode(QueryArgument.self)
        // ... implementation
    }
}

// ❌ Incorrect - missing @ToolArgument attribute
@Tool("web_search", "Search web for results")
struct WebSearchTool {
    struct QueryArgument {  // ← Missing @ToolArgument attribute
        var query: String
    }
    // This will cause type conversion errors
}
```

### Access Level Requirements

The `call` method's access level must match your tool struct's access level:

```swift
// For public tools
public struct MyTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        // Implementation
    }
}

// For internal tools  
struct MyTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        // Implementation
    }
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

# Run specific test suite (use filtering for focused testing)
swift test --filter ToolExecutionTests

# Run specific test methods
swift test --filter testToolDescriptorImplementation

# Run tests with verbose output
swift test --verbose

# Run tests in parallel
swift test --parallel

# Run tests for specific modules
swift test --filter ToolsSystemMacrosTests
swift test --filter ToolsSystemTests
```

## 🆕 ToolRegistry for API Response Handling

The ToolRegistry enables dynamic handling of tool calls from API responses, perfect for AI systems and external integrations.

### Basic Usage

```swift
import ToolsSystem

// 1. Register your tool handlers at app startup
let registry = ToolRegistry.shared

registry.register(toolName: "web_search") { toolCall in
    let query = toolCall.getString("query") ?? "default"
    let maxResults = toolCall.get("maxResults", as: Int.self, default: 10)
    
    // Your implementation
    return await performWebSearch(query: query, maxResults: maxResults)
}

// 2. Handle API responses with your exact JSON format
let jsonString = """
{
  "message": "I need up to date information. Let me search on the web",
  "tool": {
      "arguments": {
        "query": "latest news WWDC25",
        "maxResults": 5
      },
      "tool_name": "web_search"
    }
}
"""

// 3. Decode and execute
let response = try JSONDecoder().decode(ToolResponse.self, from: jsonData)
if let tool = response.tool {
    let result = try await registry.handleTool(tool)
    print("Result: \(result)")
}
```

### Enhanced Type Support

```swift
// Multiple ways to access arguments
toolCall.getString("query")                          // String?
toolCall.getInt("maxResults")                        // Int?
toolCall.getBool("includeCode")                      // Bool?
toolCall.getDouble("score")                          // Double?
toolCall.getFloat("ratio")                           // Float?

// Generic type access
toolCall.get("query", as: String.self)               // String?
toolCall.get("maxResults", as: Int.self)             // Int?

// Get with default values
toolCall.get("query", as: String.self, default: "default")
toolCall.get("maxResults", as: Int.self, default: 10)

// Helper methods
toolCall.hasArgument("query")                        // Bool
toolCall.argumentKeys                                // [String]
```

### Error Handling

```swift
do {
    let result = try await registry.handleTool(toolCall)
} catch ToolRegistryError.unknownTool(let toolName) {
    print("Unknown tool: \(toolName)")
    print("Available tools: \(registry.registeredTools)")
} catch ToolRegistryError.executionFailed(let reason) {
    print("Execution failed: \(reason)")
}
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
