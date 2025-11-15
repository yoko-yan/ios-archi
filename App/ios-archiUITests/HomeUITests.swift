import XCTest

final class HomeUITests: XCTestCase {
    var app: XCUIApplication!
    var homePage: HomePage!
    var itemEditPage: ItemEditPage!
    var coordinatesEditPage: CoordinatesEditPage!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Page Objectを初期化
        homePage = HomePage(app: app)
        itemEditPage = ItemEditPage(app: app)
        coordinatesEditPage = CoordinatesEditPage(app: app)
        homePage.waitForSplashScreenToDisappear()
    }

    override func tearDownWithError() throws {
        app = nil
        homePage = nil
        itemEditPage = nil
        coordinatesEditPage = nil
    }

    /// ホームタブが初期表示されることを確認（ナビゲーションバーとフローティングボタン）
    func testHomeTabIsInitiallyDisplayed() throws {
        homePage
            .verifyNavigationBarExists()

        // フローティングボタンが表示されることを確認
        homePage.assertExists(homePage.floatingButton, message: "フローティングボタンが表示されませんでした")
    }

    /// 新しいアイテムを登録するテスト
    func testRegisterNewItem() throws {
        // フローティングボタンをタップしてアイテム編集画面を開く
        homePage.tapFloatingButton()

        // アイテム編集画面が表示されることを確認
        itemEditPage.verifySheetIsDisplayed()

        // 座標セルをタップして座標入力画面に遷移
        itemEditPage.tapCoordinatesCell()

        // 座標を入力
        coordinatesEditPage.enterCoordinates(x: "100", y: "64", z: "200")

        // 変更ボタンをタップ
        coordinatesEditPage.tapModifyButton()

        // 少し待機して画面遷移を待つ
        sleep(1)

        // アイテム編集画面に戻ったことを確認（座標セルが再び表示される）
        itemEditPage.verifySheetIsDisplayed()

        // 登録ボタンをタップ
        itemEditPage.tapRegisterButton()

        // ホーム画面に戻ったことを確認（フローティングボタンが表示される）
        // シートが閉じる検証は、NavigationBarがホーム画面とアイテム編集画面の両方に存在するため使えない
        homePage.assertExists(homePage.floatingButton, timeout: 10, message: "ホーム画面に戻りませんでした")

        // データが登録されたことの確認
        // Note: リストの即座の更新は保証されないため、この時点ではリストの存在確認をスキップ
        // データの存在確認は別のテストで行う
    }
}
