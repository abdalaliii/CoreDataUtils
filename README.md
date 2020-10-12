# CoreDataUtils

CoreDataUtils is a framework consisting of several extensions and helpers to take the hassle out of common CoreData tasks.

# Usage

To use CoreDataUtils, first add `import CoreDataUtils"` to any classes that will need to use it. CoreDataUtils can be broken down into three basic areas of functionality, as follows.

## CoreDataStack

`CoreDataStack` is a class for building and managing Core Data stacks, including the model, managed object context, and persistent store coordinator.

##### Create a new stack

```swift
myStack = CoreDataManager(dataModel: "model-name")
myStack.setup() {
    //...
}
```

##### Create a background (private queue) context

```swift
// This context is a child of the disk writer context and a sibling of the main thread context. 
// Saving it will automatically merge changes into the main context.
let *backgroundContext = myStack.backgroundContext;
```

## Manageable

`Manageable` is a protocol on `NSManagedObject` which provides partial implementation for helpful methods. 

##### Fetch all objects

```swift
static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self]
```

##### Get the count of objects

```swift
static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) -> Int 
```

##### Retrieve or create an instance for a new object

```swift
static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self
```

If a match isn't found, a new instance will be created and initialized with the provided attribute configuration.

## NSManagedObjectObserver

`NSManagedObjectObserver` class registers for the objects-did-change notification (.NSManagedObjectContextObjectsDidChange). 
Whenever the notification is sent, it traverses the user info of the notification to check whether or not a deletion of the observed object has occurred

```swift
let observer = ManagedObjectObserver(object: mood) { [weak self] type in
    guard type == .delete else { return }
    //...
}
```

# Installation

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/abdalaliii/CoreDataUtils.git")
]
```

# Developer Notes

This whole project is a work in progress, a learning exercise and has been released "early" so that it can be built and collaborated on with valuable feedback.

# License

**CoreDataUtils** is available under the MIT license. See the LICENSE file for more info.
