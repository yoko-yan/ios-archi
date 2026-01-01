extension Collection {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            // swiftformat:disable:next hoistTry
            await values.append(try transform(element))
        }
        return values
    }
}
