import Combine
import SwiftUI

/// A navigator to use when the `NBNavigationStack` is initialized with a `NBNavigationPath` binding or no binding.`
public typealias PathNavigator = Navigator<AnyHashable>
public typealias PathAwareNavigator = EquatableNavigator<AnyHashable>

/// An object available via the environment that gives access to the current path.
/// Supports push and pop operations when `Screen` conforms to `NBScreen`.
@MainActor
public class Navigator<Screen>: ObservableObject {
  public let pathBinding: Binding<[Screen]>

  /// The current navigation path.
  public var path: [Screen] {
    get { pathBinding.wrappedValue }
    set { pathBinding.wrappedValue = newValue }
  }

  init(_ pathBinding: Binding<[Screen]>) {
    self.pathBinding = pathBinding
  }
}

public class EquatableNavigator<Screen>: ObservableObject where Screen: Equatable {
    init(navigator: Navigator<Screen>) {
        self.navigator = navigator
    }
    @MainActor public var navigator: Navigator<Screen> {
        willSet {
            if newValue.path != navigator.path {
                self.objectWillChange.send()
            }
        }
    }
}


extension Binding: Equatable where Value == [AnyHashable] {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
    
    public mutating func append(_ element: Value.Element) {
        var current = wrappedValue
        current.append(element)
        wrappedValue = current
    }
    public mutating func clear() {
        wrappedValue = Value()
    }
}
