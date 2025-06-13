//
//  AnyToolTests.swift
//  ToolsSystemMacrosTests
//
//  Created by Morisson Marcel on 13/06/25.
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Test("AnyTool wraps and executes tools correctly")
func testAnyToolExecution() async throws {
    let calcTool = CalcSquareRoot()
    let anyTool = AnyTool(calcTool)
    
    // Test that definition is preserved
    #expect(anyTool.definition.name == CalcSquareRoot.definition.name)
    #expect(anyTool.definition.description == CalcSquareRoot.definition.description)
    
    // Test execution
    let inputArgument = CalcSquareRoot.InputArgument(number: 16.0)
    let result = try await anyTool.call(arguments: [inputArgument])
    
    if case .double(let value) = result {
        #expect(value == 4.0)
    } else {
        #expect(Bool(false), "Expected double result")
    }
}

@Test("AnyTool can be encoded and decoded")
func testAnyToolCodable() throws {
    let calcTool = CalcSquareRoot()
    let anyTool = AnyTool(calcTool)
    
    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(anyTool)
    
    // Test decoding
    let decoder = JSONDecoder()
    let decodedAnyTool = try decoder.decode(AnyTool.self, from: data)
    
    // Test that definition is preserved
    #expect(decodedAnyTool.definition.name == anyTool.definition.name)
    #expect(decodedAnyTool.definition.description == anyTool.definition.description)
}

@Test("Decoded AnyTool throws execution error")
func testDecodedAnyToolExecutionError() async throws {
    let calcTool = CalcSquareRoot()
    let anyTool = AnyTool(calcTool)
    
    // Encode and decode
    let encoder = JSONEncoder()
    let data = try encoder.encode(anyTool)
    let decoder = JSONDecoder()
    let decodedAnyTool = try decoder.decode(AnyTool.self, from: data)
    
    // Test that execution throws an error
    do {
        _ = try await decodedAnyTool.call(arguments: [])
        #expect(Bool(false), "Should have thrown an error")
    } catch ToolError.executionFailed(let message) {
        #expect(message.contains("Cannot execute decoded AnyTool"))
    } catch {
        #expect(Bool(false), "Expected ToolError.executionFailed but got \(error)")
    }
}

@Test("AnyTool works in Codable structs")
func testAnyToolInCodableStruct() throws {
    struct TestResponse: Codable {
        let id: String
        let tool: AnyTool?
    }
    
    let calcTool = CalcSquareRoot()
    let anyTool = AnyTool(calcTool)
    let response = TestResponse(id: "123", tool: anyTool)
    
    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(response)
    
    // Test decoding
    let decoder = JSONDecoder()
    let decodedResponse = try decoder.decode(TestResponse.self, from: data)
    
    #expect(decodedResponse.id == "123")
    #expect(decodedResponse.tool?.definition.name == CalcSquareRoot.definition.name)
}

@Test("AnyTool description provides meaningful output")
func testAnyToolDescription() {
    let calcTool = CalcSquareRoot()
    let anyTool = AnyTool(calcTool)
    
    let description = anyTool.description
    #expect(description.contains("AnyTool"))
    #expect(description.contains("calculate_square_root"))
    #expect(description.contains("Calculates the square root of a number"))
}

@Test("AnyTool with TestTool works correctly")
func testAnyToolWithTestTool() async throws {
    let testTool = TestTool()
    let anyTool = AnyTool(testTool)
    
    // Test execution
    let result = try await anyTool.call(arguments: [])
    
    if case .string(let value) = result {
        #expect(value == "test result")
    } else {
        #expect(Bool(false), "Expected string result")
    }
}