import XCTest

@MainActor
final class ItemEditUITests: XCTestCase {
    private var app: XCUIApplication!
    private var homePage: HomePage!
    private var itemEditPage: ItemEditPage!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        homePage = HomePage(app: app)
        itemEditPage = ItemEditPage(app: app)
        homePage.waitForSplashScreenToDisappear()
    }

    override func tearDownWithError() throws {
        app = nil
        homePage = nil
        itemEditPage = nil
    }

    /// アイテム編集画面の各UI要素が表示されることを確認
    func testItemEditScreenElementsAreDisplayed() throws {
        // フローティングボタンをタップしてアイテム編集画面を開く
        homePage.tapFloatingButton()

        // アイテム編集画面が表示されることを確認
        itemEditPage.verifySheetIsDisplayed()

        // 各UI要素の存在を確認
        itemEditPage.assertExists(itemEditPage.closeButton, message: "閉じるボタンが表示されませんでした")
        itemEditPage.assertExists(itemEditPage.photoRegistrationButton, message: "写真を登録ボタンが表示されませんでした")
        itemEditPage.assertExists(itemEditPage.cameraButton, message: "カメラボタンが表示されませんでした")
        itemEditPage.assertExists(itemEditPage.photoPickerButton, message: "写真選択ボタンが表示されませんでした")
        itemEditPage.assertExists(itemEditPage.coordinatesCell, message: "座標セルが表示されませんでした")
        itemEditPage.assertExists(itemEditPage.worldCell, message: "ワールドセルが表示されませんでした")
        itemEditPage.assertExists(itemEditPage.registerButton, message: "登録ボタンが表示されませんでした")
    }

    /// 閉じるボタンでアイテム編集シートが閉じることを確認
    func testCloseButtonDismissesItemEditSheet() throws {
        // フローティングボタンをタップしてアイテム編集画面を開く
        homePage.tapFloatingButton()

        // アイテム編集画面が表示されることを確認
        itemEditPage.verifySheetIsDisplayed()

        // 閉じるボタンをタップ
        itemEditPage.tapCloseButton()

        // ホーム画面に戻ったことを確認
        homePage.assertExists(homePage.floatingButton, timeout: 5, message: "ホーム画面に戻りませんでした")
    }

    /// ワールド選択画面への遷移を確認
    func testNavigateToWorldSelectionScreen() throws {
        // フローティングボタンをタップしてアイテム編集画面を開く
        homePage.tapFloatingButton()

        // アイテム編集画面が表示されることを確認
        itemEditPage.verifySheetIsDisplayed()

        // ワールドセルをタップ
        itemEditPage.assertExists(itemEditPage.worldCell, message: "ワールドセルが見つかりません").tap()

        // ワールド選択画面が表示されることを確認
        let worldSelectionTitle = app.staticTexts["ワールドを選択する"]
        XCTAssertTrue(worldSelectionTitle.waitForExistence(timeout: 5), "ワールド選択画面が表示されませんでした")

        // ワールドを登録するボタンが表示されることを確認
        let registerWorldButton = app.buttons["ワールドを登録する"]
        XCTAssertTrue(registerWorldButton.exists, "ワールドを登録するボタンが表示されませんでした")
    }
}
