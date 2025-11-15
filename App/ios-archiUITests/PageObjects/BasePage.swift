import XCTest

/// Page Object の基底クラス
class BasePage {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    /// スプラッシュ画面が消えるまで待機
    func waitForSplashScreenToDisappear() {
        // タブバーが表示されるまで待機（最大10秒）
        let tabBar = app.tabBars.firstMatch
        _ = tabBar.waitForExistence(timeout: 10)
        // さらに少し待機してアニメーションが完了するのを待つ
        sleep(1)
    }

    /// 要素が存在することを確認
    @discardableResult
    func assertExists(_ element: XCUIElement, timeout: TimeInterval = 5, message: String = "") -> XCUIElement {
        let exists = element.waitForExistence(timeout: timeout)
        XCTAssertTrue(exists, message.isEmpty ? "\(element) が見つかりません" : message)
        return element
    }

    /// 要素が存在しないことを確認
    func assertNotExists(_ element: XCUIElement, message: String = "") {
        XCTAssertFalse(element.exists, message.isEmpty ? "\(element) が存在してはいけません" : message)
    }
}
