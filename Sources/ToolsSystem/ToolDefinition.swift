//
//  ToolDefinition.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Defines metadata for a tool including its name and description.
///
/// `ToolDefinition` contains the essential information needed to identify and describe
/// a tool's purpose. This is typically generated automatically by the `@Tool` macro
/// but can also be created manually for custom implementations.
///
/// Example:
/// ```swift
/// let definition = ToolDefinition(
///     name: "calculate_sum", 
///     description: "Calculates the sum of two numbers"
/// )
/// ```
public struct ToolDefinition: Codable {
    /// The unique identifier name for the tool.
    ///
    /// This should be a descriptive, snake_case string that uniquely identifies
    /// the tool within your application. It's used for tool selection and invocation.
    public let name: String
    
    /// A human-readable description of what the tool does.
    ///
    /// This description should clearly explain the tool's purpose and functionality
    /// to help users understand when and how to use it.
    public let description: String
    
    /// Creates a new tool definition with the specified name and description.
    ///
    /// - Parameters:
    ///   - name: The unique identifier name for the tool
    ///   - description: A human-readable description of the tool's functionality
    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}