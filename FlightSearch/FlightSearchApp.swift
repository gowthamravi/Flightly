import SwiftUI

@main
struct FlightSearchApp: App {
    @StateObject var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
                    .environmentObject(navigationPath)
            }
        }
    }
}
