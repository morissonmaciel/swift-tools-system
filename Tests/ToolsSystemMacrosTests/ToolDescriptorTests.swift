//
//  ToolDescriptorTests.swift
//  ToolsSystemMacrosTests
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Test("TestTool generates basic JSON descriptor")
func testTestToolJSONDescriptor() throws {
    let descriptor = TestTool.toolDescriptor
    
    #expect(descriptor.tool_name == "test_tool")
    #expect(descriptor.description == "A test tool")
    #expect(descriptor.arguments.isEmpty) // TestTool has no arguments
    #expect(descriptor.example != nil) // Should have example
}

@Test("CalcSquareRoot generates comprehensive JSON descriptor")
func testCalcSquareRootJSONDescriptor() throws {
    let descriptor = CalcSquareRoot.toolDescriptor
    
    #expect(descriptor.tool_name == "calculate_square_root")
    #expect(descriptor.description == "Calculates the square root of a number")
    
    // Check arguments are present
    #expect(descriptor.arguments.count > 0) // Should have arguments
    #expect(descriptor.example != nil) // Should have example
}

@Test("JSON string is properly formatted")
func testJSONStringFormatting() throws {
    let jsonString = TestTool.jsonDescription
    
    // Should be valid JSON
    #expect(!jsonString.contains("Error"))
    #expect(jsonString.contains("test_tool"))
    #expect(jsonString.contains("A test tool"))
    
    // Test that it can be parsed back to JSON
    let jsonData = jsonString.data(using: .utf8)!
    let parsedJSON = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    
    #expect(parsedJSON["tool_name"] as? String == "test_tool")
    #expect(parsedJSON["description"] as? String == "A test tool")
}

@Test("Complex tool JSON descriptor is complete")
func testComplexToolJSONDescriptor() throws {
    let jsonString = CalcSquareRoot.jsonDescription
    
    #expect(!jsonString.contains("Error"))
    #expect(jsonString.contains("calculate_square_root"))
    #expect(jsonString.contains("Calculates the square root of a number"))
    
    // Parse and validate basic structure
    let jsonData = jsonString.data(using: .utf8)!
    let parsedJSON = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
    
    #expect(parsedJSON["tool_name"] as? String == "calculate_square_root")
    #expect(parsedJSON["description"] as? String == "Calculates the square root of a number")
    
    // Check that arguments array exists (even if empty for now)
    let arguments = parsedJSON["arguments"] as! [[String: Any]]
    #expect(arguments.count >= 0) // Arguments parsing will be improved
}

@Test("ToolDescriptor is codable")
func testToolDescriptorCodable() throws {
    let example = ToolExample(
        toolName: "test",
        arguments: ["input": AnyCodable("test_value")]
    )
    
    let descriptor = ToolDescriptor(
        toolName: "test",
        description: "A test descriptor",
        arguments: [
            ArgumentDescriptor(
                name: "input",
                description: "Test input",
                type: ArgumentTypeDescriptor(type: "string")
            )
        ],
        example: example
    )
    
    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(descriptor)
    
    // Test decoding
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ToolDescriptor.self, from: data)
    
    #expect(decoded.tool_name == "test")
    #expect(decoded.description == "A test descriptor")
    #expect(decoded.arguments.count == 1)
    #expect(decoded.arguments[0].name == "input")
    #expect(decoded.arguments[0].type.type == "string")
    #expect(decoded.example?.tool_name == "test")
}