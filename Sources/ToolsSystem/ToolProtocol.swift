//
//  ToolProtocol.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Protocol that all tools must conform to in the tools system.
///
/// `ToolProtocol` defines the essential interface for executable tools. Tools must provide
/// metadata about themselves via a `definition` property and implement the core execution
/// logic in the `call` method.
///
/// The protocol uses an associated type `Argument` to ensure type safety between the tool
/// and its expected argument structure. This is typically handled automatically by the
/// `@Tool` macro.
///
/// Example implementation:
/// ```swift
/// @Tool("math_calculator", "Performs basic math operations")
/// struct MathCalculator {
///     @ToolArgument("operation", "The math operation to perform")
///     struct MathInput {
///         let operation: String
///         let numbers: [Double]
///     }
///     
///     func call(arguments: [Argument]) throws -> ToolOutput {
///         let input = try arguments.decode(MathInput.self)
///         // ... perform calculation
///         return .double(result)
///     }
/// }
/// ```
public protocol ToolProtocol: Codable {
    /// The argument type that this tool expects to receive.
    ///
    /// This associated type ensures compile-time type safety between the tool
    /// and its arguments. It must conform to `ToolArgumentProtocol`.
    associatedtype Argument: ToolArgumentProtocol
    
    /// Metadata describing this tool's name and purpose.
    ///
    /// The definition contains essential information about the tool that can be
    /// used for discovery, documentation, and user interfaces.
    var definition: ToolDefinition { get }
    
    /// Executes the tool with the provided arguments.
    ///
    /// This is the core method where the tool's functionality is implemented.
    /// The method should decode the arguments, perform the required operations,
    /// and return an appropriate `ToolOutput`.
    ///
    /// - Parameter arguments: An array of arguments conforming to the tool's `Argument` type
    /// - Returns: The result of the tool execution as a `ToolOutput`
    /// - Throws: Can throw errors for invalid arguments, execution failures, or other issues
    ///
    /// Example:
    /// ```swift
    /// func call(arguments: [Argument]) throws -> ToolOutput {
    ///     let input = try arguments.decode(MyArgumentType.self)
    ///     let result = performOperation(input)
    ///     return .string(result)
    /// }
    /// ```
    func call(arguments: [Argument]) throws -> ToolOutput
}

/// Default implementation providing JSON description functionality for all tools.
public extension ToolProtocol {
    /// Comprehensive JSON descriptor for this tool.
    ///
    /// Generates a structured JSON representation containing the tool's metadata,
    /// argument specifications, and return type information. This is useful for
    /// API documentation, tool discovery, and integration with external systems.
    ///
    /// Example usage:
    /// ```swift
    /// let calculator = SquareRootCalculator()
    /// let jsonData = try JSONEncoder().encode(calculator.toolDescriptor)
    /// let jsonString = String(data: jsonData, encoding: .utf8)
    /// print(jsonString)
    /// ```
    ///
    /// The generated JSON includes:
    /// - Tool name and description
    /// - Detailed argument specifications with property types
    /// - Return type information
    /// - Validation requirements
    var toolDescriptor: ToolDescriptor {
        return ToolDescriptor(
            name: definition.name,
            description: definition.description,
            arguments: [], // Will be populated by macro-generated implementations
            returnType: ReturnTypeDescriptor()
        )
    }
    
    /// JSON string representation of the tool descriptor.
    ///
    /// Provides a convenient way to get the tool's JSON description as a string.
    /// This property encodes the `toolDescriptor` to JSON and returns it as a string,
    /// or returns an error description if encoding fails.
    ///
    /// Example:
    /// ```swift
    /// let calculator = SquareRootCalculator()
    /// print(calculator.jsonDescription)
    /// // Outputs: {"name":"calculate_square_root","description":"..."}
    /// ```
    var jsonDescription: String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(toolDescriptor)
            return String(data: data, encoding: .utf8) ?? "Failed to encode JSON"
        } catch {
            return "Error generating JSON description: \(error.localizedDescription)"
        }
    }
}
