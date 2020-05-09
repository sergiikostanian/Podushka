//
//  DependencyContainer.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

/** 
 This class allows you associate abstractions with concrete implementations
 to do _Dependency Injection_ by resolving registered instances.
 */
final public class DependencyContainer {
    
    /// Registry of implementation instances referenced by abstraction keys.
    private var registry: [ObjectIdentifier: Any] = [:]
    
    /// Associates an abstract `Type` with provided  implementation instance.
    public func register<Type>(_ registrationBlock: (DependencyContainer) -> Type) {
        let key = ObjectIdentifier(Type.self)
        registry[key] = registrationBlock(self)
    }
    
    /// Returns an implementation instance for provided abstract `Type`.
    public func resolve<Type>() throws -> Type {
        let key = ObjectIdentifier(Type.self)
        
        guard let entry = registry[key] as? Type else {
            throw ResolveError.doesNotExist
        }
        
        return entry
    }
}

extension DependencyContainer {
    public enum ResolveError: Error {
        case doesNotExist
    }
}
