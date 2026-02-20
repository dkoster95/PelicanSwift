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
