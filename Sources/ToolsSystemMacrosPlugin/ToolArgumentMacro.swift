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
        // Extract argument name and description
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              arguments.count >= 2 else {
            throw MacroError.missingArguments
        }
        
        let nameExpr = arguments.first!.expression
        let descExpr = arguments.dropFirst().first!.expression
        
        guard let nameString = extractStringLiteral(nameExpr),
              let descString = extractStringLiteral(descExpr) else {
            throw MacroError.invalidArguments
        }
        
        // Generate the definition property
        let definition = try VariableDeclSyntax("public static var argumentDefinition: ToolArgumentDefinition { ToolArgumentDefinition(name: \(literal: nameString), description: \(literal: descString)) }")
        
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