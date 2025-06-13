//
//  ToolDescriptor.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Comprehensive JSON descriptor for a tool including its arguments and metadata.
///
/// `ToolDescriptor` provides a structured representation of a tool that can be
/// serialized to JSON for API documentation, tool discovery, or integration with
/// external systems.
///
/// Example JSON output:
/// ```json
/// {
///   "tool_name": "web_search",
///   "description": "Search the web for results based on a query string.",
///   "arguments": [
///     {
///       "name": "query",
///       "description": "The query string to search the web for.",
///       "type": {
///         "type": "string"
///       }
///     }
///   ],
///   "example": {
///     "tool_name": "web_search",
///     "arguments": {
///       "query": "latest news on AI"
///     }
///   }
/// }
/// ```
public struct ToolDescriptor: Codable, Sendable {
    /// The tool's unique identifier name.
    public let tool_name: String
    
    /// Human-readable description of the tool's functionality.
    public let description: String
    
    /// Array of argument descriptors for this tool.
    public let arguments: [ArgumentDescriptor]
    
    /// Example usage of the tool.
    public let example: ToolExample?
    
    enum CodingKeys: String, CodingKey {
        case tool_name, description, arguments, example
    }
    
    /// Creates a new tool descriptor.
    ///
    /// - Parameters:
    ///   - toolName: The tool's unique identifier
    ///   - description: The tool's functionality description
    ///   - arguments: Array of argument descriptors
    ///   - example: Optional example usage
    public init(toolName: String, description: String, arguments: [ArgumentDescriptor] = [], example: ToolExample? = nil) {
        self.tool_name = toolName
        self.description = description
        self.arguments = arguments
        self.example = example
    }
}

/// Descriptor for a tool argument including its type information.
public struct ArgumentDescriptor: Codable, Sendable {
    /// The argument's unique identifier name.
    public let name: String
    
    /// Human-readable description of the argument's purpose.
    public let description: String
    
    /// Type information for this argument.
    public let type: ArgumentTypeDescriptor
    
    /// Creates a new argument descriptor.
    ///
    /// - Parameters:
    ///   - name: The argument's unique identifier
    ///   - description: The argument's purpose description
    ///   - type: Type information for the argument
    public init(name: String, description: String, type: ArgumentTypeDescriptor) {
        self.name = name
        self.description = description
        self.type = type
    }
}

/// Descriptor for argument type information.
public struct ArgumentTypeDescriptor: Codable, Sendable {
    /// The type name (e.g., "string", "number", "boolean").
    public let type: String
    
    /// Creates a new argument type descriptor.
    ///
    /// - Parameter type: The type name
    public init(type: String) {
        self.type = type
    }
}

/// Example usage of a tool.
public struct ToolExample: Codable, Sendable {
    /// The tool name in the example.
    public let tool_name: String
    
    /// Example arguments as a dictionary.
    public let arguments: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case tool_name, arguments
    }
    
    /// Creates a new tool example.
    ///
    /// - Parameters:
    ///   - toolName: The tool name
    ///   - arguments: Example arguments
    public init(toolName: String, arguments: [String: AnyCodable]) {
        self.tool_name = toolName
        self.arguments = arguments
    }
}

/// A type-erased wrapper for Codable values in examples.
public struct AnyCodable: Codable, Sendable {
    public let value: any Codable & Sendable
    
    public init<T: Codable & Sendable>(_ value: T) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}