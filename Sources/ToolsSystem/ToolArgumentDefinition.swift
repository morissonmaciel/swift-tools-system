//
//  ToolArgumentDefinition.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Defines metadata for a tool argument including its name, description, and required example.
///
/// `ToolArgumentDefinition` contains information about a specific argument that a tool accepts.
/// This is typically generated automatically by the `@ToolArgument` macro but can also be
/// created manually for custom argument implementations.
///
/// Example:
/// ```swift
/// let argDef = ToolArgumentDefinition(
///     name: "input_number", 
///     description: "The number to process",
///     example: "42"
/// )
/// ```
public struct ToolArgumentDefinition: Codable {
    /// The unique identifier name for the argument.
    ///
    /// This should be a descriptive, snake_case string that identifies
    /// the argument within the tool's argument list.
    public let name: String
    
    /// A human-readable description of what the argument represents.
    ///
    /// This description should clearly explain the argument's purpose and expected format
    /// to help users understand how to provide the correct input.
    public let description: String
    
    /// A required example value that demonstrates the expected format or content.
    ///
    /// This example will be included in the JSON descriptor to help users understand
    /// how to structure their input for this argument.
    public let example: String
    
    /// Creates a new tool argument definition with the specified name, description, and required example.
    ///
    /// - Parameters:
    ///   - name: The unique identifier name for the argument
    ///   - description: A human-readable description of the argument's purpose
    ///   - example: A required example value demonstrating the expected format
    public init(name: String, description: String, example: String) {
        self.name = name
        self.description = description
        self.example = example
    }
}
