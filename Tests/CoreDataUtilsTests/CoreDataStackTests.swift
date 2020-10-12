import XCTest
import CoreData
@testable import CoreDataUtils

final class CoreDataStackTests: XCTestCase {

    var sut: CoreDataStack!

    override func setUp() {
        super.setUp()

        let modelURL = Bundle.module.url(forResource: "Sample", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let persistentContainer = NSPersistentContainer(name: "Sample", managedObjectModel: model)
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = NSInMemoryStoreType

        sut = CoreDataStack(persistentContainer)
    }

    // MARK: - Tests

    func test_setup_completionCalled() {
        let setupExpectation = expectation(description: "set up completion called")

        sut.setup {
            setupExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func test_setup_persistentStoreCreated() {
       let setupExpectation = expectation(description: "set up completion called")

        sut.setup {
            setupExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { (_) in
            XCTAssertTrue(self.sut.persistentContainer.persistentStoreCoordinator.persistentStores.count > 0)
        }
    }

    func test_setup_persistentContainerLoadedInMemory() {
        let setupExpectation = expectation(description: "set up completion called")

        sut.setup {
            XCTAssertEqual(self.sut.persistentContainer.persistentStoreDescriptions.first?.type, NSInMemoryStoreType)
            setupExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func test_backgroundContext_concurrencyType() {
        let setupExpectation = expectation(description: "set up completion called")

        sut.setup {
            XCTAssertEqual(self.sut.backgroundContext.concurrencyType, .privateQueueConcurrencyType)
            setupExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func test_mainContext_concurrencyType() {
        let setupExpectation = expectation(description: "set up completion called")

        sut.setup {
            XCTAssertEqual(self.sut.mainContext.concurrencyType, .mainQueueConcurrencyType)
            setupExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    static var allTests = [
        ("test_setup_completionCalled", test_setup_completionCalled),
        ("test_setup_persistentStoreCreated", test_setup_persistentStoreCreated),
        ("test_setup_persistentContainerLoadedInMemory", test_setup_persistentContainerLoadedInMemory),
        ("test_backgroundContext_concurrencyType", test_backgroundContext_concurrencyType),
        ("test_mainContext_concurrencyType", test_mainContext_concurrencyType)
    ]
}
