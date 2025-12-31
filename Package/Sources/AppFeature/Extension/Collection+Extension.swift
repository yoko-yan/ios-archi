extension Collection {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            // swiftformat:disable:next hoistTry
            values.append(try await transform(element))
        }
        return values
    }
}
