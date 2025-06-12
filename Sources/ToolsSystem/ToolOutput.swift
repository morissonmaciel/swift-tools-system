//
//  ToolOutput.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Represents the output value returned by a tool execution.
///
/// `ToolOutput` provides a type-safe way to return different types of data from tool execution.
/// It supports common data types and can be easily serialized to/from JSON for API communication.
///
/// Example usage:
/// ```swift
/// func call(arguments: [Argument]) throws -> ToolOutput {
///     // Return different types based on your tool's logic
///     return .string("Hello, World!")          // Text result
///     return .double(3.14159)                  // Numeric result
///     return .int(42)                          // Integer result
///     return .bool(true)                       // Boolean result
///     return .array(["item1", 2, true])        // Mixed array
/// }
/// ```
public enum ToolOutput {
    /// A string text result.
    case string(String)
    
    /// A double-precision floating-point number result.
    case double(Double)
    
    /// An integer number result.
    case int(Int)
    
    /// A boolean true/false result.
    case bool(Bool)
    
    /// Binary data result.
    case data(Data)
    
    /// An array containing mixed codable values.
    ///
    /// The array can contain any combination of supported types (String, Double, Int, Bool).
    /// This is useful for returning lists or collections of data.
    case array([any Codable])
}

extension ToolOutput: Codable {
    enum CodingKeys: String, CodingKey {
        case type, value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "string":
            let value = try container.decode(String.self, forKey: .value)
            self = .string(value)
        case "double":
            let value = try container.decode(Double.self, forKey: .value)
            self = .double(value)
        case "int":
            let value = try container.decode(Int.self, forKey: .value)
            self = .int(value)
        case "bool":
            let value = try container.decode(Bool.self, forKey: .value)
            self = .bool(value)
        case "data":
            let value = try container.decode(Data.self, forKey: .value)
            self = .data(value)
        case "array":
            let arrayContainer = try container.nestedUnkeyedContainer(forKey: .value)
            var elements: [any Codable] = []
            var mutableContainer = arrayContainer
            
            while !mutableContainer.isAtEnd {
                if let stringValue = try? mutableContainer.decode(String.self) {
                    elements.append(stringValue)
                } else if let doubleValue = try? mutableContainer.decode(Double.self) {
                    elements.append(doubleValue)
                } else if let intValue = try? mutableContainer.decode(Int.self) {
                    elements.append(intValue)
                } else if let boolValue = try? mutableContainer.decode(Bool.self) {
                    elements.append(boolValue)
                } else {
                    // Skip unknown types
                    _ = try? mutableContainer.decode(String.self)
                }
            }
            self = .array(elements)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown ToolOutput type: \(type)"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .string(let value):
            try container.encode("string", forKey: .type)
            try container.encode(value, forKey: .value)
        case .double(let value):
            try container.encode("double", forKey: .type)
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode("int", forKey: .type)
            try container.encode(value, forKey: .value)
        case .bool(let value):
            try container.encode("bool", forKey: .type)
            try container.encode(value, forKey: .value)
        case .data(let value):
            try container.encode("data", forKey: .type)
            try container.encode(value, forKey: .value)
        case .array(let value):
            try container.encode("array", forKey: .type)
            var arrayContainer = container.nestedUnkeyedContainer(forKey: .value)
            
            for element in value {
                if let stringValue = element as? String {
                    try arrayContainer.encode(stringValue)
                } else if let doubleValue = element as? Double {
                    try arrayContainer.encode(doubleValue)
                } else if let intValue = element as? Int {
                    try arrayContainer.encode(intValue)
                } else if let boolValue = element as? Bool {
                    try arrayContainer.encode(boolValue)
                }
                // Skip types that can't be encoded
            }
        }
    }
}