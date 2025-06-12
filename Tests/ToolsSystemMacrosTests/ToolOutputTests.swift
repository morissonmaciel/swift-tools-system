//
//  ToolOutputTests.swift
//  ToolsSystemMacrosTests
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation
import Testing
import ToolsSystem

@Test("ToolOutput supports array type")
func testToolOutputArray() throws {
    // Test creating array output
    let arrayOutput = ToolOutput.array(["hello", 42, true])
    
    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(arrayOutput)
    
    // Test decoding
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ToolOutput.self, from: data)
    
    if case .array(let decodedArray) = decoded {
        #expect(decodedArray.count == 3)
        // Note: The exact values may be stored as different types due to type erasure
        // but the count should match
    } else {
        #expect(Bool(false), "Expected array case")
    }
}

@Test("ToolOutput supports basic types")
func testToolOutputBasicTypes() throws {
    // Test string
    let stringOutput = ToolOutput.string("test")
    let encodedString = try JSONEncoder().encode(stringOutput)
    let decodedString = try JSONDecoder().decode(ToolOutput.self, from: encodedString)
    if case .string(let value) = decodedString {
        #expect(value == "test")
    } else {
        #expect(Bool(false), "Expected string case")
    }
    
    // Test double
    let doubleOutput = ToolOutput.double(3.14)
    let encodedDouble = try JSONEncoder().encode(doubleOutput)
    let decodedDouble = try JSONDecoder().decode(ToolOutput.self, from: encodedDouble)
    if case .double(let value) = decodedDouble {
        #expect(value == 3.14)
    } else {
        #expect(Bool(false), "Expected double case")
    }
    
    // Test int
    let intOutput = ToolOutput.int(42)
    let encodedInt = try JSONEncoder().encode(intOutput)
    let decodedInt = try JSONDecoder().decode(ToolOutput.self, from: encodedInt)
    if case .int(let value) = decodedInt {
        #expect(value == 42)
    } else {
        #expect(Bool(false), "Expected int case")
    }
    
    // Test bool
    let boolOutput = ToolOutput.bool(true)
    let encodedBool = try JSONEncoder().encode(boolOutput)
    let decodedBool = try JSONDecoder().decode(ToolOutput.self, from: encodedBool)
    if case .bool(let value) = decodedBool {
        #expect(value == true)
    } else {
        #expect(Bool(false), "Expected bool case")
    }
}