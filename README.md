

## 🌐 Pelican 🌐
- **Simple Way to manage your local storage**
- **Persistence Module**
- **Keep local storage simple**
---

Swift Persistence framework.

(https://github.com/dkoster95/PelicanSwift/blob/master/pelicandiagram.png)



## Features

- **NetworkRequestFactory protocol**:
	- [Keychain Repository](https://github.com/dkoster95/QuickHatchSwift/blob/master/Docs/GettingStarted.md)
	- [UserDefaults Repository](https://github.com/dkoster95/QuickHatchSwift/blob/master/Docs/CodableExtensions.md)
	- [CoreDataRepository](https://github.com/dkoster95/QuickHatchSwift/blob/master/Docs/ImageExtension.md)

---

## Requirements

- iOS 11.0+ 
- WatchOS 5.0+
- TvOS 12.0+
- MacOS 10.10+
- Xcode 10.2+
- Swift 5+

---

## Installation
	### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate QuickHatch into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
git "https://github.com/dkoster95/PelicanSwift.git" "1.0"
```

### Manually

No Package manager? no problem, you can use QuickHatch as a git submodule

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

