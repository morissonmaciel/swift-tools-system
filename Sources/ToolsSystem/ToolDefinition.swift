//
//  ToolDefinition.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Defines metadata for a tool including its name, description, and usage instructions.
///
/// `ToolDefinition` contains the essential information needed to identify and describe
/// a tool's purpose and usage. This is typically generated automatically by the `@Tool` macro
/// but can also be created manually for custom implementations.
///
/// Example:
/// ```swift
/// let definition = ToolDefinition(
///     name: "calculate_sum",
///     description: "Calculates the sum of two numbers",
///     instructions: "Provide two numeric values as input parameters"
/// )
/// ```
public struct ToolDefinition: Codable, Sendable {
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
    
    /// Detailed usage instructions for the tool.
    ///
    /// This string contains specific instructions on how to use the tool effectively,
    /// including parameter requirements, expected inputs, and any special considerations.
    /// If no instructions are provided, this defaults to an empty string.
    public let instructions: String
    
    /// Creates a new tool definition with the specified name, description, and instructions.
    ///
    /// - Parameters:
    ///   - name: The unique identifier name for the tool
    ///   - description: A human-readable description of the tool's functionality
    ///   - instructions: Detailed usage instructions for the tool (defaults to empty string)
    public init(name: String, description: String, instructions: String = "") {
        self.name = name
        self.description = description
        self.instructions = instructions
    }
}