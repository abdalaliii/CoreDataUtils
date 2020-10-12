//
//  CoreDataStack.swift
//
//
//  Created by Abdel Ali on 10/12/20.
//

import Foundation
import CoreData

public class CoreDataStack {

    public let persistentContainer: NSPersistentContainer

    public lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return context
    }()

    public lazy var mainContext: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true

        return context
    }()

    public init(dataModel: String, storeType: String = NSSQLiteStoreType) {
        self.persistentContainer = NSPersistentContainer(name: dataModel)
        let description = self.persistentContainer.persistentStoreDescriptions.first
        description?.type = storeType
    }

    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    public func setup(completion: (() -> Void)?) {
        self.persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("was unable to load store \(error!)")
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }
}
