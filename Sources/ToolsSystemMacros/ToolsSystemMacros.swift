//
//  ToolsSystemMacros.swift
//  ToolsSystemMacros
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation
@_exported import ToolsSystem

/// Marks a struct as a tool with the specified name and description.
///
/// The `@Tool` macro automatically generates the necessary boilerplate code to make a struct
/// conform to `ToolProtocol`. It creates a `definition` property with the provided metadata
/// and sets up the appropriate `Argument` typealias based on nested argument structures.
///
/// ## Basic Usage
///
/// For tools that don't require arguments:
/// ```swift
/// @Tool("hello_world", "Prints a greeting message")
/// struct HelloWorldTool {
///     func call(arguments: [Argument]) throws -> ToolOutput {
///         return .string("Hello, World!")
///     }
/// }
/// ```
///
/// ## Tools with Arguments
///
/// For tools that require structured input:
/// ```swift
/// @Tool("calculate_area", "Calculates the area of a rectangle")
/// struct AreaCalculator {
///     @ToolArgument("dimensions", "Rectangle dimensions")
///     struct RectangleInput {
///         let width: Double
///         let height: Double
///     }
///     
///     func call(arguments: [Argument]) throws -> ToolOutput {
///         let input = try arguments.decode(RectangleInput.self)
///         let area = input.width * input.height
///         return .double(area)
///     }
/// }
/// ```
///
/// ## Generated Code
///
/// The macro automatically generates:
/// - A `definition` property containing the tool's metadata
/// - An `Argument` typealias pointing to the appropriate argument type
/// - Conformance to `ToolProtocol`
///
/// - Parameters:
///   - name: A unique identifier for the tool (should be snake_case)
///   - description: A human-readable description of what the tool does
@attached(member, names: named(definition), named(Argument))
@attached(extension, conformances: ToolProtocol, names: named(definition), named(toolDescriptor))
public macro Tool(_ name: String, _ description: String) = #externalMacro(module: "ToolsSystemMacrosPlugin", type: "ToolMacro")

/// Marks a struct as a tool argument with the specified name and description.
///
/// The `@ToolArgument` macro generates the necessary code to make a struct conform to
/// `ToolArgumentProtocol`, allowing it to be used as input to tool execution methods.
/// This macro is typically used on nested structs within tool definitions.
///
/// ## Usage
///
/// ```swift
/// @Tool("file_processor", "Processes files with various options")
/// struct FileProcessor {
///     @ToolArgument("file_options", "File processing configuration")
///     struct FileOptions {
///         let filePath: String
///         let format: String
///         let compress: Bool
///     }
///     
///     func call(arguments: [Argument]) throws -> ToolOutput {
///         let options = try arguments.decode(FileOptions.self)
///         // Process file with the provided options
///         return .string("File processed successfully")
///     }
/// }
/// ```
///
/// ## Generated Code
///
/// The macro automatically generates:
/// - An `argumentDefinition` property containing the argument's metadata
/// - Conformance to `ToolArgumentProtocol`
///
/// - Parameters:
///   - name: A unique identifier for the argument (should be snake_case)
///   - description: A human-readable description of what the argument represents
@attached(member, names: named(argumentDefinition))
@attached(extension, conformances: ToolArgumentProtocol)
public macro ToolArgument(_ name: String, _ description: String) = #externalMacro(module: "ToolsSystemMacrosPlugin", type: "ToolArgumentMacro")

/// Marks a property as required within a tool argument.
///
/// The `@Required` macro provides metadata about argument properties that are mandatory
/// for tool execution. Currently serves as a documentation and validation marker.
///
/// ## Usage
///
/// ```swift
/// @ToolArgument("user_profile", "User profile information")
/// struct UserProfile {
///     @Required var email: String        // This field is required
///     var phoneNumber: String?           // This field is optional
///     @Required var username: String     // This field is required
/// }
/// ```
///
/// ## Future Enhancements
///
/// This macro is designed to support future validation features such as:
/// - Automatic validation of required fields at runtime
/// - Generation of JSON schema for API documentation
/// - IDE support for highlighting missing required fields
@attached(accessor)
public macro Required() = #externalMacro(module: "ToolsSystemMacrosPlugin", type: "RequiredMacro")