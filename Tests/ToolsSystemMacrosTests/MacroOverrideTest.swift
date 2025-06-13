//
//  MacroOverrideTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

// Simple tool without arguments to test base case
@Tool("simple_tool", "A simple tool")
struct SimpleTool {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .string("simple")
    }
}

@Test("Test which toolDescriptor implementation is being used")
func testToolDescriptorImplementation() throws {
    // Test simple tool (should use default implementation)
    let simpleDescriptor = SimpleTool.toolDescriptor
    print("SimpleTool arguments: \(simpleDescriptor.arguments)")
    
    // Test WebSearchTool (should use macro-generated implementation)
    let webDescriptor = WebSearchTool.toolDescriptor
    print("WebSearchTool arguments: \(webDescriptor.arguments)")
    print("WebSearchTool arguments count: \(webDescriptor.arguments.count)")
    
    // Check if the macro is generating the override correctly
    #expect(simpleDescriptor.arguments.isEmpty, "Simple tool should have no arguments")
    #expect(webDescriptor.arguments.count > 0, "WebSearchTool should have arguments from macro")
}