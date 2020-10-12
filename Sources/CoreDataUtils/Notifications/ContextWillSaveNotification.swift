//
//  ContextWillSaveNotification.swift
//
//
//  Created by Abdel Ali on 10/12/20.
//

import CoreData

public struct ContextWillSaveNotification {

    fileprivate let notification: Notification

    public init(notification: Notification) {
        assert(notification.name == .NSManagedObjectContextWillSave)
        self.notification = notification
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
}
