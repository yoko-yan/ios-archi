enum ValidationResult<T> {
    case valid
    case invalid(T)

    var validationError: T? {
        if case let .invalid(validationError) = self {
            return validationError
        }
        return nil
    }
}
