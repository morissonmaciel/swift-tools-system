//
//  DescriptorEncodingTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystem

@Test("Test ArgumentDescriptor and new structure JSON encoding")
func testDescriptorEncoding() throws {
    // Create an ArgumentDescriptor with new structure
    let argDesc = ArgumentDescriptor(
        name: "query",
        description: "Query string to search web for",
        type: ArgumentTypeDescriptor(type: "string")
    )
    
    // Test encoding the ArgumentDescriptor
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    let argData = try encoder.encode(argDesc)
    let argJson = String(data: argData, encoding: .utf8)!
    print("ArgumentDescriptor JSON:")
    print(argJson)
    
    // Test encoding ToolDescriptor with new structure
    let example = ToolExample(
        toolName: "web_search",
        arguments: ["query": AnyCodable("latest news on AI")]
    )
    
    let toolDesc = ToolDescriptor(
        toolName: "web_search",
        description: "Search web for results",
        arguments: [argDesc],
        example: example
    )
    
    let toolData = try encoder.encode(toolDesc)
    let toolJson = String(data: toolData, encoding: .utf8)!
    print("\nToolDescriptor JSON:")
    print(toolJson)
    
    // Verify new structure
    let parsedJSON = try JSONSerialization.jsonObject(with: toolData) as! [String: Any]
    #expect(parsedJSON["tool_name"] as? String == "web_search")
    #expect(parsedJSON["example"] != nil)
}