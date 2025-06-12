//
//  ToolDefinitionTests.swift
//  ToolsSystemMacrosTests
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation
import Testing
import ToolsSystem

@Test("ToolDefinition can be created independently")
func testToolDefinitionCreation() {
    let definition = ToolDefinition(name: "custom_tool", description: "A custom tool for testing")
    
    #expect(definition.name == "custom_tool")
    #expect(definition.description == "A custom tool for testing")
}

@Test("ToolDefinition is Codable")
func testToolDefinitionCodable() throws {
    let original = ToolDefinition(name: "encode_test", description: "Test encoding")
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(original)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ToolDefinition.self, from: data)
    
    #expect(decoded.name == original.name)
    #expect(decoded.description == original.description)
}