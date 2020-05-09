//
//  ObserverContainer.swift
//  Podushka
//
//  Created by Serhii Kostanian on 09.05.2020.
//  Copyright © 2020 Serhii Kostanian. All rights reserved.
//

import Foundation

/**
 This struct allows you to manage object observation. You can add and remove object observers 
 as well as enumerate current observers in order to notify them about some event.
 */
struct ObserverContainer<Observer> {
        
    private var containers: Set<Container> = []

    /// Adds observer to a container.
    mutating func add(_ observer: Observer) {
        let container = Container(observer as AnyObject)
        containers.update(with: container)
        purgeEmptyContainers()
    }
    
    /// Removes observer from a container.
    mutating func remove(_ observer: Observer) {
        let used = containers.filter { container in
            if let anotherObserver = container.observer as? Observer {
                let shouldRemove = ObjectIdentifier(observer as AnyObject) != ObjectIdentifier(anotherObserver as AnyObject)
                return shouldRemove
            } else {
                return false
            }
        }
        
        containers = used
        
        purgeEmptyContainers()
    }
    
    /// Enumerates all observers in a container.
    func enumerateObservers(_ body: (_ observer: Observer) -> Void) {
        containers.forEach { container in
            if let observer = container.observer as? Observer {
                body(observer)
            }
        }
    }
    
    private mutating func purgeEmptyContainers() {
        containers = containers.filter { $0.observer is Observer }
    }
}

// MARK: - Internal Container
private extension ObserverContainer {
    
    /// Internal hashable container for one observer object. 
    /// This struct is made to wrap an observer object into a hashable container
    /// and to be able to hold a weak reference to the observer.
    struct Container: Hashable {

        weak var observer: AnyObject?
        
        private(set) var hashValue = 0
        
        init(_ observer: AnyObject) {
            self.observer = observer
            self.hashValue = ObjectIdentifier(observer).hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(hashValue)
        }
        
        static func == (lhs: Container, rhs: Container) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
}
