import SwiftSyntax
import SwiftSyntaxMacros

public struct MockableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw MacroError.notAProtocol
        }

        let protocolName = protocolDecl.name.text
        let mockClassName = "\(protocolName)Mock"
        let accessLevel = protocolDecl.modifiers.accessLevel

        var members: [String] = []

        // init()
        if !accessLevel.isEmpty {
            members.append("    \(accessLevel)init() {}")
        }

        // Process variables
        for member in protocolDecl.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                let varMembers = generateVariableMock(varDecl: varDecl, accessLevel: accessLevel)
                members.append(contentsOf: varMembers)
            }
        }

        // Process methods
        for member in protocolDecl.memberBlock.members {
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
                let funcMembers = generateMethodMock(funcDecl: funcDecl, accessLevel: accessLevel)
                members.append(contentsOf: funcMembers)
            }
        }

        let membersCode = members.joined(separator: "\n\n")

        let mockClass: DeclSyntax = """
        \(raw: accessLevel)class \(raw: mockClassName): \(raw: protocolName) {
        \(raw: membersCode)
        }
        """

        return [mockClass]
    }

    private static func generateVariableMock(varDecl: VariableDeclSyntax, accessLevel: String) -> [String] {
        var results: [String] = []

        for binding in varDecl.bindings {
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation else {
                continue
            }

            let varName = identifier.identifier.text
            let typeName = typeAnnotation.type.description.trimmingWhitespace()
            let isOptional = typeName.hasSuffix("?")

            if isOptional {
                results.append("    \(accessLevel)var \(varName): \(typeName)")
            } else if typeName.hasPrefix("[") || typeName.containsSubstring(": ") {
                // Array or Dictionary
                let defaultValue = typeName.containsSubstring(": ") ? "[:]" : "[]"
                results.append("    \(accessLevel)var \(varName): \(typeName) = \(defaultValue)")
            } else {
                results.append("""
                    \(accessLevel)var \(varName): \(typeName) {
                        get { underlying\(varName.capitalizingFirstLetter()) }
                        set { underlying\(varName.capitalizingFirstLetter()) = newValue }
                    }
                    \(accessLevel)var underlying\(varName.capitalizingFirstLetter()): \(typeName)!
                """)
            }
        }

        return results
    }

    private static func generateMethodMock(funcDecl: FunctionDeclSyntax, accessLevel: String) -> [String] {
        var results: [String] = []

        let funcName = funcDecl.name.text
        let selectorName = generateSelectorName(funcDecl: funcDecl)
        let isAsync = funcDecl.signature.effectSpecifiers?.asyncSpecifier != nil
        let isThrows = funcDecl.signature.effectSpecifiers?.throwsClause != nil
        let returnType = funcDecl.signature.returnClause?.type.description.trimmingWhitespace()
        let parameters = funcDecl.signature.parameterClause.parameters

        // MARK comment
        results.append("    // MARK: - \(funcName)")

        // Throwable error
        if isThrows {
            results.append("    \(accessLevel)var \(selectorName)ThrowableError: (any Error)?")
        }

        // CallsCount
        results.append("    \(accessLevel)var \(selectorName)CallsCount = 0")

        // Called
        results.append("""
            \(accessLevel)var \(selectorName)Called: Bool {
                \(selectorName)CallsCount > 0
            }
        """)

        // ReceivedArguments (for methods with parameters)
        if parameters.count == 1, let param = parameters.first {
            let paramName = param.secondName?.text ?? param.firstName.text
            let paramType = param.type.description.trimmingWhitespace()
            results.append("    \(accessLevel)var \(selectorName)Received\(paramName.capitalizingFirstLetter()): \(paramType)?")
            results.append("    \(accessLevel)var \(selectorName)ReceivedInvocations: [\(paramType)] = []")
        } else if parameters.count > 1 {
            let tupleType = parameters.map { param -> String in
                let paramName = param.secondName?.text ?? param.firstName.text
                let paramType = param.type.description.trimmingWhitespace()
                return "\(paramName): \(paramType)"
            }.joined(separator: ", ")
            results.append("    \(accessLevel)var \(selectorName)ReceivedArguments: (\(tupleType))?")
            results.append("    \(accessLevel)var \(selectorName)ReceivedInvocations: [(\(tupleType))] = []")
        }

        // ReturnValue
        if let returnType = returnType, returnType != "Void" {
            let isOptionalReturn = returnType.hasSuffix("?")
            if isOptionalReturn {
                results.append("    \(accessLevel)var \(selectorName)ReturnValue: \(returnType)")
            } else {
                results.append("    \(accessLevel)var \(selectorName)ReturnValue: \(returnType)!")
            }
        }

        // Closure
        let closureParams = parameters.map { param -> String in
            param.type.description.trimmingWhitespace()
        }.joined(separator: ", ")
        let closureReturn = returnType ?? "Void"
        let asyncPart = isAsync ? "async " : ""
        let throwsPart = isThrows ? "throws " : ""
        results.append("    \(accessLevel)var \(selectorName)Closure: ((\(closureParams)) \(asyncPart)\(throwsPart)-> \(closureReturn))?")

        // Method implementation
        let paramsDecl = parameters.map { param -> String in
            let firstName = param.firstName.text
            let secondName = param.secondName?.text ?? firstName
            let paramType = param.type.description.trimmingWhitespace()
            if firstName == "_" {
                return "_ \(secondName): \(paramType)"
            } else if firstName == secondName {
                return "\(firstName): \(paramType)"
            } else {
                return "\(firstName) \(secondName): \(paramType)"
            }
        }.joined(separator: ", ")

        let effectsPart = [
            isAsync ? " async" : "",
            isThrows ? " throws" : ""
        ].joined()

        let returnPart = returnType.map { " -> \($0)" } ?? ""

        var methodBody: [String] = []

        // Throw error if set
        if isThrows {
            methodBody.append("""
                        if let error = \(selectorName)ThrowableError {
                            throw error
                        }
            """)
        }

        // Increment call count
        methodBody.append("        \(selectorName)CallsCount += 1")

        // Record received arguments
        if parameters.count == 1, let param = parameters.first {
            let paramName = param.secondName?.text ?? param.firstName.text
            methodBody.append("        \(selectorName)Received\(paramName.capitalizingFirstLetter()) = \(paramName)")
            methodBody.append("        \(selectorName)ReceivedInvocations.append(\(paramName))")
        } else if parameters.count > 1 {
            let argsTuple = parameters.map { param -> String in
                let paramName = param.secondName?.text ?? param.firstName.text
                return "\(paramName): \(paramName)"
            }.joined(separator: ", ")
            methodBody.append("        \(selectorName)ReceivedArguments = (\(argsTuple))")
            methodBody.append("        \(selectorName)ReceivedInvocations.append((\(argsTuple)))")
        }

        // Call closure or return value
        let closureCallArgs = parameters.map { param -> String in
            param.secondName?.text ?? param.firstName.text
        }.joined(separator: ", ")

        let tryPart = isThrows ? "try " : ""
        let awaitPart = isAsync ? "await " : ""

        if let returnType = returnType, returnType != "Void" {
            methodBody.append("""
                        if let closure = \(selectorName)Closure {
                            return \(tryPart)\(awaitPart)closure(\(closureCallArgs))
                        } else {
                            return \(selectorName)ReturnValue
                        }
            """)
        } else {
            methodBody.append("        \(tryPart)\(awaitPart)\(selectorName)Closure?(\(closureCallArgs))")
        }

        let methodBodyCode = methodBody.joined(separator: "\n")

        results.append("""
            \(accessLevel)func \(funcName)(\(paramsDecl))\(effectsPart)\(returnPart) {
        \(methodBodyCode)
            }
        """)

        return results
    }

    private static func generateSelectorName(funcDecl: FunctionDeclSyntax) -> String {
        let funcName = funcDecl.name.text
        let parameters = funcDecl.signature.parameterClause.parameters

        if parameters.isEmpty {
            return funcName
        }

        var selectorParts = [funcName]
        for param in parameters {
            let label = param.firstName.text
            if label != "_" {
                selectorParts.append(label.capitalizingFirstLetter())
            }
        }

        return selectorParts.joined()
    }
}

enum MacroError: Error, CustomStringConvertible {
    case notAProtocol

    var description: String {
        switch self {
        case .notAProtocol:
            return "@Mockable can only be applied to protocols"
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }

    func trimmingWhitespace() -> String {
        var result = self[...]
        while result.first?.isWhitespace == true {
            result = result.dropFirst()
        }
        while result.last?.isWhitespace == true {
            result = result.dropLast()
        }
        return String(result)
    }

    func containsSubstring(_ substring: String) -> Bool {
        guard !substring.isEmpty else { return true }
        var index = startIndex
        while index < endIndex {
            let remaining = self[index...]
            if remaining.hasPrefix(substring) {
                return true
            }
            index = self.index(after: index)
        }
        return false
    }
}

extension DeclModifierListSyntax {
    var accessLevel: String {
        for modifier in self {
            switch modifier.name.tokenKind {
            case .keyword(.public):
                return "public "
            case .keyword(.internal):
                return ""
            case .keyword(.private):
                return "private "
            case .keyword(.fileprivate):
                return "fileprivate "
            default:
                continue
            }
        }
        return ""
    }
}
