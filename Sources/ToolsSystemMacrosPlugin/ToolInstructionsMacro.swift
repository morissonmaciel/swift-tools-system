//
//  ToolInstructionsMacro.swift
//  ToolsSystemMacros
//
//  Created by Morisson Marcel on 13/06/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder  
import SwiftSyntaxMacros

/// A macro that generates an `instructions` property from a string literal.
///
/// Usage:
/// ```swift
/// @Tool("example", "Example tool")
/// struct ExampleTool {
///     @ToolInstructions("Detailed instructions on how to use this tool...")
///     
///     func execute() -> String {
///         return "Hello"
///     }
/// }
/// ```
///
/// This macro will generate:
/// ```swift
/// public let instructions: String = "Detailed instructions on how to use this tool..."
/// ```
public struct ToolInstructionsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract the instructions string parameter
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              arguments.count >= 1 else {
            throw MacroError.missingArguments
        }
        
        let instructionsExpr = arguments.first!.expression
        
        guard let instructionsString = extractStringLiteral(instructionsExpr) else {
            throw MacroError.invalidArguments
        }
        
        // Generate the instructions property
        let instructionsProperty = try VariableDeclSyntax("public let instructions: String = \(literal: instructionsString)")
        
        return [DeclSyntax(instructionsProperty)]
    }
    
    /// Extracts a string literal value from an expression.
    ///
    /// - Parameter expr: The expression to extract the string from
    /// - Returns: The string value if the expression is a string literal, nil otherwise
    private static func extractStringLiteral(_ expr: ExprSyntax) -> String? {
        guard let stringLiteral = expr.as(StringLiteralExprSyntax.self),
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }
        return segment.content.text
    }
}