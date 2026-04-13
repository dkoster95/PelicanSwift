//
//  SwiftDataRepository.swift
//  Pelican
//
//  Created by Daniel Koster on 2/10/26.
//
import PelicanProtocols
import SwiftData
import Foundation

@ModelActor
public actor SwiftDataRepository<Element: PersistenModelConvertible>: AsyncInsertableRepository {
    
    public func add(element: Element) async throws -> Element {
        modelContext.insert(element.asEntity())
        try modelContext.save()
        return element
    }
    
    public typealias Element = Element
}

extension SwiftDataRepository: AsyncReadableRepository {
    public func find(query: (@Sendable (Element) -> Bool)?) async -> [Element] {
        let descriptor = FetchDescriptor<Element.SwiftDataEntity>()
        guard let results = try? modelContext.fetch(descriptor) else { return [] }
        let mappedResults = results.map { Element.init(from: $0) }
        if let query = query {
            return mappedResults.filter(query)
        }
        return mappedResults
    }
    
    public func contains(element: Element) async -> Bool {
        return await !find { elementFetched in
            return elementFetched == element
        }.isEmpty
    }
}

extension SwiftDataRepository: AsyncUpdatableRepository {
    public func update(element: Element) async throws -> Element {
        let descriptor = FetchDescriptor<Element.SwiftDataEntity>(predicate: element.identifiablePredicate)
        guard let results = try? modelContext.fetch(descriptor),
              let elementFound = results.first else { throw RepositoryError.nonExistingData }
        element.merge(into: elementFound)
        try modelContext.save()
        return element
    }
}

extension SwiftDataRepository: AsyncDeleteableRepository {
    
    public func delete(element: Element) async throws {
        let descriptor = FetchDescriptor<Element.SwiftDataEntity>(predicate: element.identifiablePredicate)
        guard let results = try? modelContext.fetch(descriptor),
              let elementFound = results.first else { throw RepositoryError.nonExistingData }
        modelContext.delete(elementFound)
        try modelContext.save()
    }
    
    public func deleteAll() async throws {
        try modelContext.delete(model: Element.SwiftDataEntity.self)
        try modelContext.save()
    }
}

extension SwiftDataRepository: AsyncBatchRepository {
    public func add(elements: [Element]) async throws {
        let models = elements.map { $0.asEntity() }
        for model in models {
            modelContext.insert(model)
        }
        try modelContext.save()
    }
    
}

extension SwiftDataRepository: AsyncPredicableReadableRepository {
    public typealias PersistibleElement = Element.SwiftDataEntity
    public typealias ResultElement = Element
    
    public func find(predicate: Predicate<Element.SwiftDataEntity>, sortBy: SortDescriptor<Element.SwiftDataEntity>?) async -> [Element] {
        var descriptor = FetchDescriptor<Element.SwiftDataEntity>.init(predicate: predicate)
        if let sortBy = sortBy {
            descriptor.sortBy = [sortBy]
        }
        guard let results = try? modelContext.fetch(descriptor) else { return [] }
        let mappedResults = results.map { Element(from: $0) }
        return mappedResults
    }
}
