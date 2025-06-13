//
//  ToolError.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation

/// Errors that can occur during tool execution and argument processing.
///
/// `ToolError` provides standardized error cases for common issues that arise
/// when working with tools, particularly during argument validation and decoding.
///
/// Example error handling:
/// ```swift
/// func call(arguments: [Argument]) throws -> ToolOutput {
///     do {
///         let input = try arguments.decode(MyInput.self)
///         return .string("Success!")
///     } catch ToolError.noArguments {
///         throw ToolError.noArguments // Re-throw or handle appropriately
///     } catch ToolError.invalidArgumentType {
///         return .string("Invalid argument provided")
///     }
/// }
/// ```
public enum ToolError: Error, Sendable, Equatable {
    /// Thrown when a tool expects arguments but none are provided.
    ///
    /// This error occurs when `arguments.decode()` is called on an empty array,
    /// indicating that the tool requires input arguments but didn't receive any.
    case noArguments
    
    /// Thrown when the provided argument cannot be cast to the expected type.
    ///
    /// This error occurs when `arguments.decode()` is called with a type that
    /// doesn't match the actual argument type provided, indicating a type mismatch
    /// between what the tool expects and what was provided.
    case invalidArgumentType
    
    /// Thrown when a tool execution fails with a specific error message.
    ///
    /// This error is used to indicate that a tool's execution failed for a specific
    /// reason, such as when trying to execute a decoded AnyTool instance.
    case executionFailed(String)
}