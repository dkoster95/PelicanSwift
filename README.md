

![](https://github.com/dkoster95/PelicanSwift/blob/master/logo.png)
- **Simple Way to manage your local storage**
- **Persistence Module**
- **Keep local storage simple**
- **Storage Pluggable**
---

Swift Persistence framework.

![](https://github.com/dkoster95/PelicanSwift/blob/master/diagram.png)

Your app usually uses local storage to store tokens, offline data or user preferences.
Pelican is a framework created to handle those requirements by using a repository pattern.
There are 3 repository implementations Keychain, CoreData and UserDefaults.
If you have diferent requirements or wanna use a diferent type of persistence you can create your own repository by implementing **Repository** protocol!  
The framework also provides a **Keychain Store** in case you dont want to use the repository pattern.

# Scope
---
## Expected Use ?

So when you want to use a module you are trying to solve a problem and each module has it benefits and limitations, Its super important to understand the scope of the framework to prevent errors from happening.

Here is a list of what features you expect out of Pelican
- **Keychain store to be used**
- **UserDefaults store to be used**
- **Generic Repository protocol defined**
- **Portability: MacoS, iOS, WatchOS and TVOS compatible** 
- **Swift Package Manager Integration**
- **Entities: Definition and Configuration independence (From NSManagedObject)**
- **Independence from Repository to Context Configuration**
- **Perform Sync and Async Transactions**
- **Core Data repository implementation**
- **In Memory Repository Implementation**
- **Integration with Codable & Equatable**
- **Integration with Combine**
- **Integration with Swift Concurrency**
- **Package responsibilites split, Protocols, Repositories and Keychain libraries**
---
## What not included ?

- **Parameter checks (inejections,etc)**
- **BufferOverflows check**
- **Context Configuration not included, must be injected**
- **Data Encryption not included**
- **Batch Transactions not included in CoreData Repository**
- **NSPredicate not supported by Repository as of now**

---
## When to expect a change ?

- **New Repository implementation**
- **New Repository Operation**
- **Keychain update**

---

# Why use a persistence module ?
---
As a software architect, developer, engineer or however you wanna call yourself you have certain responsibilities when it comes to the code, its not just about writing code and unit tests without making sense.
You NEED to think about some concepts or pillars in software engineering like Maintainability, Testability, Reliability, Scalability, Security, performance, traceability and the hability to monitor changes and behavior in your code.
Software is gonna evolve, change and be maintained so you gotta think about this when you design solutions, it should be "easier to maintain". what does it mean ? if you gotta implement a change, how many places or modules are you gonna impact ? the lowest possible. If you detect a bug, how easy is to locate the origin the bug ? when should you release some specific part of your code and when shouldnt you ?
Imagine fixing a car, do you remove every single part of the car always ? not really you remove the affected part and software is not different.
if you have a bug in your Networking module should you change you persistence module ? NO!
How easy is this module/pattern/class to teach to a new member of the team ?
This kind of questions is what a software designer make to determine the maintainability of the system. Independence, Coupling and Cohesion are key concepts here.
So when we ask why a persistence module, those concepts are basically the answer.
- Our system should never depend on a Persistence implementation.
- Our entities should never be tied to a Persistence framework
- We should be careful when handling concurrency.
- Core Data may eventually be replace by a new Apple framework therefore we need to have independence from it.
- We want to be able to test each Persistence operation Independently, compliant to F.I.R.S.T.
- We want to have the configuration separated from the implementation.
- We want to run diferent sets of tests according to the Persistence, like Integration tests with InMemory repositories or Security automated tests to look for vulnerabilities in our repositories.
- Follow SOLID principles and Cohesion and Copling Component Principles like:

**SRP principle**: Having one responsibility and one reason to change (storing data) makes it easier to maintain, develop, scale and monitor.
**OCP principle**: Pluggable architecture makes the app using it change-friendly by injecting repositories and stores rather than coupling to a concrete implementation.
**DIP Principle**: Storage frameworks are low-level frameworks and our apps should be independent from frameworks, database engines or any external actor, our business entities should not depend on some storage framework to work, instead we should have a separate configuration of the entity so we can integrate it with the framework we are using.
**low coupling**: Core Data is an old objc framework that is outdated if you compare it with other ORM's so, it makes sense that Apple could launch a new ORM soon, or a new Keychain Implentation, you dont want your app to be coupled to any of this when that happens.
---
```swift
public protocol Repository {
    associatedtype Element: Equatable
    func add(element: Element) throws -> Element
    func update(element: Element) throws -> Element
    func delete(element: Element) throws
    func filter(query: (Element) -> Bool) -> [Element]
    func first(where: @escaping (Element) -> Bool) -> Element?
    func contains(condition: (Element) -> Bool) -> Bool
    func contains(element: Element) -> Bool
    var isEmpty: Bool { get }
    var getAll: [Element] { get }
    func deleteAll() throws
}
```
Here you have the Repository protocol definition, yeah I know generic protocols are not easy to handle in Swift but there is also an Erasure Type to make it easier to operate.
---
```swift 
public extension Repository {
    func eraseToAnyRepository() -> AnyRepository<Element> {
        return AnyRepository<Element>(storage: self)
    }
}
```
Those are all the features a Repository should have: add, removing, empty, and the fetching options.  
if you want your own repository implementation you just need to make your class implement this repository protocol!

## Transactions & Combine
 - [Sync and Async Transactions](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/Transactions.md)
 - [Transaction Publisher](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/CombineTransactionPublisher.md)
 
## KeyValue Stores
- [Keychain Store](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/KeychainStore.md)
- [UserDefaults Store](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/UserDefaultsStore.md)

## Repositories
- [CoreDataRepository](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/CoreDataRepository.md)

---

## Requirements

- iOS 13.0+ 
- WatchOS 6.0+
- TvOS 13.0+
- MacOS 12.0+
- Xcode 10.2+
- Swift 5+

---

## Installation

### Manually

No Package manager? no problem, you can use Pelican as a git submodule

## Swift Package Manager
Pelican has support for SPM, you just need to go to Xcode in the menu File/Swift Packages/Add package dependency
and you select the version of Pelican.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add Pelican as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/dkoster95/PelicanSwift.git
  ```

- Open the new `PelicanSwift` folder, and drag the `PelicanSwift.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `PelicanSwift.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.


- And that's it!
---

