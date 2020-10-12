//
//  NSManagedObjectObserver.swift
//
//
//  Created by Abdel Ali on 10/12/20.
//

import Foundation
import CoreData

final public class NSManagedObjectObserver {

    enum ChangeType {
        case delete
        case update
    }

    fileprivate var token: NSObjectProtocol!

    init?(object: NSManagedObject, changeHandler: @escaping (ChangeType) -> ()) {
        guard let moc = object.managedObjectContext else { return nil }
        token = moc.addObjectsDidChangeNotificationObserver { [weak self] notification in
            guard let changeType = self?.changeType(of: object, in: notification) else { return }
            changeHandler(changeType)
        }
    }

    deinit {
        if let t = token {
            NotificationCenter.default.removeObserver(t)
        }
    }

    fileprivate func changeType(
        of object: NSManagedObject,
        in notification: ObjectsDidChangeNotification
    ) -> ChangeType? {
        let deleted = notification.deletedObjects.union(notification.invalidatedObjects)
        if notification.invalidatedAllObjects || deleted.contains(object) {
            return .delete
        }
        let updated = notification.updatedObjects.union(notification.refreshedObjects)
        if updated.contains(object) {
            return .update
        }
        return nil
    }
}

