//
//  ToolMacro.swift
//  ToolsSystemMacros
//
//  Created by Morisson Marcel on 11/06/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder  
import SwiftSyntaxMacros

public struct ToolMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // Extract tool name and description
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
        let definition = try VariableDeclSyntax("public static var definition: ToolDefinition { ToolDefinition(name: \(literal: nameString), description: \(literal: descString)) }")
        
        // Look for nested argument structs or create a default one
        var argumentTypeAlias: TypeAliasDeclSyntax
        
        // Check if the declaration has any nested structs that might be argument types
        let hasInputArgument = declaration.memberBlock.members.contains { member in
            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                return structDecl.name.text == "InputArgument"
            }
            return false
        }
        
        if hasInputArgument {
            argumentTypeAlias = try TypeAliasDeclSyntax("public typealias Argument = InputArgument")
        } else {
            // Create a default empty argument type
            argumentTypeAlias = try TypeAliasDeclSyntax("public typealias Argument = EmptyArgument")
        }
        
        return [DeclSyntax(definition), DeclSyntax(argumentTypeAlias)]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Extract tool name and description for the extension
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
        
        // Generate argument descriptors based on nested structs
        var argumentDescriptors: [String] = []
        
        // Look for nested structs with @ToolArgument
        for member in declaration.memberBlock.members {
            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                // Check if struct has @ToolArgument attribute
                for attribute in structDecl.attributes {
                    if let attributeSyntax = attribute.as(AttributeSyntax.self),
                       let identifier = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self),
                       identifier.name.text == "ToolArgument" {
                        
                        // Extract argument name and description from @ToolArgument
                        if let arguments = attributeSyntax.arguments?.as(LabeledExprListSyntax.self),
                           arguments.count >= 2,
                           let argNameString = extractStringLiteral(arguments.first!.expression),
                           let argDescString = extractStringLiteral(arguments.dropFirst().first!.expression) {
                            
                            // Generate properties map for this argument
                            var properties: [String] = []
                            for memberDecl in structDecl.memberBlock.members {
                                if let varDecl = memberDecl.decl.as(VariableDeclSyntax.self),
                                   let binding = varDecl.bindings.first,
                                   let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                                   let typeAnnotation = binding.typeAnnotation?.type {
                                    
                                    let propertyName = identifier.text
                                    let typeName = typeAnnotation.description.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    // Check if property has @Required attribute
                                    let isRequired = varDecl.attributes.contains { attr in
                                        if let attrSyntax = attr.as(AttributeSyntax.self),
                                           let attrId = attrSyntax.attributeName.as(IdentifierTypeSyntax.self) {
                                            return attrId.name.text == "Required"
                                        }
                                        return false
                                    }
                                    
                                    properties.append("\"\(propertyName)\": PropertyDescriptor(type: \"\(typeName)\", required: \(isRequired))")
                                }
                            }
                            
                            let propertiesString = properties.isEmpty ? "[:]" : "[\(properties.joined(separator: ", "))]"
                            argumentDescriptors.append("ArgumentDescriptor(name: \"\(argNameString)\", description: \"\(argDescString)\", properties: \(propertiesString))")
                        }
                    }
                }
            }
        }
        
        let argumentsArray = argumentDescriptors.isEmpty ? "[]" : "[\(argumentDescriptors.joined(separator: ", "))]"
        
        let extensionDecl = try ExtensionDeclSyntax("""
            extension \(type.trimmed): ToolProtocol {
                var definition: ToolDefinition {
                    ToolDefinition(name: \(literal: nameString), description: \(literal: descString))
                }
                
                var toolDescriptor: ToolDescriptor {
                    return ToolDescriptor(
                        name: \(literal: nameString),
                        description: \(literal: descString),
                        arguments: \(raw: argumentsArray),
                        returnType: ReturnTypeDescriptor()
                    )
                }
            }
            """)
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

enum MacroError: Error, CustomStringConvertible {
    case missingArguments
    case invalidArguments
    
    var description: String {
        switch self {
        case .missingArguments:
            return "Missing arguments"
        case .invalidArguments:
            return "Invalid arguments"
        }
    }
}