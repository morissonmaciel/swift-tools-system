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
///   "name": "calculate_square_root",
///   "description": "Calculates the square root of a number",
///   "arguments": [
///     {
///       "name": "input",
///       "description": "The number to calculate the square root of",
///       "properties": {
///         "number": {
///           "type": "Double",
///           "required": true
///         }
///       }
///     }
///   ],
///   "returnType": {
///     "type": "ToolOutput",
///     "description": "The calculated result"
///   }
/// }
/// ```
public struct ToolDescriptor: Codable {
    /// The tool's unique identifier name.
    public let name: String
    
    /// Human-readable description of the tool's functionality.
    public let description: String
    
    /// Array of argument descriptors for this tool.
    public let arguments: [ArgumentDescriptor]
    
    /// Description of the tool's return type.
    public let returnType: ReturnTypeDescriptor
    
    /// Creates a new tool descriptor.
    ///
    /// - Parameters:
    ///   - name: The tool's unique identifier
    ///   - description: The tool's functionality description
    ///   - arguments: Array of argument descriptors
    ///   - returnType: Description of the return type
    public init(name: String, description: String, arguments: [ArgumentDescriptor] = [], returnType: ReturnTypeDescriptor = ReturnTypeDescriptor()) {
        self.name = name
        self.description = description
        self.arguments = arguments
        self.returnType = returnType
    }
}

/// Descriptor for a tool argument including its properties and validation rules.
public struct ArgumentDescriptor: Codable {
    /// The argument's unique identifier name.
    public let name: String
    
    /// Human-readable description of the argument's purpose.
    public let description: String
    
    /// Dictionary of properties within this argument.
    public let properties: [String: PropertyDescriptor]
    
    /// Creates a new argument descriptor.
    ///
    /// - Parameters:
    ///   - name: The argument's unique identifier
    ///   - description: The argument's purpose description
    ///   - properties: Dictionary of properties within the argument
    public init(name: String, description: String, properties: [String: PropertyDescriptor] = [:]) {
        self.name = name
        self.description = description
        self.properties = properties
    }
}

/// Descriptor for a property within an argument.
public struct PropertyDescriptor: Codable {
    /// The Swift type name of the property.
    public let type: String
    
    /// Whether this property is required.
    public let required: Bool
    
    /// Optional description of the property.
    public let description: String?
    
    /// Creates a new property descriptor.
    ///
    /// - Parameters:
    ///   - type: The Swift type name
    ///   - required: Whether the property is required
    ///   - description: Optional description of the property
    public init(type: String, required: Bool = false, description: String? = nil) {
        self.type = type
        self.required = required
        self.description = description
    }
}

/// Descriptor for the tool's return type.
public struct ReturnTypeDescriptor: Codable {
    /// The return type name.
    public let type: String
    
    /// Description of what the tool returns.
    public let description: String
    
    /// Creates a new return type descriptor.
    ///
    /// - Parameters:
    ///   - type: The return type name
    ///   - description: Description of what is returned
    public init(type: String = "ToolOutput", description: String = "The result of the tool execution") {
        self.type = type
        self.description = description
    }
}