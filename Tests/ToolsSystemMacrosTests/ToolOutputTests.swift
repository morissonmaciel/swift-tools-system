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

@Test("ToolOutput supports dictionary type")
func testToolOutputDictionary() throws {
    // Test creating dictionary output
    let dictOutput = ToolOutput.dictionary([
        "name": "John",
        "age": 30,
        "active": true,
        "score": 95.5
    ])
    
    // Test encoding
    let encoder = JSONEncoder()
    let data = try encoder.encode(dictOutput)
    
    // Test decoding
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ToolOutput.self, from: data)
    
    if case .dictionary(let decodedDict) = decoded {
        #expect(decodedDict.count == 4)
        #expect(decodedDict["name"] as? String == "John")
        #expect(decodedDict["age"] as? Int == 30)
        #expect(decodedDict["active"] as? Bool == true)
        #expect(decodedDict["score"] as? Double == 95.5)
    } else {
        #expect(Bool(false), "Expected dictionary case")
    }
}

@Test("ToolOutput dictionary description returns pretty JSON")
func testToolOutputDictionaryDescription() {
    let dictOutput = ToolOutput.dictionary([
        "name": "Alice",
        "age": 25,
        "skills": ["Swift", "Python"],
        "available": true
    ])
    
    let description = dictOutput.description
    
    // Check that it contains JSON structure
    #expect(description.contains("{"))
    #expect(description.contains("}"))
    #expect(description.contains("\"name\""))
    #expect(description.contains("\"Alice\""))
    #expect(description.contains("\"age\""))
    #expect(description.contains("25"))
    #expect(description.contains("\"available\""))
    #expect(description.contains("true"))
}

@Test("ToolOutput description works for all types")
func testToolOutputDescriptions() {
    // Test string description
    let stringOutput = ToolOutput.string("Hello World")
    #expect(stringOutput.description == "Hello World")
    
    // Test int description
    let intOutput = ToolOutput.int(42)
    #expect(intOutput.description == "42")
    
    // Test double description
    let doubleOutput = ToolOutput.double(3.14)
    #expect(doubleOutput.description == "3.14")
    
    // Test bool description
    let boolOutput = ToolOutput.bool(true)
    #expect(boolOutput.description == "true")
    
    // Test array description
    let arrayOutput = ToolOutput.array(["a", 1, false])
    #expect(arrayOutput.description.contains("["))
    #expect(arrayOutput.description.contains("]"))
    #expect(arrayOutput.description.contains("a"))
    #expect(arrayOutput.description.contains("1"))
    #expect(arrayOutput.description.contains("false"))
}