//
//  ToolMacroTests.swift
//  ToolsSystemMacrosTests
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Test("Tool macro generates correct definition")
func testToolMacroDefinition() {
    let definition = TestTool.definition
    
    #expect(definition.name == "test_tool")
    #expect(definition.description == "A test tool")
}

@Test("Tool macro works with different names and descriptions")
func testToolMacroWithDifferentValues() {
    let definition = CalcSquareRoot.definition
    
    #expect(definition.name == "calculate_square_root")
    #expect(definition.description == "Calculates the square root of a number")
}

@Test("Tool conforms to ToolProtocol")
func testToolProtocolConformance() {
    let tool = TestTool()
    #expect(tool is any ToolProtocol)
    
    let calcTool = CalcSquareRoot()
    #expect(calcTool is any ToolProtocol)
}

@Test("Tool macro integrates with ToolInstructions")
func testToolWithInstructions() {
    let definition = FileProcessorTool.definition
    
    #expect(definition.name == "file_processor")
    #expect(definition.description == "Processes files with various options")
    #expect(!definition.instructions.isEmpty)
    #expect(definition.instructions.contains("This tool processes files in various formats"))
    #expect(definition.instructions.contains("JSON, XML, and CSV"))
}

@Test("Tool without instructions has empty instructions")
func testToolWithoutInstructions() {
    let definition = TestTool.definition
    
    #expect(definition.name == "test_tool")
    #expect(definition.description == "A test tool")
    #expect(definition.instructions.isEmpty)
}