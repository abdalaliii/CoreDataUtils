//
//  Manageable.swift
//  
//
//  Created by Abdel Ali on 10/12/20.
//

import Foundation
import CoreData

public protocol Manageable: class {
    static var entityName: String { get }
}

public extension Manageable where Self: NSManagedObject {

    static var entityName: String {
        return entity().name!
    }

    static func fetch(
        in context: NSManagedObjectContext,
        configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }
    ) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }

    static func count(
        in context: NSManagedObjectContext,
        configure: (NSFetchRequest<Self>) -> () = { _ in }
    ) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return try! context.count(for: request)
    }
    
    static func findOrCreate(
        in context: NSManagedObjectContext,
        matching predicate: NSPredicate,
        configure: (Self) -> ()
    ) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        return object
    }

    static func findOrFetch(
        in context: NSManagedObjectContext,
        matching predicate: NSPredicate
    ) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        return object
    }

    static func fetchSingleObject(
        in context: NSManagedObjectContext,
        configure: (NSFetchRequest<Self>) -> ()
    ) -> Self? {
        let result = fetch(in: context) { request in
            configure(request)
            request.fetchLimit = 2
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }

    func refresh(_ mergeChanges: Bool = true) {
        managedObjectContext?.refresh(self, mergeChanges: mergeChanges)
    }

    func changedValue(forKey key: String) -> Any? {
        return changedValues()[key]
    }

    func committedValue(forKey key: String) -> Any? {
        return committedValues(forKeys: [key])[key]
    }

    private static func materializedObject(
        in context: NSManagedObjectContext,
        matching predicate: NSPredicate
    ) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, predicate.evaluate(with: result) else { continue }
            return result
        }
        return nil
    }
}
