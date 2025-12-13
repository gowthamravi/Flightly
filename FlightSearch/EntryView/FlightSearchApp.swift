import SwiftUI

@main
struct FlightSearchApp: App {
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
                    .environment("navigationPath", $navigationPath)
                    .navigationDestination(for: String.self) { route in
                        switch route {
                        case "FlightSearch":
                            FlightSearchView()
                                .environment("navigationPath", $navigationPath)
                        default:
                            Text("Unknown route: \(route)")
                        }
                    }
            }
        }
    }
}
