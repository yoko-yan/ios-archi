//
//  Created by yoko-yan on 2023/10/31
//

// https://www.avanderlee.com/swift/dependency-injection/

import Foundation

public protocol InjectionKey {
    /// The associated type representing the type of the dependency injection key's value.
    associatedtype Value

    /// The default value for the dependency injection key.
    static var currentValue: Self.Value { get set }
}

/// Provides access to injected dependencies.
public struct InjectedValues { // swiftlint:disable:this convenience_type
    private final class Container {
        var current = InjectedValues()
    }

    /// This is only used as an accessor to the computed properties within extensions of `InjectedValues`.
    private static let container = Container()

    /// A static subscript for updating the `currentValue` of `InjectionKey` instances.
    public static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    /// A static subscript accessor for updating and references dependencies directly.
    public static subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
        get { container.current[keyPath: keyPath] }
        set { container.current[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper
public struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValues, T>
    public var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }

    public init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}

// MARK: - View model

public protocol Injectable {}
