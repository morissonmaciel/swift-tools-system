//
//  WebSearchToolTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Tool("web_search", "Search web for results based on query string")
struct WebSearchTool {
    enum WebSearchToolError: Error {
        case duckDuckGoParsingError
    }
    
    @ToolArgument("query", "Query string to search web for", example: "latest news on AI")
    struct QueryArgument {
        var query: String
    }
    
    func call(arguments: [Argument]) async throws -> ToolOutput {
        let queryArg = try arguments.decode(QueryArgument.self)
        // Mock implementation for testing
        let searchResults = [
            ["title": "Test Result", "url": "https://example.com", "snippet": "Test snippet"]
        ]
        return .dictionaryArray(searchResults)
    }
}

@Test("WebSearchTool generates proper JSON descriptor with arguments")
func testWebSearchToolJSONDescriptor() throws {
    print("🎉 IMPROVED JSON OUTPUT:")
    print(WebSearchTool.jsonDescription)
    
    let descriptor = WebSearchTool.toolDescriptor
    
    #expect(descriptor.tool_name == "web_search")
    #expect(descriptor.description == "Search web for results based on query string")
    #expect(descriptor.arguments.count > 0, "Arguments should be parsed and included")
    
    if !descriptor.arguments.isEmpty {
        let firstArg = descriptor.arguments[0]
        #expect(firstArg.name == "query")
        #expect(firstArg.description == "Query string to search web for")
        #expect(firstArg.type.type == "string", "Should be string type")
    }
    
    #expect(descriptor.example != nil, "Should have example section")
    #expect(descriptor.example?.tool_name == "web_search", "Example should have correct tool name")
}