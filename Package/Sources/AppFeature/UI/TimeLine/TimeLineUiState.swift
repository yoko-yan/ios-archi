struct TimeLineUiState: Equatable {
    var items: [Item] = []
    var spotImages: [String: SpotImage?] = [:]
    var deleteItems: [Item]?
    var deleteAlertMessage: String?
    var isChecked = true
}
