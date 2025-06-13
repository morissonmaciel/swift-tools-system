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

@Tool("file_processor", "Processes files with various options")
@ToolInstructions("""
This tool processes files in various formats. Provide the file path as a string,
specify the desired output format, and indicate whether compression should be applied.
The tool supports common formats like JSON, XML, and CSV.
""")
struct FileProcessorTool: Sendable {
    @ToolArgument("file_options", "File processing configuration", example: "/path/to/file.txt")
    struct FileOptions: Sendable {
        let filePath: String
        let format: String
        let compress: Bool
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let options = try arguments.decode(FileOptions.self)
        return .string("File processed: \(options.filePath)")
    }
}

@Tool("calculate_square_root", "Calculates the square root of a number")
struct CalcSquareRoot: Sendable {
    
    @ToolArgument("input", "The number to calculate the square root of", example: "16.0")
    struct InputArgument: Sendable {
        var number: Double
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let inputArgument = try arguments.decode(InputArgument.self)
        let result = sqrt(inputArgument.number)
        return .double(result)
    }
}