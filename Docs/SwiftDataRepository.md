
## SwiftData Repository

With Apple's new SwiftData framework released a new repository implementation appeared. so we created SwiftDataRepository!


### We are not here to explain all details about Swift Data, but we will focus on following:

- PersistentModel is not Sendable nor Thread safe
- ModelContext is not Sendable nor Thread safe

```swift

// MARK: Not Thread safe!
@Model
final class TestSwiftDataEntity {
    @Attribute(.unique) var uuid: UUID
    var name: String
    var createdAt: Date
    
    init(uuid: UUID,
         name: String,
         createdAt: Date) {
        self.uuid = uuid
        self.name = name
        self.createdAt = createdAt
    }
    
}

// MARK: Not Thread Safe!
let context = ModelContext(container: .....)
modelContext.insert(...)
```

we still have the same issue of concurrency safety with Swift Data therefore the implementation for this repo was by using an actor and a protocol to convert between SwiftData Models and DTO to securely use SwiftData:

```swift

public protocol PersistenModelConvertible: Equatable, Sendable {
    associatedtype SwiftDataEntity: PersistentModel
    init(from: SwiftDataEntity)
    func asEntity() -> SwiftDataEntity
    func merge(into: SwiftDataEntity)
    var identifiablePredicate: Predicate<SwiftDataEntity> { get }
}

@ModelActor
public actor SwiftDataRepository<Element: PersistenModelConvertible> .....
```

so how do we actually use it ?

We have this Entity here (not a SwiftData Model)
```swift
struct TestEntityV2: Equatable {
    let id: UUID
    let name: String
    let createdAt: Date
}
```

and we are gonna use this SwiftData model to save it:
```swift
@Model
final class TestSwiftDataEntity {
    @Attribute(.unique) var uuid: UUID
    var name: String
    var createdAt: Date
    
    init(uuid: UUID,
         name: String,
         createdAt: Date) {
        self.uuid = uuid
        self.name = name
        self.createdAt = createdAt
    }
    
}
```

###how do we go from one place to the other ?

```swift
extension TestEntityV2: PersistenModelConvertible {
    var identifiablePredicate: Predicate<TestSwiftDataEntity> {
        let uuid = self.id
        return #Predicate { element in
            element.uuid == uuid
        }
    }
    
    init(from: TestSwiftDataEntity) {
        id = from.uuid
        name = from.name
        createdAt = from.createdAt
    }
    
    func asEntity() -> TestSwiftDataEntity {
        TestSwiftDataEntity(uuid: id, name: name, createdAt: createdAt)
    }
    
    func merge(into: TestSwiftDataEntity) {
        into.name = name
    }
    
    typealias SwiftDataEntity = TestSwiftDataEntity
    
    
}
```

This way we keep independence between our business entities and our Database config (in this case SwiftData)

now that we have our Entity configured we just use the Repository:
```swift

let test = TestEntityV2(id: UUID(), name: "some name", createdAt: Date())

Task {
    // Creation of repo must occur inside the task it will be accessed to be thread safe
    let repository = SwiftDataRepository<TestEntityV2>(modelContainer: .....)
    let elementSaved = try await repository.add(test)
    
    let elements = await repository.find()
}
```
