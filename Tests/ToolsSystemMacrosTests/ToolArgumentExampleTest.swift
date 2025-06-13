//
//  ToolArgumentExampleTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Tool("web_search_with_example", "Search web for results based on query string with example")
struct WebSearchToolWithExample {
    @ToolArgument("query", "Query string to search web for", example: "latest news on AI")
    struct QueryArgument {
        var query: String
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let queryArg = try arguments.decode(QueryArgument.self)
        // Mock implementation for testing
        let searchResults = [
            ["title": "AI News", "url": "https://example.com", "snippet": "Latest AI developments"]
        ]
        return .dictionaryArray(searchResults)
    }
}

@Tool("multi_argument_tool", "Tool with multiple arguments including examples")
struct MultiArgumentTool {
    @ToolArgument("search_query", "The search query to execute", example: "swift programming")
    struct SearchQuery {
        var query: String
        var maxResults: Int
    }
    
    @ToolArgument("filter_options", "Options to filter results", example: "english")
    struct FilterOptions {
        var language: String
        var sortBy: String
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .string("Mock response")
    }
}

@Tool("tool_with_basic_example", "Tool with basic argument example")
struct ToolWithBasicExample {
    @ToolArgument("input", "Input with basic example", example: "sample input")
    struct InputArgument {
        var value: String
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        return .string("Mock response")
    }
}

@Test("ToolArgument with example generates proper argumentDefinition")
func testToolArgumentWithExample() throws {
    let definition = WebSearchToolWithExample.QueryArgument.argumentDefinition
    
    #expect(definition.name == "query")
    #expect(definition.description == "Query string to search web for")
    #expect(definition.example == "latest news on AI")
}

@Test("ToolArgument with basic example generates proper argumentDefinition")
func testToolArgumentWithBasicExample() throws {
    let definition = ToolWithBasicExample.InputArgument.argumentDefinition
    
    #expect(definition.name == "input")
    #expect(definition.description == "Input with basic example")
    #expect(definition.example == "sample input")
}

@Test("Tool with example generates proper JSON descriptor with examples in arguments")
func testToolWithExampleJSONDescriptor() throws {
    print("🎉 TOOL WITH EXAMPLE JSON OUTPUT:")
    print(WebSearchToolWithExample.jsonDescription)
    
    let descriptor = WebSearchToolWithExample.toolDescriptor
    
    #expect(descriptor.tool_name == "web_search_with_example")
    #expect(descriptor.description == "Search web for results based on query string with example")
    #expect(descriptor.arguments.count == 1)
    
    let firstArg = descriptor.arguments[0]
    #expect(firstArg.name == "query")
    #expect(firstArg.description == "Query string to search web for")
    #expect(firstArg.type.type == "string")
    
    // Check that example is included in the tool example
    #expect(descriptor.example != nil, "Should have example section")
    #expect(descriptor.example?.tool_name == "web_search_with_example")
    #expect(descriptor.example?.arguments.count == 1, "Should have one example argument")
    
    if let exampleArgs = descriptor.example?.arguments,
       let queryExample = exampleArgs["query"]?.value as? String {
        #expect(queryExample == "latest news on AI", "Example value should match what was provided")
    } else {
        Issue.record("Example arguments should contain query with correct value")
    }
}

@Test("Tool with multiple arguments generates proper examples")
func testMultiArgumentToolWithExamples() throws {
    print("🎉 MULTI-ARGUMENT TOOL JSON OUTPUT:")
    print(MultiArgumentTool.jsonDescription)
    
    let descriptor = MultiArgumentTool.toolDescriptor
    
    #expect(descriptor.tool_name == "multi_argument_tool")
    #expect(descriptor.arguments.count == 2)
    
    // Check that examples are included for both arguments
    #expect(descriptor.example != nil, "Should have example section")
    #expect(descriptor.example?.arguments.count == 2, "Should have examples for both arguments")
    
    if let exampleArgs = descriptor.example?.arguments {
        if let searchQueryExample = exampleArgs["search_query"]?.value as? String {
            #expect(searchQueryExample == "swift programming")
        } else {
            Issue.record("search_query example should be present")
        }
        
        if let filterExample = exampleArgs["filter_options"]?.value as? String {
            #expect(filterExample == "english")
        } else {
            Issue.record("filter_options example should be present")
        }
    }
}

@Test("Tool with basic example generates proper JSON descriptor")
func testToolWithBasicExampleJSONDescriptor() throws {
    print("🎉 TOOL WITH BASIC EXAMPLE JSON OUTPUT:")
    print(ToolWithBasicExample.jsonDescription)
    
    let descriptor = ToolWithBasicExample.toolDescriptor
    
    #expect(descriptor.tool_name == "tool_with_basic_example")
    #expect(descriptor.arguments.count == 1)
    
    // Check that example section exists with proper arguments
    #expect(descriptor.example != nil, "Should have example section")
    #expect(descriptor.example?.tool_name == "tool_with_basic_example")
    #expect(descriptor.example?.arguments.count == 1, "Should have one example argument")
    
    if let exampleArgs = descriptor.example?.arguments,
       let inputExample = exampleArgs["input"]?.value as? String {
        #expect(inputExample == "sample input", "Example value should match what was provided")
    } else {
        Issue.record("Example arguments should contain input with correct value")
    }
}

@Test("JSON serialization produces expected format with examples")
func testJSONSerializationWithExamples() throws {
    let descriptor = WebSearchToolWithExample.toolDescriptor
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    
    let jsonData = try encoder.encode(descriptor)
    let jsonString = String(data: jsonData, encoding: .utf8)!
    
    print("🎉 SERIALIZED JSON WITH EXAMPLES:")
    print(jsonString)
    
    // Verify the JSON contains the expected structure
    #expect(jsonString.contains("\"tool_name\" : \"web_search_with_example\""))
    #expect(jsonString.contains("\"example\" : {"))
    #expect(jsonString.contains("\"arguments\" : {"))
    #expect(jsonString.contains("\"query\" : \"latest news on AI\""))
}