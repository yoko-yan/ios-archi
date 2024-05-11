enum SeedValidationError {
    case seed
}

extension SeedValidationError: ValidationError {
    var errorDescription: String? {
        switch self {
        case .seed: return "数字を入力してください"
        }
    }
}

enum SeedValidator {
    static func validate(seed text: String) -> ValidationResult<SeedValidationError> {
        guard Seed(text) != nil else { return .invalid(.seed) }
        return .valid
    }
}
