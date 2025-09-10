import XCTest
@testable import AlpacaList

final class CommentsListViewModelTests: XCTestCase {
    private func makeTree() -> FeedItem {
        // post
        // ├─ c1
        // │  ├─ c1a
        // │  └─ c1b
        // │     └─ c1b1
        // └─ c2
        let c1b1 = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1b1", indention: 2, children: [])
        let c1b = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1b", indention: 1, children: [c1b1])
        let c1a = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1a", indention: 1, children: [])
        let c1 = FeedItem.createComment(id: UUID(), username: "u", date: Date(), body: "c1", indention: 0, children: [c1a, c1b])
        let c2 = FeedItem.createComment(id: UUID(), username: "v", date: Date(), body: "c2", indention: 0, children: [])
        let post = FeedItem.createPost(id: UUID(), username: "p", date: Date(), title: "t", body: "b", thumbnail: nil, children: [c1, c2])
        return post
    }

    func test_initialVisibleComments_showsOnlyTopLevel() {
        let post = makeTree()
        let sut = CommentsListViewModel(post: post)
        XCTAssertEqual(sut.visibleComments.count, 2)
        let ids = sut.visibleComments.map { $0.id }
        XCTAssertEqual(Set(ids), Set(post.children.map { $0.id }))
    }

    func test_toggleExpanded_revealsDescendantsDepthFirst() {
        let post = makeTree()
        let sut = CommentsListViewModel(post: post)
        let c1Id = post.children[0].id
        sut.toggleExpanded(id: c1Id)
        XCTAssertEqual(sut.visibleComments.map { $0.feedItem.body ?? "" }, ["c1", "c1a", "c1b", "c2"])
        let c1bId = post.children[0].children[1].id
        sut.toggleExpanded(id: c1bId)
        XCTAssertEqual(sut.visibleComments.map { $0.feedItem.body ?? "" }, ["c1", "c1a", "c1b", "c1b1", "c2"])
    }

    func test_toggleCollapse_hidesPreviouslyRevealedChildren() {
        let post = makeTree()
        let sut = CommentsListViewModel(post: post)
        let c1Id = post.children[0].id
        let c1bId = post.children[0].children[1].id
        sut.toggleExpanded(id: c1Id)
        sut.toggleExpanded(id: c1bId)
        XCTAssertTrue(sut.visibleComments.contains { $0.feedItem.body == "c1b1" })
        sut.toggleExpanded(id: c1Id)
        XCTAssertEqual(sut.visibleComments.map { $0.feedItem.body ?? "" }, ["c1", "c2"])
        XCTAssertFalse(sut.isExpanded(id: c1Id))
    }

    func test_postWithComments_includesPostAtIndexZero() {
        let post = makeTree()
        let sut = CommentsListViewModel(post: post)
        let list = sut.postWithComments
        XCTAssertEqual(list.first?.id, sut.postViewModel.id)
        XCTAssertEqual(list.count, 1 + sut.visibleComments.count)
    }
} 