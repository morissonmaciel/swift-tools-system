//
//  AnyTool.swift
//  ToolsSystem
//
//  Created by Morisson Marcel on 13/06/25.
//

import Foundation

/// A type-erased wrapper for any tool that conforms to `ToolProtocol`.
///
/// `AnyTool` provides a way to handle existential types (`any ToolProtocol`) in contexts
/// where `Codable` conformance is required, such as when storing tools in arrays or
/// as properties of `Codable` structs.
///
/// Example usage:
/// ```swift
/// struct ThreadModelResponse: Codable {
///     let id: String
///     let tool: AnyTool?  // Instead of: var tool: (any ToolProtocol)?
/// }
///
/// // Usage
/// let calcTool = CalcSquareRoot()
/// let anyTool = AnyTool(calcTool)
/// let response = ThreadModelResponse(id: "123", tool: anyTool)
///
/// // Execute the wrapped tool
/// let result = try await anyTool.call(arguments: [inputArgument])
/// ```
public struct AnyTool: Sendable {
    public typealias Argument = EmptyArgument
    
    private let _definition: ToolDefinition
    private let _call: @Sendable ([any ToolArgumentProtocol]) async throws -> ToolOutput
    private let _wrappedTool: (any ToolProtocol)?
    
    /// Creates a type-erased wrapper around any tool.
    /// - Parameter tool: The tool to wrap
    public init<T: ToolProtocol>(_ tool: T) {
        self._definition = T.definition
        self._wrappedTool = tool
        self._call = { arguments in
            // Cast the arguments to the expected type for the wrapped tool
            let typedArgs = arguments.compactMap { $0 as? T.Argument }
            return try await tool.call(arguments: typedArgs)
        }
    }
    
    /// The tool's definition and metadata.
    public var definition: ToolDefinition {
        return _definition
    }
    
    /// Access to the wrapped tool instance (if available).
    public var wrappedTool: (any ToolProtocol)? {
        return _wrappedTool
    }
    
    /// Executes the wrapped tool with the provided arguments.
    /// - Parameter arguments: The arguments to pass to the tool
    /// - Returns: The tool's output
    /// - Throws: `ToolError` or any error thrown by the wrapped tool
    public func call(arguments: [any ToolArgumentProtocol]) async throws -> ToolOutput {
        return try await _call(arguments)
    }
}

extension AnyTool: Codable {
    enum CodingKeys: String, CodingKey {
        case definition
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._definition = try container.decode(ToolDefinition.self, forKey: .definition)
        self._wrappedTool = nil
        
        // Create a placeholder call function for decoded instances
        // Note: Decoded AnyTool instances cannot execute since we can't reconstruct the original tool
        self._call = { _ in
            throw ToolError.executionFailed("Cannot execute decoded AnyTool - original tool implementation lost during encoding")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_definition, forKey: .definition)
    }
}

extension AnyTool: CustomStringConvertible {
    /// A human-readable description of the wrapped tool.
    public var description: String {
        return "AnyTool(\(_definition.name): \(_definition.description))"
    }
}