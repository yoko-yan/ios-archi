import XCTest

/// アイテム編集画面の Page Object
class ItemEditPage: BasePage {
    // MARK: - UI Elements

    /// ナビゲーションバー
    var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }

    /// 閉じるボタン（×）
    var closeButton: XCUIElement {
        app.buttons["xmark"]
    }

    /// 写真を登録ボタン
    var photoRegistrationButton: XCUIElement {
        app.buttons["写真を登録"]
    }

    /// カメラボタン
    var cameraButton: XCUIElement {
        app.buttons["camera.circle.fill"]
    }

    /// 写真選択ボタン
    var photoPickerButton: XCUIElement {
        app.buttons["photo.circle.fill"]
    }

    /// 座標セル
    var coordinatesCell: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS 'Coordinates' OR label CONTAINS '座標'")).firstMatch
    }

    /// ワールドセル
    var worldCell: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS '未選択' OR label CONTAINS '選択済み' OR (label CONTAINS 'ワールド' AND label CONTAINS ',')")).firstMatch
    }

    /// 登録ボタン
    var registerButton: XCUIElement {
        // "登録" または "Register" を含むボタン
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '登録' OR label CONTAINS[c] 'Register'")).firstMatch
    }

    /// 削除ボタン
    var deleteButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '削除' OR label CONTAINS[c] 'Delete'")).firstMatch
    }

    // MARK: - Actions

    /// シートが表示されることを確認
    @discardableResult
    func verifySheetIsDisplayed() -> Self {
        assertExists(navigationBar, message: "アイテム編集画面が表示されませんでした")
        return self
    }

    /// 座標セルをタップして座標入力画面に遷移
    @discardableResult
    func tapCoordinatesCell() -> Self {
        assertExists(coordinatesCell, message: "座標セルが見つかりません").tap()
        return self
    }

    /// 閉じるボタンをタップ
    @discardableResult
    func tapCloseButton() -> Self {
        assertExists(closeButton, message: "閉じるボタンが見つかりません").tap()
        return self
    }

    /// 登録ボタンをタップ
    @discardableResult
    func tapRegisterButton() -> Self {
        assertExists(registerButton, message: "登録ボタンが見つかりません").tap()
        return self
    }

    /// 登録ボタンが有効になるまで待機
    @discardableResult
    func waitForRegisterButtonToBeEnabled(timeout: TimeInterval = 3) -> Self {
        let button = registerButton
        assertExists(button, timeout: timeout, message: "登録ボタンが見つかりません")
        // ボタンが有効になるまで少し待機
        sleep(1)
        return self
    }

    /// シートが閉じることを確認
    @discardableResult
    func verifySheetIsDismissed(timeout: TimeInterval = 5) -> Self {
        let sheetDismissed = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: sheetDismissed, object: navigationBar)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "シートが閉じませんでした")
        return self
    }
}
