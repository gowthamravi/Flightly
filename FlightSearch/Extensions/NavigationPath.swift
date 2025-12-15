import Foundation

// Define possible navigation destinations
enum NavigationDestination: Hashable {
    case mainView
    case flightSearch
    case loginView
    case guestView
    // Add other destinations as needed
}

// Observable object to manage navigation state
class NavigationPath: ObservableObject {
    @Published var path = NavigationPathStore()
}

// Type alias for clarity
typealias NavigationPathStore = NavigationPath.Store

// Extension to define the path structure
extension NavigationPath {
    struct Store: RandomAccessCollection, MutableCollection {
        fileprivate(set) var elements: [NavigationDestination] = []

        var startIndex: Int { elements.startIndex }
        var endIndex: Int { elements.endIndex }

        subscript(index: Int) -> NavigationDestination {
            get { elements[index] }
            set { elements[index] = newValue }
        }

        func index(after i: Int) -> Int {
            elements.index(after: i)
        }

        mutating func append(_ destination: NavigationDestination) {
            elements.append(destination)
        }

        mutating func removeLast() {
            elements.removeLast()
        }
    }
}
