import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ToolsSystemMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ToolMacro.self,
        ToolArgumentMacro.self,
        RequiredMacro.self,
    ]
}