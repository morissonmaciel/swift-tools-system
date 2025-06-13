//
//  ImprovedJSONTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Test("WebSearchTool generates improved JSON structure")
func testImprovedJSONStructure() throws {
    let jsonString = WebSearchTool.jsonDescription
    
    print("=== IMPROVED JSON OUTPUT ===")
    print(jsonString)
    
    // Parse and validate the new structure
    let jsonData = jsonString.data(using: .utf8)!
    let parsedJSON = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    
    // Validate improved structure
    #expect(parsedJSON["tool_name"] as? String == "web_search", "Should use tool_name field")
    #expect(parsedJSON["description"] as? String == "Search web for results based on query string", "Should have description")
    
    let arguments = parsedJSON["arguments"] as! [[String: Any]]
    #expect(arguments.count == 1, "Should have 1 argument")
    
    let firstArg = arguments[0]
    #expect(firstArg["name"] as? String == "query", "Should have query argument")
    #expect(firstArg["description"] as? String == "Query string to search web for", "Should have argument description")
    
    let type = firstArg["type"] as! [String: Any]
    #expect(type["type"] as? String == "string", "Should have string type")
    
    // Check that returnType is no longer present (as per your suggestion)
    #expect(parsedJSON["returnType"] == nil, "returnType should be removed")
    
    // Check example section exists
    #expect(parsedJSON["example"] != nil, "Should have example section")
    
    let example = parsedJSON["example"] as! [String: Any]
    #expect(example["tool_name"] as? String == "web_search", "Example should have tool_name")
    #expect(example["arguments"] != nil, "Example should have arguments")
}