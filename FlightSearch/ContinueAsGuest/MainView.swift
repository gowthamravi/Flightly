import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Use EnvironmentObject to receive the shared instance

    var body: some View {
        VStack {
            Text("Welcome to the Main App!")
                .font(.largeTitle)
                .padding()

            Button("Log Out") {
                authViewModel.logout()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthViewModel()) // Provide a mock AuthViewModel for previews
    }
}
