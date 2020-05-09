//
//  DependencyManager.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

public protocol DependencyManagerObserver: AnyObject {
    /// Tells the observer that the container with a specified type is now setup.
    func dependencyManager(_ dependencyManager: DependencyManager, didEndSetupContainer type: DependencyManager.ContainerType)
}

/**
 This class is managing dependencies. You should register all your dependencies here before using them.
 */
final public class DependencyManager {
    
    /// This enum contains all available types of dependency containers.
    /// The main idea is to have an ability to setup the container with different implementations
    /// of your dependencies in accordance to your needs.
    public enum ContainerType {
        /// Default container that we will use for debug and production.
        case normal
        /// Container with dependencies for UI testing purpose.
        /// This is just an example type to demonstrate how I would use such an approach in a real project.
        case uiTesting
    }
    
    private let container = DependencyContainer()
    private var observers = ObserverContainer<DependencyManagerObserver>()
    
    public func addObserver(_ observer: DependencyManagerObserver) {
        observers.add(observer)
    }
    
    public func removeObserver(_ observer: DependencyManagerObserver) {
        observers.remove(observer)
    }

    /// Setups a container as a specified `type` by registering all your dependencies with according implementations.
    public func setupContainer(as type: ContainerType) {
        switch type {
        case .normal:
            setupNormalContainer()
        case .uiTesting:
            setupUITestingContainer()
        }        
    }
    
    /// Returns a registered implementation instance for provided abstract `Type`.
    public func resolve<Type>() throws -> Type {
        return try container.resolve()
    }
    
    // MARK: - Container Setup
    private func setupNormalContainer() {
        
        // MARK: Services
        
        // MARK: ViewModels
        container.register { container -> MainViewModel in
            return MainVM(dependencyManager: self)
        }
        
        observers.enumerateObservers { (observer) in
            observer.dependencyManager(self, didEndSetupContainer: .normal)
        }
    }
    
    private func setupUITestingContainer() {
        // Here I would setup my mocked dependencies for testing.
    }
}
