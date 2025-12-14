import SwiftUI

@main
struct FlightSearchApp: App {
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                LoginView()
                    .navigationDestination(for: String.self) { route in
                        switch route {
                        case "FlightSearch":
                            FlightSearchView()
                        default:
                            Text("Unknown route: \(route)")
                        }
                    }
            }
        }
    }
}
