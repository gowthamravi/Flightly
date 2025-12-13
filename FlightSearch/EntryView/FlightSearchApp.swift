import SwiftUI

@main
struct FlightSearchApp: App {
    // Create a single instance of AuthViewModel and make it an EnvironmentObject
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                // Check authentication status and show appropriate view
                if authViewModel.isAuthenticated {
                    MainView() // Show MainView if already authenticated
                } else {
                    AuthView() // Show AuthView when not authenticated
                }
            }
            .environmentObject(authViewModel) // Make authViewModel available to all child views
        }
    }
}
