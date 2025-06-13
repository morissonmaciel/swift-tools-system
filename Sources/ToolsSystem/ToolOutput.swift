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
/// func call(arguments: [Argument]) async throws -> ToolOutput {
///     // Return different types based on your tool's logic
///     return .string("Hello, World!")          // Text result
///     return .double(3.14159)                  // Numeric result
///     return .int(42)                          // Integer result
///     return .bool(true)                       // Boolean result
///     return .array(["item1", 2, true])        // Mixed array
///     return .dictionary(["name": "John", "age": 30]) // Structured data
///     return .dictionaryArray([["id": 1, "name": "John"], ["id": 2, "name": "Jane"]]) // Array of objects
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
    
    /// A dictionary containing structured key-value data.
    ///
    /// The dictionary values can be any codable type. When accessed via `description`,
    /// this provides a pretty-printed JSON representation for easy reading.
    /// This is useful for returning structured objects and complex data.
    case dictionary([String: any Codable])
    
    /// An array of dictionaries containing structured key-value data.
    ///
    /// Each dictionary's values can be any codable type. When accessed via `description`,
    /// this provides a pretty-printed JSON array representation for easy reading.
    /// This is useful for returning lists of structured objects and collections of data.
    case dictionaryArray([[String: any Codable]])
}

// Helper enum for encoding mixed-type values in dictionaries
private enum AnyCodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(AnyCodableValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Cannot decode AnyCodableValue"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        }
    }
}

// Helper struct for dynamic dictionary keys during Codable operations
private struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
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
        case "dictionary":
            let dictContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: .value)
            var dictionary: [String: any Codable] = [:]
            
            for key in dictContainer.allKeys {
                // Try decoding in a specific order: bool first (since it's a subset of int), then int, then double, then string
                if let boolValue = try? dictContainer.decode(Bool.self, forKey: key) {
                    dictionary[key.stringValue] = boolValue
                } else if let intValue = try? dictContainer.decode(Int.self, forKey: key) {
                    dictionary[key.stringValue] = intValue
                } else if let doubleValue = try? dictContainer.decode(Double.self, forKey: key) {
                    dictionary[key.stringValue] = doubleValue
                } else if let stringValue = try? dictContainer.decode(String.self, forKey: key) {
                    dictionary[key.stringValue] = stringValue
                }
            }
            self = .dictionary(dictionary)
        case "dictionaryArray":
            let arrayContainer = try container.nestedUnkeyedContainer(forKey: .value)
            var dictionaries: [[String: any Codable]] = []
            var mutableContainer = arrayContainer
            
            while !mutableContainer.isAtEnd {
                let dictContainer = try mutableContainer.nestedContainer(keyedBy: DynamicKey.self)
                var dictionary: [String: any Codable] = [:]
                
                for key in dictContainer.allKeys {
                    // Try decoding in a specific order: bool first, then int, then double, then string
                    if let boolValue = try? dictContainer.decode(Bool.self, forKey: key) {
                        dictionary[key.stringValue] = boolValue
                    } else if let intValue = try? dictContainer.decode(Int.self, forKey: key) {
                        dictionary[key.stringValue] = intValue
                    } else if let doubleValue = try? dictContainer.decode(Double.self, forKey: key) {
                        dictionary[key.stringValue] = doubleValue
                    } else if let stringValue = try? dictContainer.decode(String.self, forKey: key) {
                        dictionary[key.stringValue] = stringValue
                    }
                }
                dictionaries.append(dictionary)
            }
            self = .dictionaryArray(dictionaries)
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
        case .dictionary(let value):
            try container.encode("dictionary", forKey: .type)
            var dictContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: .value)
            
            for (key, element) in value {
                let codingKey = DynamicKey(stringValue: key)!
                if let stringValue = element as? String {
                    try dictContainer.encode(stringValue, forKey: codingKey)
                } else if let doubleValue = element as? Double {
                    try dictContainer.encode(doubleValue, forKey: codingKey)
                } else if let intValue = element as? Int {
                    try dictContainer.encode(intValue, forKey: codingKey)
                } else if let boolValue = element as? Bool {
                    try dictContainer.encode(boolValue, forKey: codingKey)
                }
                // Skip types that can't be encoded
            }
        case .dictionaryArray(let value):
            try container.encode("dictionaryArray", forKey: .type)
            var arrayContainer = container.nestedUnkeyedContainer(forKey: .value)
            
            for dictionary in value {
                var dictContainer = arrayContainer.nestedContainer(keyedBy: DynamicKey.self)
                
                for (key, element) in dictionary {
                    let codingKey = DynamicKey(stringValue: key)!
                    if let stringValue = element as? String {
                        try dictContainer.encode(stringValue, forKey: codingKey)
                    } else if let doubleValue = element as? Double {
                        try dictContainer.encode(doubleValue, forKey: codingKey)
                    } else if let intValue = element as? Int {
                        try dictContainer.encode(intValue, forKey: codingKey)
                    } else if let boolValue = element as? Bool {
                        try dictContainer.encode(boolValue, forKey: codingKey)
                    }
                    // Skip types that can't be encoded
                }
            }
        }
    }
}

extension ToolOutput: CustomStringConvertible {
    /// A human-readable description of the tool output.
    ///
    /// For dictionary outputs, this returns a pretty-printed JSON string.
    /// For other output types, this returns their string representation.
    public var description: String {
        switch self {
        case .string(let value):
            return value
        case .double(let value):
            return String(value)
        case .int(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        case .data(let value):
            return "Data(\(value.count) bytes)"
        case .array(let value):
            return "[\(value.map { String(describing: $0) }.joined(separator: ", "))]"
        case .dictionary(let value):
            return prettyJSONString(from: value)
        case .dictionaryArray(let value):
            return prettyJSONArrayString(from: value)
        }
    }
    
    /// Converts a dictionary to a pretty-printed JSON string.
    private func prettyJSONString(from dictionary: [String: any Codable]) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            
            // Convert to a simple encodable dictionary
            let encodableDict = dictionary.compactMapValues { value -> AnyCodableValue? in
                if let stringValue = value as? String {
                    return .string(stringValue)
                } else if let intValue = value as? Int {
                    return .int(intValue)
                } else if let doubleValue = value as? Double {
                    return .double(doubleValue)
                } else if let boolValue = value as? Bool {
                    return .bool(boolValue)
                } else {
                    return .string(String(describing: value))
                }
            }
            
            let jsonData = try encoder.encode(encodableDict)
            return String(data: jsonData, encoding: .utf8) ?? "Failed to format JSON"
        } catch {
            return "Error formatting JSON: \(error.localizedDescription)"
        }
    }
    
    /// Converts an array of dictionaries to a pretty-printed JSON array string.
    private func prettyJSONArrayString(from dictionaries: [[String: any Codable]]) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            
            // Convert to an array of simple encodable dictionaries
            let encodableDictArray = dictionaries.map { dictionary in
                dictionary.compactMapValues { value -> AnyCodableValue? in
                    if let stringValue = value as? String {
                        return .string(stringValue)
                    } else if let intValue = value as? Int {
                        return .int(intValue)
                    } else if let doubleValue = value as? Double {
                        return .double(doubleValue)
                    } else if let boolValue = value as? Bool {
                        return .bool(boolValue)
                    } else {
                        return .string(String(describing: value))
                    }
                }
            }
            
            let jsonData = try encoder.encode(encodableDictArray)
            return String(data: jsonData, encoding: .utf8) ?? "Failed to format JSON array"
        } catch {
            return "Error formatting JSON array: \(error.localizedDescription)"
        }
    }
}