import XCTest

/// ホーム画面の Page Object
class HomePage: BasePage {
    // MARK: - UI Elements

    /// ホームタブ
    var homeTab: XCUIElement {
        app.tabBars.buttons.element(matching: .button, identifier: "TabItem.home")
    }

    /// ホームタブ（ラベルで検索）
    var homeTabByLabel: XCUIElement {
        app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'ホーム'")).firstMatch
    }

    /// ナビゲーションバーのタイトル
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }

    /// ナビゲーションバーのタイトルテキスト
    var navigationTitle: XCUIElement {
        app.navigationBars["ホーム"]
    }

    /// 情報ボタン（iアイコン）
    var infoButton: XCUIElement {
        // ナビゲーションバー内のボタンを探す
        app.navigationBars.buttons.firstMatch
    }

    /// タイムラインリスト
    var timelineList: XCUIElement {
        // テーブルではなくスクロールビューかもしれない
        if app.tables.firstMatch.exists {
            return app.tables.firstMatch
        } else {
            return app.scrollViews.firstMatch
        }
    }

    /// フローティングボタン（新規作成）
    var floatingButton: XCUIElement {
        app.buttons["FloatingButton"]
    }

    // MARK: - Actions

    /// ホームタブに移動
    @discardableResult
    func goToHomeTab() -> Self {
        if homeTab.exists {
            homeTab.tap()
        } else {
            assertExists(homeTabByLabel, message: "ホームタブが見つかりません").tap()
        }
        return self
    }

    /// ナビゲーションバーの存在を確認
    @discardableResult
    func verifyNavigationBarExists() -> Self {
        assertExists(navigationBar, message: "ナビゲーションバーが見つかりません")
        return self
    }

    /// 情報ボタンをタップしてアプリ情報画面を開く
    @discardableResult
    func tapInfoButton() -> Self {
        assertExists(infoButton, message: "情報ボタンが見つかりません").tap()
        return self
    }

    /// フローティングボタンをタップして新規作成画面を開く
    @discardableResult
    func tapFloatingButton() -> Self {
        assertExists(floatingButton, message: "フローティングボタンが見つかりません").tap()
        return self
    }

    /// タイムラインリストの存在を確認
    @discardableResult
    func verifyTimelineListExists() -> Self {
        assertExists(timelineList, message: "タイムラインリストが見つかりません")
        return self
    }

    /// Pull to Refresh を実行
    @discardableResult
    func pullToRefresh() -> Self {
        if timelineList.exists {
            let start = timelineList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
            let end = timelineList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            start.press(forDuration: 0, thenDragTo: end)
        }
        return self
    }

    /// タイムラインのアイテムをタップ（インデックス指定）
    @discardableResult
    func tapTimelineItem(at index: Int) -> Self {
        let cells = timelineList.cells
        XCTAssertTrue(cells.count > index, "インデックス\(index)のアイテムが存在しません")
        cells.element(boundBy: index).tap()
        return self
    }
}
