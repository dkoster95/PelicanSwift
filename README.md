

![](https://github.com/dkoster95/PelicanSwift/blob/master/logo.png)
- **Simple Way to manage your local storage**
- **Persistence Module**
- **Keep local storage simple**
---

Swift Persistence framework.

![](https://github.com/dkoster95/PelicanSwift/blob/master/diagram.png)

Your app usually uses local storage to store tokens, offline data or user preferences.
Pelican is a framework created to handle those requirements by using a repository pattern.
There are 3 repository implementations Keychain, CoreData and UserDefaults.
If you have diferent requirements or wanna use a diferent type of persistence you can create your own repository by extending **PelicanRepository** class!  
The framework also provides a **Keychain Wrapper** in case you dont want to use the repository pattern.

---
```swift
open class PelicanRepository <PersistibleObject: Any> {
    
    open func empty() {}
    
    open var isEmpty: Bool { return fetchAll.isEmpty }
    
    public init() {}
    
    open var fetchAll: [PersistibleObject] {
        return []
    }
    
    open func save(object: PersistibleObject) -> Bool {
        return true
    }
    
    open func update(object: PersistibleObject) -> Bool {
        return true
    }
    
    open func save() -> Bool {
        return true
    }
    
    open func filter(query: (PersistibleObject) -> Bool) -> [PersistibleObject] { return fetchAll.filter { query($0) }
    }
    
    open func delete(object: PersistibleObject) -> Bool {
        return true
    }
    
    open var first: PersistibleObject? {
        return fetchAll.first
    }
}
```
Here you have the Pelican Repository class definition, It was made a class instead of a protocol because it uses a generic type and swift associatedTypes with protocols are not friendly :(.  
Those are all the features a Repository should have: add, removing, empty, and the fetching options.  
if you want your own repository implementation you just need to make your class extend this repository class and then override the methods you want!


## Repositories
- [Keychain Repository](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/KeychainRepository.md)
- [UserDefaults Repository](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/UserDefaultsRepository.md)
- [CoreDataRepository](https://github.com/dkoster95/PelicanSwift/blob/master/Docs/CoreDataRepository.md)

---

## Requirements

- iOS 11.0+ 
- WatchOS 5.0+
- TvOS 12.0+
- MacOS 10.12+
- Xcode 10.2+
- Swift 5+

---

## Installation
	### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Pelican into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "https://github.com/dkoster95/PelicanSwift.git" "1.0"
```

Run `carthage update` to build the framework (you can specify the platform) and then drag the executable `Pelican.framework` into your Xcode project.

### Manually

No Package manager? no problem, you can use Pelican as a git submodule

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

