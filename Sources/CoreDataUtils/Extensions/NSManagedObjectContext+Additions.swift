//
//  NSManagedObjectContext+Additions.swift
//  
//
//  Created by Abdel Ali on 10/12/20.
//

import Foundation
import CoreData

// MARK: - Save/Insert

public extension NSManagedObjectContext {

    func insertObject<A: NSManagedObject>() -> A where A: Manageable {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return entity
    }

    func saveOrRollback() -> Bool {
        do {
            if hasChanges {
                try save()
            }
            return true
        } catch {
            rollback()
            return false
        }
    }

    func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}

// MARK: - Notifications

extension NSManagedObjectContext {

    public func addContextDidSaveNotificationObserver(_ handler: @escaping (ContextDidSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextDidSave, object: self, queue: nil) { n in
            let wrappedNote = ContextDidSaveNotification(notification: n)
            handler(wrappedNote)
        }
    }

    public func addContextWillSaveNotificationObserver(_ handler: @escaping (ContextWillSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextWillSave, object: self, queue: nil) { n in
            let wrappedNote = ContextWillSaveNotification(notification: n)
            handler(wrappedNote)
        }
    }

    public func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { n in
            let wrappedNote = ObjectsDidChangeNotification(notification: n)
            handler(wrappedNote)
        }
    }
}
