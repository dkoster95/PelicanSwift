# FileCache

`FileCache` is a high-performance, persistent caching solution for the **Pelican** library. It uses a hybrid approach: **SwiftData** for fast metadata indexing and the **File System** for efficient large binary data storage.

## Features

- **Hybrid Storage**: Metadata (names, IDs, timestamps) is stored in SQLite via SwiftData, while large data blobs are stored as physical files.
- **Actor-Based**: Built as a Swift `actor` to ensure thread-safety and prevent data races.
- **Policy Enforcement**: Automatically validates data against a collection of `CachePolicy` objects before persistence.
- **Atomic Writes**: Uses atomic file writing and complete file protection for data integrity.

---

## Directory Structure

`FileCache` automatically manages its own folder hierarchy within the system's Caches directory:

- **Root**: `Library/Caches/Pelican/`
- **Database**: `.../Pelican/PelicanCache.sqlite`
- **Binary Data**: `.../Pelican/files/`

---

## Usage

### 1. Initialization

You can initialize `FileCache` using the shared database configuration or by providing your own `ModelContainer`.

```swift
// Option A: Using default shared database
let cache = FileCache(policies: [MyCustomPolicy()])

// Option B: Providing a custom ModelContainer
let container = try ModelContainer(for: FileCacheRecordEntity.self)
let customCache = FileCache(
    fileManager: .default,
    policies: [],
    modelContainer: container
)
```

### 2. Saving Data

When saving, the cache validates policies, creates the necessary directories, indexes the record in the database, and writes the content to disk.

```swift
let data = CacheData(
    content: someData,
    name: "profile_image_01",
    id: UUID(),
    createdAt: Date()
)

do {
    try await cache.save(data)
} catch {
    print("Failed to save: \(error)")
}
```

### 3. Finding Data

Retrieval is performed by name. If found, the metadata is pulled from SwiftData and the binary content is mapped from the file system.

```swift
if let cachedItem = await cache.find("profile_image_01") {
    print("Retrieved: \(cachedItem.name)")
}
```

### 4. Removing Data

You can remove specific items or clear the entire cache (database and files).

```swift
// Remove a specific record
try await cache.remove(data)

// Clear the entire cache
try await cache.removeAll()
```

---

## Protocol Architecture

To bypass complex Swift compiler limitations with generic compositions, `FileCache` utilizes a refined protocol pattern:

```swift
protocol FileCacheRepository: AsyncInsertableRepository,
                              AsyncPredicableReadableRepository,
                              AsyncDeleteableRepository
where Element == FileCacheRecord,
      PersistibleElement == FileCacheRecordEntity,
      ResultElement == FileCacheRecord {}
```



