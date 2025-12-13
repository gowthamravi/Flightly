import SwiftUI

struct ContentView: View {
    // Assuming AuthViewModel is provided from the environment or instantiated here.
    // Or, a top-level AppState could manage isAuthenticated.
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // User is authenticated, show main app content
                Text("Welcome to Flight Search!")
                // You would typically navigate to MainView or a dashboard here.
                // For example: MainView()
                Button("Log Out") { // Added for testing purposes
                    authViewModel.logout()
                }
            } else {
                // User is not authenticated, show AuthView
                AuthView(viewModel: authViewModel) // Pass the same instance
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
