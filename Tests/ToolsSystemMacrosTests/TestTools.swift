//
//  TestTools.swift
//  ToolsSystemMacrosTests
//
//  Created by Morisson Marcel on 11/06/25.
//

import Foundation
import ToolsSystemMacros
import ToolsSystem

// Import sqrt function
import Darwin

// Simple test to verify the macro compiles and works
@Tool("test_tool", "A test tool")
struct TestTool: Sendable {
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .string("test result")
    }
}

@Tool("calculate_square_root", "Calculates the square root of a number")
struct CalcSquareRoot: Sendable {
    
    @ToolArgument("input", "The number to calculate the square root of")
    struct InputArgument: Sendable {
        var number: Double
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let inputArgument = try arguments.decode(InputArgument.self)
        let result = sqrt(inputArgument.number)
        return .double(result)
    }
}