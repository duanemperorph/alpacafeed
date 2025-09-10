import XCTest

final class BasicFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-uiTesting"]
        app.launch()
    }

    func test_appLaunch_showsFeedList() {
        let feedList = app.scrollViews["feed_list"]
        XCTAssertTrue(feedList.waitForExistence(timeout: 5), "Feed list should be visible on launch")
    }

    func test_tapFirstPost_navigatesToCommentsList() {
        let feedList = app.scrollViews["feed_list"]
        XCTAssertTrue(feedList.waitForExistence(timeout: 5))

        // Tap first feed row button
        let firstFeedCellButton = feedList.descendants(matching: .button).firstMatch
        XCTAssertTrue(firstFeedCellButton.exists)
        firstFeedCellButton.tap()

        let commentsList = app.scrollViews["comments_list"]
        XCTAssertTrue(commentsList.waitForExistence(timeout: 5), "Comments list should be visible after tapping a post")
    }

    func test_expandAndCollapse_firstComment_changesVisibleRowCount() {
        // Navigate to comments first
        let feedList = app.scrollViews["feed_list"]
        XCTAssertTrue(feedList.waitForExistence(timeout: 5))
        let firstFeedCellButton = feedList.descendants(matching: .button).firstMatch
        XCTAssertTrue(firstFeedCellButton.exists)
        firstFeedCellButton.tap()

        let commentsList = app.scrollViews["comments_list"]
        XCTAssertTrue(commentsList.waitForExistence(timeout: 5))

        // Count visible comment/post rows by feed_cell_* identifiers
        let rowButtons = commentsList.descendants(matching: .button).matching(NSPredicate(format: "identifier BEGINSWITH 'feed_cell_'"))
        let countBefore = rowButtons.count
        XCTAssertGreaterThan(countBefore, 0)

        // Tap first expand button
        let firstExpand = commentsList.buttons["comment_expand_button"].firstMatch
        XCTAssertTrue(firstExpand.waitForExistence(timeout: 3), "Expand button should exist for comment rows")
        firstExpand.tap()

        // Wait briefly for UI to update
        _ = commentsList.waitForExistence(timeout: 1)
        let countAfterExpand = rowButtons.count
        XCTAssertGreaterThan(countAfterExpand, countBefore, "Expanding should increase visible rows")

        // Collapse again
        firstExpand.tap()
        _ = commentsList.waitForExistence(timeout: 1)
        let countAfterCollapse = rowButtons.count
        XCTAssertEqual(countAfterCollapse, countBefore, "Collapsing should restore original row count")
    }
} 