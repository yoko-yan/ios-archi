import XCTest

/// 座標編集画面の Page Object
class CoordinatesEditPage: BasePage {
    // MARK: - UI Elements

    /// ナビゲーションバー
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }

    /// X座標テキストフィールド
    var xTextField: XCUIElement {
        app.textFields["X"]
    }

    /// Y座標テキストフィールド
    var yTextField: XCUIElement {
        app.textFields["Y"]
    }

    /// Z座標テキストフィールド
    var zTextField: XCUIElement {
        app.textFields["Z"]
    }

    /// 変更ボタン
    var modifyButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Modify' OR label CONTAINS[c] '変更'")).firstMatch
    }

    // MARK: - Actions

    /// 座標を入力
    @discardableResult
    func enterCoordinates(x: String, y: String, z: String) -> Self {
        // Xを入力
        let xField = assertExists(xTextField, message: "X座標フィールドが見つかりません")
        xField.tap()
        xField.typeText(x)

        // Yを入力
        let yField = assertExists(yTextField, message: "Y座標フィールドが見つかりません")
        yField.tap()
        yField.typeText(y)

        // Zを入力
        let zField = assertExists(zTextField, message: "Z座標フィールドが見つかりません")
        zField.tap()
        zField.typeText(z)

        // キーボードを閉じる
        dismissKeyboard()

        return self
    }

    /// キーボードを閉じる
    private func dismissKeyboard() {
        // キーボードの閉じるボタンを探す
        let keyboardDismissButton = app.buttons["keyboard.chevron.compact.down"]
        if keyboardDismissButton.exists {
            keyboardDismissButton.tap()
        } else {
            // キーボードが見つからない場合は、画面の上部をタップ
            let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            coordinate.tap()
        }
    }

    /// 変更ボタンをタップ
    @discardableResult
    func tapModifyButton() -> Self {
        let button = assertExists(modifyButton, message: "変更ボタンが見つかりません")
        // ボタンが有効になるまで少し待機
        sleep(1)
        // ボタンが有効か確認
        XCTAssertTrue(button.isEnabled, "変更ボタンが無効です。座標のvalidationエラーがある可能性があります。")
        button.tap()
        return self
    }

    /// 座標編集画面が閉じることを確認
    @discardableResult
    func verifyDismissed(timeout: TimeInterval = 5) -> Self {
        let dismissed = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: dismissed, object: navigationBar)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "座標編集画面が閉じませんでした")
        return self
    }
}
