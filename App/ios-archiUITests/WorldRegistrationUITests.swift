import XCTest

final class WorldRegistrationUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    /// Worldを新規登録するUIテスト
    func testRegisterNewWorld() throws {
        // スプラッシュ画面が消えるまで待機
        sleep(3)

        // Worldタブ（globe.desk）をタップ
        let worldTab = app.tabBars.buttons.element(matching: .button, identifier: "TabItem.world")
        if !worldTab.exists {
            // identifierで見つからない場合は、ラベルで探す
            let worldTabByLabel = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'World' OR label CONTAINS[c] 'world'")).element
            XCTAssertTrue(worldTabByLabel.waitForExistence(timeout: 5), "Worldタブが見つかりません")
            worldTabByLabel.tap()
        } else {
            worldTab.tap()
        }

        // FloatingButton（新規作成ボタン）が表示されるまで待機
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus' OR label CONTAINS '+'")).firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "追加ボタンが見つかりません")
        addButton.tap()

        // WorldEditViewのシートが表示されるまで待機
        let titleTextField = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] 'Unregistered' OR placeholderValue CONTAINS[c] '未登録'")).firstMatch
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 5), "タイトル入力フィールドが見つかりません")

        // タイトルを入力
        let testWorldName = "テストWorld \(Date().timeIntervalSince1970)"
        titleTextField.tap()
        titleTextField.typeText(testWorldName)

        // キーボードを閉じる
        if app.buttons["keyboard.chevron.compact.down"].exists {
            app.buttons["keyboard.chevron.compact.down"].tap()
        } else {
            // キーボードを閉じるボタンが見つからない場合は、他の場所をタップ
            app.staticTexts["Title"].tap()
        }

        // Seed選択画面に遷移
        let seedCell = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Seed'")).firstMatch
        XCTAssertTrue(seedCell.waitForExistence(timeout: 3), "Seedセルが見つかりません")
        seedCell.tap()

        // Seed選択画面で最初のSeedを選択
        sleep(1) // 画面遷移を待つ

        // SeedEditViewで最初のSeedをタップ（実装により異なる可能性があるため、調整が必要）
        // ここでは戻るボタンをタップして、デフォルトのSeedで登録を進める
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        }

        // 登録ボタンをタップ
        let registerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '登録' OR label CONTAINS[c] 'Register'")).firstMatch
        XCTAssertTrue(registerButton.waitForExistence(timeout: 3), "登録ボタンが見つかりません")

        // ボタンが有効になるまで待機
        sleep(1)

        if registerButton.isEnabled {
            registerButton.tap()

            // 登録完了後、シートが閉じることを確認
            let sheetDismissed = NSPredicate(format: "exists == false")
            let expectation = XCTNSPredicateExpectation(predicate: sheetDismissed, object: titleTextField)
            let result = XCTWaiter().wait(for: [expectation], timeout: 5)
            XCTAssertEqual(result, .completed, "シートが閉じませんでした")

            // WorldListに新しいWorldが表示されることを確認
            let newWorldCell = app.staticTexts[testWorldName]
            XCTAssertTrue(newWorldCell.waitForExistence(timeout: 5), "新しいWorldがリストに表示されませんでした")
        } else {
            XCTFail("登録ボタンが有効になっていません。入力が不足している可能性があります。")
        }
    }

    /// Worldタブへの遷移テスト
    func testNavigateToWorldTab() throws {
        // スプラッシュ画面が消えるまで待機
        sleep(3)

        // Worldタブが存在することを確認
        let worldTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'World' OR label CONTAINS[c] 'world'")).firstMatch
        XCTAssertTrue(worldTab.waitForExistence(timeout: 5), "Worldタブが見つかりません")

        // Worldタブをタップ
        worldTab.tap()

        // WorldListViewのタイトルが表示されることを確認
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 3), "ナビゲーションバーが見つかりません")
    }

    /// 新規作成ボタンの表示テスト
    func testShowAddWorldButton() throws {
        // スプラッシュ画面が消えるまで待機
        sleep(3)

        // Worldタブに移動
        let worldTab = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'World' OR label CONTAINS[c] 'world'")).firstMatch
        XCTAssertTrue(worldTab.waitForExistence(timeout: 5))
        worldTab.tap()

        // FloatingButton（新規作成ボタン）が表示されることを確認
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'plus' OR label CONTAINS '+'")).firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "追加ボタンが表示されませんでした")
    }
}
