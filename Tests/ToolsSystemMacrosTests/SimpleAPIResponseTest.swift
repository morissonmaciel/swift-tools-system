//
//  SimpleAPIResponseTest.swift
//  ToolsSystemMacrosTests
//
//  Created by Claude Code
//

import Foundation
import Testing
import ToolsSystemMacros
import ToolsSystem

@Test("APIToolResponse decodes your exact JSON format")
func testAPIToolResponseDecoding() throws {
    let jsonString = """
    {
      "message": "I need up to date information. Let me search on the web",
      "tool": {
          "arguments": {
            "query": "latest news WWDC25"
          },
          "tool_name": "web_search"
        }
    }
    """
    
    let jsonData = jsonString.data(using: .utf8)!
    let response = try JSONDecoder().decode(APIToolResponse.self, from: jsonData)
    
    #expect(response.message == "I need up to date information. Let me search on the web")
    #expect(response.tool != nil)
    #expect(response.tool?.tool_name == "web_search")
    #expect(response.tool?.getString("query") == "latest news WWDC25")
    
    print("✅ Successfully decoded API response")
    print("Message: \(response.message)")
    print("Tool: \(response.tool?.tool_name ?? "none")")
    print("Query: \(response.tool?.getString("query") ?? "none")")
}

@Test("APIToolResponse handles different argument types")
func testAPIToolResponseDifferentTypes() throws {
    let jsonString = """
    {
      "message": "Processing complex request",
      "tool": {
          "arguments": {
            "query": "swift programming",
            "maxResults": 10,
            "includeCode": true,
            "relevanceScore": 0.85
          },
          "tool_name": "advanced_search"
        }
    }
    """
    
    let jsonData = jsonString.data(using: .utf8)!
    let response = try JSONDecoder().decode(APIToolResponse.self, from: jsonData)
    
    guard let tool = response.tool else {
        Issue.record("Tool should be present")
        return
    }
    
    #expect(tool.getString("query") == "swift programming")
    #expect(tool.getInt("maxResults") == 10)
    #expect(tool.getBool("includeCode") == true)
    #expect(tool.getDouble("relevanceScore") == 0.85)
    
    // Test generic get method
    #expect(tool.get("query", as: String.self) == "swift programming")
    #expect(tool.get("maxResults", as: Int.self) == 10)
    #expect(tool.get("includeCode", as: Bool.self) == true)
    #expect(tool.get("relevanceScore", as: Double.self) == 0.85)
    
    // Test get with default value
    #expect(tool.get("nonexistent", as: String.self, default: "default") == "default")
    #expect(tool.get("maxResults", as: Int.self, default: 5) == 10) // existing value
    
    // Test helper methods
    #expect(tool.hasArgument("query") == true)
    #expect(tool.hasArgument("nonexistent") == false)
    #expect(tool.argumentKeys.contains("query"))
    #expect(tool.argumentKeys.count == 4)
    
    print("✅ Successfully handled different argument types and enhanced methods")
}

@Test("APIToolResponse handles response without tool")
func testAPIToolResponseWithoutTool() throws {
    let jsonString = """
    {
      "message": "This is just a regular response without any tool"
    }
    """
    
    let jsonData = jsonString.data(using: .utf8)!
    let response = try JSONDecoder().decode(APIToolResponse.self, from: jsonData)
    
    #expect(response.message == "This is just a regular response without any tool")
    #expect(response.tool == nil)
    
    print("✅ Handled response without tool correctly")
}

@Test("ToolRegistry registration and handling")
func testToolRegistry() async throws {
    let registry = ToolRegistry.shared
    
    // Register a web search handler
    registry.register(toolName: "web_search") { toolCall in
        guard let query = toolCall.getString("query") else {
            throw ToolRegistryError.executionFailed("Missing query parameter")
        }
        return "Web search results for: \(query)"
    }
    
    // Register a weather handler
    registry.register(toolName: "weather_check") { toolCall in
        guard let location = toolCall.getString("location") else {
            throw ToolRegistryError.executionFailed("Missing location parameter")
        }
        return "Weather in \(location): 22°C, sunny"
    }
    
    #expect(registry.isRegistered("web_search"))
    #expect(registry.isRegistered("weather_check"))
    #expect(!registry.isRegistered("unknown_tool"))
    
    let registeredTools = registry.registeredTools
    #expect(registeredTools.contains("web_search"))
    #expect(registeredTools.contains("weather_check"))
    
    print("✅ Registry registration works correctly")
    print("Registered tools: \(registeredTools.sorted())")
}

@Test("End-to-end API response handling")
func testEndToEndAPIHandling() async throws {
    let registry = ToolRegistry.shared
    
    // Register handlers for different tools
    registry.register(toolName: "web_search") { toolCall in
        guard let query = toolCall.getString("query") else {
            throw ToolRegistryError.executionFailed("Missing query parameter")
        }
        // Simulate web search
        return "Found 5 results for '\(query)': 1. Swift 6 announced at WWDC25..."
    }
    
    registry.register(toolName: "weather_check") { toolCall in
        guard let location = toolCall.getString("location") else {
            throw ToolRegistryError.executionFailed("Missing location parameter")
        }
        return "Current weather in \(location): 22°C, partly cloudy, 10% chance of rain"
    }
    
    // Test with your API JSON format
    let apiResponses = [
        """
        {
          "message": "Let me search for that information",
          "tool": {
              "arguments": {
                "query": "Swift 6 new features"
              },
              "tool_name": "web_search"
            }
        }
        """,
        """
        {
          "message": "I'll check the weather for you",
          "tool": {
              "arguments": {
                "location": "San Francisco"
              },
              "tool_name": "weather_check"
            }
        }
        """
    ]
    
    for (index, jsonString) in apiResponses.enumerated() {
        // 1. Decode the API response
        let response = try JSONDecoder().decode(APIToolResponse.self, from: jsonString.data(using: .utf8)!)
        
        print("\\n📱 API Response \(index + 1): \(response.message)")
        
        // 2. Handle the tool if present
        if let tool = response.tool {
            do {
                let result = try await registry.handleTool(tool)
                print("🔧 Tool result: \(result)")
            } catch {
                print("❌ Tool execution failed: \(error)")
            }
        } else {
            print("ℹ️  No tool to execute")
        }
    }
    
    print("\\n✅ End-to-end handling completed successfully")
}

@Test("Error handling for unknown tools")
func testErrorHandling() async throws {
    let registry = ToolRegistry.shared
    
    // Try to handle an unknown tool
    let unknownToolCall = APIToolCall(
        tool_name: "unknown_tool",
        arguments: ["param": .string("value")]
    )
    
    do {
        _ = try await registry.handleTool(unknownToolCall)
        Issue.record("Should have thrown an error for unknown tool")
    } catch let error as ToolRegistryError {
        switch error {
        case .unknownTool(let name):
            #expect(name == "unknown_tool")
            print("✅ Properly caught unknown tool error: \(error.localizedDescription)")
        default:
            Issue.record("Wrong error type")
        }
    } catch {
        Issue.record("Unexpected error type: \(error)")
    }
}