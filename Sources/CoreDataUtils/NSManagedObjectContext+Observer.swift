import Foundation
import CoreData


public struct ContextDidSaveNotification {

    let notification: Notification

    public init(note: Notification) {
        guard note.name == .NSManagedObjectContextDidSave else { fatalError() }
        notification = note
    }

    public var insertedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSInsertedObjectsKey)
    }

    public var updatedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSUpdatedObjectsKey)
    }

    public var deletedObjects: AnyIterator<NSManagedObject> {
        return iterator(forKey: NSDeletedObjectsKey)
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }

    fileprivate func iterator(forKey key: String) -> AnyIterator<NSManagedObject> {
        guard let set = (notification as Notification).userInfo?[key] as? NSSet else {
            return AnyIterator { nil }
        }
        var innerIterator = set.makeIterator()
        return AnyIterator { return innerIterator.next() as? NSManagedObject }
    }
}

public struct ContextWillSaveNotification {

    let notification: Notification

    public init(note: Notification) {
        assert(note.name == .NSManagedObjectContextWillSave)
        notification = note
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
}


public struct ObjectsDidChangeNotification {

    init(note: Notification) {
        assert(note.name == .NSManagedObjectContextObjectsDidChange)
        notification = note
    }

    public var insertedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInsertedObjectsKey)
    }

    public var updatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSUpdatedObjectsKey)
    }

    public var deletedObjects: Set<NSManagedObject> {
        return objects(forKey: NSDeletedObjectsKey)
    }

    public var refreshedObjects: Set<NSManagedObject> {
        return objects(forKey: NSRefreshedObjectsKey)
    }

    public var invalidatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInvalidatedObjectsKey)
    }

    public var invalidatedAllObjects: Bool {
        return (notification as Notification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    fileprivate let notification: Notification

    fileprivate func objects(forKey key: String) -> Set<NSManagedObject> {
        return ((notification as Notification).userInfo?[key] as? Set<NSManagedObject>) ?? Set()
    }

}


extension NSManagedObjectContext {

    public func addContextDidSaveNotificationObserver(_ handler: @escaping (ContextDidSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextDidSave, object: self, queue: nil) { note in
            let wrappedNote = ContextDidSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    public func addContextWillSaveNotificationObserver(_ handler: @escaping (ContextWillSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextWillSave, object: self, queue: nil) { note in
            let wrappedNote = ContextWillSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    public func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { note in
            let wrappedNote = ObjectsDidChangeNotification(note: note)
            handler(wrappedNote)
        }
    }
}


