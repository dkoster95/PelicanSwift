//
//  SwiftDataEntity.swift
//  Pelican
//
//  Created by Daniel Koster on 2/10/26.
//
import SwiftData
import Foundation

public protocol PersistenModelConvertible: Equatable, Sendable {
    associatedtype SwiftDataEntity: PersistentModel
    init(from: SwiftDataEntity)
    func asEntity() -> SwiftDataEntity
    func merge(into: SwiftDataEntity)
    var identifiablePredicate: Predicate<SwiftDataEntity> { get }
}
