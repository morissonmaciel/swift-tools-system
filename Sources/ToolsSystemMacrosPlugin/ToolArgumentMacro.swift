//
//  ToolArgumentMacro.swift
//  ToolsSystemMacros
//
//  Created by Morisson Marcel on 11/06/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder  
import SwiftSyntaxMacros

public struct ToolArgumentMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract argument name, description, and required example
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              arguments.count >= 3 else {
            throw MacroError.missingArguments
        }
        
        let nameExpr = arguments.first!.expression
        let descExpr = arguments.dropFirst().first!.expression
        
        guard let nameString = extractStringLiteral(nameExpr),
              let descString = extractStringLiteral(descExpr) else {
            throw MacroError.invalidArguments
        }
        
        // Extract required example parameter
        var exampleString: String? = nil
        if arguments.count >= 3 {
            // Look for the example parameter by label
            for argument in arguments.dropFirst(2) {
                if let label = argument.label?.text, label == "example" {
                    exampleString = extractStringLiteral(argument.expression)
                    break
                }
            }
        }
        
        guard let example = exampleString else {
            throw MacroError.missingExample
        }
        
        // Generate the definition property with required example
        let definition = try VariableDeclSyntax("public static var argumentDefinition: ToolArgumentDefinition { ToolArgumentDefinition(name: \(literal: nameString), description: \(literal: descString), example: \(literal: example)) }")
        
        return [DeclSyntax(definition)]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let extensionDecl = try ExtensionDeclSyntax("extension \(type.trimmed): ToolArgumentProtocol {}")
        return [extensionDecl]
    }
    
    private static func extractStringLiteral(_ expr: ExprSyntax) -> String? {
        guard let stringLiteral = expr.as(StringLiteralExprSyntax.self),
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }
        return segment.content.text
    }
}

public struct RequiredMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // For simplicity, just add empty get/set that do nothing special for @Required
        // The @Required is mainly metadata for now
        return []
    }
}