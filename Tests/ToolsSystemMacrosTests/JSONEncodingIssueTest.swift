//
//  JSONEncodingIssueTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Test("Compare toolDescriptor vs JSON encoding")
func testJSONEncodingIssue() throws {
    // Get the toolDescriptor directly
    let descriptor = WebSearchTool.toolDescriptor
    
    print("=== Direct toolDescriptor ===")
    print("Arguments count: \(descriptor.arguments.count)")
    for arg in descriptor.arguments {
        print("Argument: \(arg)")
    }
    
    // Test encoding the descriptor directly
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    print("\n=== Direct encoding of toolDescriptor ===")
    let directData = try encoder.encode(descriptor)
    let directJson = String(data: directData, encoding: .utf8)!
    print(directJson)
    
    print("\n=== Using jsonDescription property ===")
    let jsonDescription = WebSearchTool.jsonDescription
    print(jsonDescription)
    
    // Compare if they're the same
    #expect(descriptor.arguments.count > 0, "toolDescriptor should have arguments")
    
    // Parse both JSONs to compare
    let directParsed = try JSONSerialization.jsonObject(with: directData) as! [String: Any]
    let jsonDescData = jsonDescription.data(using: .utf8)!
    let jsonDescParsed = try JSONSerialization.jsonObject(with: jsonDescData) as! [String: Any]
    
    let directArgs = directParsed["arguments"] as! [[String: Any]]
    let jsonDescArgs = jsonDescParsed["arguments"] as! [[String: Any]]
    
    print("\nDirect args count: \(directArgs.count)")
    print("jsonDescription args count: \(jsonDescArgs.count)")
}