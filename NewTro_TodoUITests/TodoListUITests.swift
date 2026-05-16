import XCTest

final class TodoListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting", "-ResetRealm"]
        app.launch()
        waitForMainScreen()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Setup Helpers

    /// -UITesting 플래그로 스플래시/웰컴 스킵 → 메인 화면 대기
    private func waitForMainScreen() {
        let addBtn = app.buttons["addTodoButton"]
        let appeared = addBtn.waitForExistence(timeout: 10)
        if !appeared {
            XCTFail("메인 화면 진입 실패 - addTodoButton 없음")
        }
    }

    /// Todo 1개 추가
    private func addTodo(_ text: String) {
        app.buttons["addTodoButton"].tap()
        sleep(1)

        let field = app.textFields["todoTextField"]
        XCTAssertTrue(field.waitForExistence(timeout: 3), "todoTextField 없음")
        field.tap()
        field.typeText(text)

        let saveBtn = app.buttons["saveButton"]
        XCTAssertTrue(saveBtn.waitForExistence(timeout: 3), "saveButton 없음")
        saveBtn.tap()
        sleep(1)
    }

    /// 현재 화면에서 첫 번째 Todo의 id 반환
    private func firstTodoId() -> String? {
        for btn in app.buttons.allElementsBoundByIndex {
            if btn.identifier.hasPrefix("checkbox_") {
                return String(btn.identifier.dropFirst("checkbox_".count))
            }
        }
        return nil
    }

    // MARK: - Test 01: Todo 5개 추가

    func test_01_addFiveTodos() throws {
        let titles = ["운동하기", "책 읽기", "코드 리뷰", "장보기", "일기 쓰기"]
        for title in titles { addTodo(title) }

        var count = 0
        for btn in app.buttons.allElementsBoundByIndex {
            if btn.identifier.hasPrefix("checkbox_") { count += 1 }
        }
        XCTAssertEqual(count, 5, "Todo 5개가 리스트에 표시되어야 함. 실제 개수: \(count)")
    }

    // MARK: - Test 02: 완료 체크박스 토글

    func test_02_checkboxToggle() throws {
        addTodo("체크 테스트")

        guard let id = firstTodoId() else { XCTFail("Todo 없음"); return }
        let checkbox = app.buttons["checkbox_\(id)"]

        // 완료 체크
        XCTAssertTrue(checkbox.waitForExistence(timeout: 3))
        checkbox.tap()
        sleep(1)

        // 완료 후에도 체크박스가 존재해야 함 (완료 Todo는 하단으로 이동)
        XCTAssertTrue(app.buttons["checkbox_\(id)"].waitForExistence(timeout: 3),
                      "완료 체크 후 체크박스가 사라짐")

        // 완료 해제
        app.buttons["checkbox_\(id)"].tap()
        sleep(1)

        XCTAssertTrue(app.buttons["checkbox_\(id)"].waitForExistence(timeout: 3),
                      "완료 해제 후 체크박스가 사라짐")
    }

    // MARK: - Test 04: ... 버튼 → 액션 메뉴 Sheet

    func test_04_actionMenuButton_opensSheet() throws {
        addTodo("액션 메뉴 테스트")

        guard let id = firstTodoId() else { XCTFail("Todo 없음"); return }

        let actionBtn = app.buttons["action_\(id)"]
        XCTAssertTrue(actionBtn.waitForExistence(timeout: 3), "action 버튼 없음")
        actionBtn.tap()
        sleep(1)

        // 액션 메뉴 sheet 확인
        XCTAssertTrue(
            app.staticTexts["삭제"].waitForExistence(timeout: 3),
            "액션 메뉴 sheet가 열리지 않음"
        )

        // 취소로 닫기
        let cancelBtn = app.buttons.matching(NSPredicate(format: "label == '취소'")).firstMatch
        XCTAssertTrue(cancelBtn.waitForExistence(timeout: 2), "취소 버튼 없음")
        cancelBtn.tap()
        sleep(1)
    }

    // MARK: - Test 05: ... 닫은 후 다른 액션 오작동 없음

    func test_05_actionMenuClose_noGhostTap() throws {
        addTodo("오작동 방지 테스트")

        guard let id = firstTodoId() else { XCTFail("Todo 없음"); return }

        // ... 탭
        app.buttons["action_\(id)"].tap()
        sleep(1)
        XCTAssertTrue(app.staticTexts["삭제"].waitForExistence(timeout: 3), "액션 메뉴 열리지 않음")

        // 취소로 닫기
        app.buttons.matching(NSPredicate(format: "label == '취소'")).firstMatch.tap()
        sleep(1)

        // 체크박스가 사라지면 안 됨 (완료 처리되면 안 됨)
        XCTAssertTrue(
            app.buttons["checkbox_\(id)"].exists,
            "[BUG] 액션 메뉴 닫힌 후 Todo가 완료 처리됨"
        )
    }

    // MARK: - Test 06: 텍스트 탭 → 편집 Sheet

    func test_06_tapText_opensEditSheet() throws {
        addTodo("편집 테스트")
        sleep(1)

        let todoText = app.staticTexts["편집 테스트"]
        XCTAssertTrue(todoText.waitForExistence(timeout: 3), "Todo 텍스트 없음")
        todoText.tap()
        sleep(1)

        // 편집 sheet 확인
        XCTAssertTrue(
            app.staticTexts["할 일 수정"].waitForExistence(timeout: 3),
            "편집 sheet가 열리지 않음"
        )

        // 취소
        app.buttons.matching(NSPredicate(format: "label == '취소'")).firstMatch.tap()
        sleep(1)
    }
}
