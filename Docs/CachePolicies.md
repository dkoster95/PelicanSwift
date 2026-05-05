# Pelican Cache Policies

`CachePolicy` objects define the rules for data validation within the Pelican caching system. Before any data is saved to a `MemoryCache` or `FileCache`, these policies are evaluated to ensure the data is fresh and fits within storage constraints.

## Available Policies

### 1. ExpirationCachePolicy
Validates data based on its age. It uses a flexible `dateOfExpirationBuilder` to calculate whether a record has expired relative to its creation date.

**Usage:**
```swift
// Create a policy where data expires 24 hours after creation
let ttlPolicy = ExpirationCachePolicy { createdAt in
    Calendar.current.date(byAdding: .hour, value: 24, to: createdAt) ?? createdAt
}

// Throws CacheError.expired if Date() > expirationDate
```

### 2. SizeCachePolicy
Ensures the cache does not exceed a specific byte limit. It can be used for both **In-Memory** and **On-Disk** storage.

**Usage for File Cache:**
Calculates total directory size on disk.
```swift
let diskLimitPolicy = SizeCachePolicy(
    maxSize: 50 * 1024 * 1024, // 50 MB
    fileManager: .default
)
```

**Usage for Memory Cache:**
Calculates the sum of all data currently in RAM using `reduce`.
```swift
let memoryLimitPolicy = SizeCachePolicy(
    maxSize: 10 * 1024 * 1024, // 10 MB
    inMemoryRepository: myRepo
)
```

---

## Technical Details

### Error Handling
If a policy fails validation during a `save()` operation, it throws a specific `CacheError`:
- `CacheError.expired`: Thrown when the calculated expiration date has passed.
- `CacheError.sizeLimit`: Thrown when adding the new data would exceed the `maxSize`.

### Custom Logic
The `SizeCachePolicy` is highly extensible. By providing a custom `totalSizeCalculator` closure, you can define exactly how "used space" is measured for your specific repository.

### Performance
The `FileManager` extension included with `SizeCachePolicy` performs deep enumeration to calculate directory sizes accurately, using `.fileSizeKey` pre-fetching for optimized performance.

---

## Integration Example

You can combine these policies when initializing any Pelican cache:

```swift
let myPolicies: [CachePolicy] = [
    ExpirationCachePolicy { $0.addingTimeInterval(3600) }, // 1 hour TTL
    SizeCachePolicy(maxSize: 1_000_000, fileManager: .default) // 1MB limit
]

let cache = FileCache(policies: myPolicies)
```

Would you like to see how to implement a **custom policy** for checking specific data content types?

