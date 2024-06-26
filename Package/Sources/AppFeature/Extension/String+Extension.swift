extension String {
    func withOutWhitespaces() -> String {
        trimmingCharacters(in: .whitespaces)
    }

    func convertibleInt() -> String {
        let str = withOutWhitespaces()
        if str.isEmpty {
            return str
        } else if let int = Int(str) {
            return String(int)
        }
        return str
    }
}
