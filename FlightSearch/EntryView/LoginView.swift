import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var navigationPath: NavigationPath

    var body: some View {
        VStack {
            Image("AppLogo") // Assuming you have an app logo image named "AppLogo"
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding(.bottom, 50)

            TextField("Email Address", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Login") {
                // TODO: Implement actual login logic
                print("Login tapped with email: \(email) and password: \(password)")
                // For now, just navigate to ContentView
                navigationPath.path.append(NavigationDestination.mainView)
            }
            .padding()
            .buttonStyle(PrimaryButtonStyle())

            Button("Forgot Password?") {
                // TODO: Implement forgot password flow
                print("Forgot Password tapped")
            }
            .padding(.top, 10)
            .foregroundColor(.blue)

            Spacer()

            HStack {
                Text("Don't have an account?")
                Button("Sign Up") {
                    // TODO: Implement sign up flow
                    print("Sign Up tapped")
                }
                .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .navigationBarHidden(true) // Hide the navigation bar
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(NavigationPath())
    }
}

// Custom Button Style for Login Button
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Animate press
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
