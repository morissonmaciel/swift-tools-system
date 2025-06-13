//
//  ToolArgumentProtocol.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Protocol that all tool arguments must conform to.
///
/// `ToolArgumentProtocol` ensures that tool arguments are both codable (for serialization)
/// and can be used within the tools system. Types conforming to this protocol can be
/// passed as arguments to tool execution methods.
///
/// Example:
/// ```swift
/// @ToolArgument("user_input", "Input from the user")
/// struct UserInput: ToolArgumentProtocol {
///     let message: String
///     let priority: Int
/// }
/// ```
public protocol ToolArgumentProtocol: Codable, Sendable {
    
}

/// Default empty argument for tools that don't require any input arguments.
///
/// `EmptyArgument` is automatically used by the `@Tool` macro for tools that don't
/// define their own argument types. It contains no data and serves as a placeholder.
///
/// Example:
/// ```swift
/// @Tool("simple_tool", "A tool with no arguments")
/// struct SimpleTool {
///     func call(arguments: [Argument]) throws -> ToolOutput {
///         // arguments will be [EmptyArgument]
///         return .string("No arguments needed!")
///     }
/// }
/// ```
public struct EmptyArgument: ToolArgumentProtocol, Sendable {
    /// Creates a new empty argument instance.
    public init() {}
}

/// Extension providing argument decoding functionality for tool argument arrays.
public extension Array where Element: ToolArgumentProtocol {
    /// Decodes the first argument in the array to the specified type.
    ///
    /// This method provides a convenient way to extract strongly-typed arguments
    /// from the argument array passed to tool execution methods.
    ///
    /// - Parameter type: The target argument type to decode to
    /// - Returns: The decoded argument of the specified type
    /// - Throws: `ToolError.noArguments` if the array is empty
    /// - Throws: `ToolError.invalidArgumentType` if the first argument cannot be cast to the target type
    ///
    /// Example:
    /// ```swift
    /// func call(arguments: [Argument]) throws -> ToolOutput {
    ///     let input = try arguments.decode(UserInput.self)
    ///     return .string("Hello, \(input.message)!")
    /// }
    /// ```
    func decode<T: ToolArgumentProtocol>(_ type: T.Type) throws -> T {
        guard let first = self.first else {
            throw ToolError.noArguments
        }
        guard let decoded = first as? T else {
            throw ToolError.invalidArgumentType
        }
        return decoded
    }
}