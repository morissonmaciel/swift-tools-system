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
        
        guard let _ = extractStringLiteral(nameExpr),
              let _ = extractStringLiteral(descExpr) else {
            throw MacroError.invalidArguments
        }
        
        // Look for nested argument structs or create a default one
        var argumentTypeAlias: TypeAliasDeclSyntax
        
        // Check if the declaration has any nested structs with @ToolArgument
        var argumentTypeName: String? = nil
        for member in declaration.memberBlock.members {
            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                // Check if struct has @ToolArgument attribute
                for attribute in structDecl.attributes {
                    if let attributeSyntax = attribute.as(AttributeSyntax.self),
                       let identifier = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self),
                       identifier.name.text == "ToolArgument" {
                        argumentTypeName = structDecl.name.text
                        break
                    }
                }
                if argumentTypeName != nil {
                    break
                }
            }
        }
        
        if let typeName = argumentTypeName {
            argumentTypeAlias = try TypeAliasDeclSyntax("public typealias Argument = \(raw: typeName)")
        } else {
            // Create a default empty argument type
            argumentTypeAlias = try TypeAliasDeclSyntax("public typealias Argument = EmptyArgument")
        }
        
        return [DeclSyntax(argumentTypeAlias)]
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
        var exampleArguments: [String] = []
        
        // Look for nested structs with @ToolArgument
        for member in declaration.memberBlock.members {
            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                // Check if struct has @ToolArgument attribute
                for attribute in structDecl.attributes {
                    if let attributeSyntax = attribute.as(AttributeSyntax.self),
                       let identifier = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self),
                       identifier.name.text == "ToolArgument" {
                        
                        // Extract argument name, description, and example from @ToolArgument
                        if let arguments = attributeSyntax.arguments?.as(LabeledExprListSyntax.self),
                           arguments.count >= 2,
                           let argNameString = extractStringLiteral(arguments.first!.expression),
                           let argDescString = extractStringLiteral(arguments.dropFirst().first!.expression) {
                            
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
                            
                            // Generate type information for this argument
                            // For now, we'll infer the type from the first property
                            var argumentType = "string" // default
                            
                            for memberDecl in structDecl.memberBlock.members {
                                if let varDecl = memberDecl.decl.as(VariableDeclSyntax.self),
                                   let binding = varDecl.bindings.first,
                                   let typeAnnotation = binding.typeAnnotation?.type {
                                    
                                    let typeName = typeAnnotation.description.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    // Map Swift types to JSON schema types
                                    switch typeName {
                                    case "String":
                                        argumentType = "string"
                                    case "Int", "Int32", "Int64":
                                        argumentType = "integer"
                                    case "Double", "Float":
                                        argumentType = "number"
                                    case "Bool":
                                        argumentType = "boolean"
                                    default:
                                        argumentType = "string"
                                    }
                                    break // Use the first property's type
                                }
                            }
                            
                            argumentDescriptors.append("ArgumentDescriptor(name: \"\(argNameString)\", description: \"\(argDescString)\", type: ArgumentTypeDescriptor(type: \"\(argumentType)\"))")
                            
                            // Add example to arguments (now required)
                            if let example = exampleString {
                                exampleArguments.append("\"\(argNameString)\": AnyCodable(\"\(example)\")")
                            } else {
                                // This should not happen with required examples, but handle gracefully
                                exampleArguments.append("\"\(argNameString)\": AnyCodable(\"example value\")")
                            }
                        }
                    }
                }
            }
        }
        
        let argumentsArray = argumentDescriptors.isEmpty ? "[]" : "[\(argumentDescriptors.joined(separator: ", "))]"
        let exampleArgumentsDict = exampleArguments.isEmpty ? "[:]" : "[\(exampleArguments.joined(separator: ", "))]"
        
        let extensionDecl = try ExtensionDeclSyntax("""
            extension \(type.trimmed): ToolProtocol {
                public static var definition: ToolDefinition {
                    ToolDefinition(name: \(literal: nameString), description: \(literal: descString))
                }
                
                public static var toolDescriptor: ToolDescriptor {
                    let example = ToolExample(
                        toolName: \(literal: nameString),
                        arguments: \(raw: exampleArgumentsDict)
                    )
                    return ToolDescriptor(
                        toolName: \(literal: nameString),
                        description: \(literal: descString),
                        arguments: \(raw: argumentsArray),
                        example: example
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
    case missingExample
    
    var description: String {
        switch self {
        case .missingArguments:
            return "Missing arguments"
        case .invalidArguments:
            return "Invalid arguments"
        case .missingExample:
            return "Missing required example parameter"
        }
    }
}