# MemoryCache

`MemoryCache` is a fast, volatile caching implementation for the **Pelican** library. It stores data directly in RAM using an `InMemoryRepository`, making it ideal for temporary storage or as the first layer in a multi-tier cache system.

## Features

- **In-Memory Storage**: Extreme performance for frequently accessed data.
- **Actor-Isolated**: Built as a Swift `actor` to ensure thread-safe access to the underlying repository.
- **Policy Validation**: Validates all incoming data against `CachePolicy` rules (e.g., size limits, expiration) before storage.
- **Protocol Oriented**: Fully conforms to the `Cache` protocol for easy swapping or chaining.

---

## Usage

### 1. Initialization

To initialize `MemoryCache`, you need an `InMemoryRepository` and an optional array of policies.

```swift
import Pelican
import PelicanProtocols

// Setup repository and policies
let repository = InMemoryRepository<CacheData>()
let policies: [CachePolicy] = [MaxItemCountPolicy(limit: 100)]

// Initialize the cache
let memoryCache = MemoryCache(
    policies: policies,
    repository: repository
)
```

### 2. Saving Data

Data is saved to the internal repository only after all policies have successfully validated it.

```swift
let item = CacheData(name: "session_token", content: tokenData)

do {
    try await memoryCache.save(item)
} catch {
    print("Policy validation failed: \(error)")
}
```

### 3. Finding Data

Retrieval is performed using a synchronous query within the actor's asynchronous `find` method.

```swift
if let data = await memoryCache.find("session_token") {
    print("Found token in memory!")
}
```

### 4. Clearing the Cache

You can remove specific items or purge the entire memory store instantly.

```swift
// Remove single item
try await memoryCache.remove(item)

// Clear everything
try await memoryCache.removeAll()
```

---

## Technical Details

### Thread Safety
`MemoryCache` is a Swift `actor`, meaning it manages its own serial executor. You don't need to use locks or semaphores when accessing the cache from multiple threads; simply use the `await` keyword.

### Performance
Because this cache is backed by an `InMemoryRepository`, operations are near-instantaneous (O(1) for saving, O(n) for finding by name depending on the repository implementation). However, all data is lost when the app process is terminated.

## Requirements

- **Swift 5.9+**
- **PelicanProtocols** dependency
- **Foundation**

