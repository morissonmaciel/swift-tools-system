//
//  SimpleGenericResponse.swift
//  ToolsSystem
//
//  Created by Claude Code
//

import Foundation

/// A simple, reliable response structure for your use case
public struct APIToolResponse: Codable {
    public let message: String
    public let tool: APIToolCall?
    
    public init(message: String, tool: APIToolCall? = nil) {
        self.message = message
        self.tool = tool
    }
}

/// Represents a tool call from your API with arguments
public struct APIToolCall: Codable {
    public let tool_name: String
    public let arguments: [String: CodableValue]
    
    public init(tool_name: String, arguments: [String: CodableValue]) {
        self.tool_name = tool_name
        self.arguments = arguments
    }
    
    /// Get an argument value as a specific type
    public func get<T>(_ key: String, as type: T.Type) -> T? {
        switch type {
        case is String.Type:
            return arguments[key]?.stringValue as? T
        case is Int.Type:
            return arguments[key]?.intValue as? T
        case is Double.Type:
            return arguments[key]?.doubleValue as? T
        case is Bool.Type:
            return arguments[key]?.boolValue as? T
        case is Float.Type:
            if let doubleValue = arguments[key]?.doubleValue {
                return Float(doubleValue) as? T
            }
            return nil
        default:
            return nil
        }
    }
    
    /// Get a string argument (convenience method)
    public func getString(_ key: String) -> String? {
        return get(key, as: String.self)
    }
    
    /// Get an integer argument (convenience method)
    public func getInt(_ key: String) -> Int? {
        return get(key, as: Int.self)
    }
    
    /// Get a boolean argument (convenience method)
    public func getBool(_ key: String) -> Bool? {
        return get(key, as: Bool.self)
    }
    
    /// Get a double argument (convenience method)
    public func getDouble(_ key: String) -> Double? {
        return get(key, as: Double.self)
    }
    
    /// Get a float argument (convenience method)
    public func getFloat(_ key: String) -> Float? {
        return get(key, as: Float.self)
    }
    
    /// Get an argument with a default value
    public func get<T>(_ key: String, as type: T.Type, default defaultValue: T) -> T {
        return get(key, as: type) ?? defaultValue
    }
    
    /// Check if an argument exists
    public func hasArgument(_ key: String) -> Bool {
        return arguments[key] != nil
    }
    
    /// Get all argument keys
    public var argumentKeys: [String] {
        return Array(arguments.keys)
    }
}

/// A simple value type that can hold different JSON types
public enum CodableValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, 
                                    debugDescription: "Unsupported value type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
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
        case .null:
            try container.encodeNil()
        }
    }
    
    // Convenience getters
    public var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }
    
    public var intValue: Int? {
        if case .int(let value) = self { return value }
        return nil
    }
    
    public var doubleValue: Double? {
        if case .double(let value) = self { return value }
        return nil
    }
    
    public var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }
}

// MARK: - Simple Tool Registry

/// A tool registry for mapping tool names to handlers
public class ToolRegistry {
    public static let shared = ToolRegistry()
    
    private var toolHandlers: [String: ToolHandler] = [:]
    
    private init() {}
    
    /// Register a tool handler for a specific tool name
    public func register(toolName: String, handler: @escaping ToolHandler) {
        toolHandlers[toolName] = handler
    }
    
    /// Handle a tool call from an API response
    public func handleTool(_ toolCall: APIToolCall) async throws -> String {
        guard let handler = toolHandlers[toolCall.tool_name] else {
            throw ToolRegistryError.unknownTool(toolCall.tool_name)
        }
        
        return try await handler(toolCall)
    }
    
    /// Check if a tool is registered
    public func isRegistered(_ toolName: String) -> Bool {
        return toolHandlers[toolName] != nil
    }
    
    /// Get all registered tool names
    public var registeredTools: [String] {
        return Array(toolHandlers.keys)
    }
}

public typealias ToolHandler = (APIToolCall) async throws -> String

public enum ToolRegistryError: Error, LocalizedError {
    case unknownTool(String)
    case executionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .unknownTool(let name):
            return "Unknown tool: \(name). Available tools: \(ToolRegistry.shared.registeredTools.joined(separator: ", "))"
        case .executionFailed(let reason):
            return "Tool execution failed: \(reason)"
        }
    }
}